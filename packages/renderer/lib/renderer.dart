// packages/renderer/lib/renderer.dart

import 'package:dust_component/component.dart';
import 'dart:js_interop'; // Still needed for JSFunction, JSAny etc. in callbacks for now
import 'dom_event.dart'; // Import DomEvent wrapper
import 'package:dust_dom/dom.dart' as dom; // Import the new DOM abstraction
import 'package:riverpod/riverpod.dart'; // Import Riverpod
// import 'package:dust_component/context.dart'; // Removed, BuildContext is now exported by component.dart
// --- Old JS Interop (To be removed) ---
// @JS('document.createElement') ... etc.
// extension JSAnyExtension on JSAny { ... }
// --- End Old JS Interop ---

// --- Simple Renderer State ---
// Store the state and target element for updates (very basic)
// State? _mountedState; // This seems unused now with _renderInternal handling root component VNode
dom.DomElement? _targetElement; // Use DomElement from dust_dom
// --- End Simple Renderer State ---

// Global Provider Container removed. Container is created in runApp and passed via BuildContext.
// _createDomElement function removed. Its logic is integrated into _mountNodeAndChildren.

/// Performs the rendering or re-rendering by building the VNode and patching the DOM.
/// This function is primarily used for stateful component updates triggered by setState.
/// The initial render is handled by runApp -> _renderInternal -> _patch.

/// Patches the DOM to reflect the difference between the new and old VNode trees.
// Forward declaration for helper functions (implementation will be added later)
// Helper function to handle mounting a new component VNode
void _mountComponent(dom.DomElement parentElement, VNode componentVNode,
    BuildContext context, dom.DomNode? referenceNode) {
  // Add referenceNode
  final component = componentVNode.component;
  if (component == null) {
    print('Error: _mountComponent called with a non-component VNode.');
    return;
  }

  print(
      'Mounting component: ${component.runtimeType} with key ${component.key}');

  VNode? renderedVNode; // The VNode tree rendered by the component

  if (component is StatefulWidget) {
    print('  -> StatefulWidget detected');
    // 1. Create State
    final state = component.createState();
    componentVNode.state = state; // Associate state with VNode

    // 2. Set update requester
    state.setUpdateRequester(() {
      print('Update requested by state for ${component.runtimeType}!');
      if (!state.mounted) {
        print('  -> State is not mounted, ignoring update request.');
        return;
      }
      if (componentVNode.renderedVNode == null) {
        print(
            '  -> Previous renderedVNode is null, cannot patch. Might indicate an issue.');
        // Potentially try a full re-mount? Or log error.
        return;
      }
      final currentDomNode =
          componentVNode.domNode as dom.DomNode?; // Cast to DomNode?
      if (currentDomNode?.parentNode == null ||
          currentDomNode?.parentNode is! dom.DomElement) {
        print(
            '  -> Cannot find valid parent DOM element for patching. Aborting update.');
        // This might happen if the component was removed from the DOM externally or structure is broken.
        return;
      }

      // Get the parent DOM element from the currently rendered node's parent
      // IMPORTANT: The parent for patching the *rendered* tree is the component's DOM node's parent.
      final parentForRenderedTree =
          currentDomNode!.parentNode as dom.DomElement;
      final oldRenderedVNode = componentVNode.renderedVNode;

      print('  -> Re-building component...');
      final newRenderedVNode = state.build();
      print('  -> Patching new rendered tree against old...');
      // Pass end anchor as reference node
      _patch(parentForRenderedTree, newRenderedVNode, oldRenderedVNode, context,
          componentVNode.endNode as dom.DomNode?);

      // Update references on the component VNode
      componentVNode.renderedVNode = newRenderedVNode;
      // The component's own domNode reference should point to the root of its rendered output
      componentVNode.domNode =
          newRenderedVNode.domNode; // Update domNode reference
      print('  -> Update finished for ${component.runtimeType}.');
    });

    // 3. Set context & Initialize state (calls initState)
    state.context = context;
    state.frameworkUpdateWidget(component); // Calls initState

    // 4. Build initial VNode tree
    renderedVNode = state.build();
    print(
        '  -> Initial build returned VNode: ${renderedVNode.tag ?? renderedVNode.component?.runtimeType ?? 'text'}');
  } else if (component is StatelessWidget) {
    print('  -> StatelessWidget detected');
    // Build VNode tree
    // Pass context to StatelessWidget build method
    renderedVNode = component.build(context);
    print(
        '  -> Build returned VNode: ${renderedVNode?.tag ?? renderedVNode?.component?.runtimeType ?? 'text'}');
  } else {
    print('Error: Unknown component type: ${component.runtimeType}');
    return;
  }

  // --- Create Anchor Nodes ---
  final startAnchor = dom.document.createComment(
      ' component-start: ${component.runtimeType} key: ${component.key} ');
  final endAnchor = dom.document.createComment(
      ' component-end: ${component.runtimeType} key: ${component.key} ');

  // --- Insert Anchors & Set VNode References ---
  // Insert BOTH anchors first, so the end anchor exists as a reference point
  parentElement.appendChild(startAnchor);
  parentElement
      .appendChild(endAnchor); // Insert end anchor immediately after start
  componentVNode.domNode = startAnchor; // Start anchor is the primary reference
  componentVNode.endNode = endAnchor; // Store end anchor reference

  // 5. Store rendered VNode on the component VNode
  componentVNode.renderedVNode = renderedVNode;

  // 6. Patch the DOM with the rendered VNode tree
  // The rendered content will be inserted *after* the startAnchor by _patch.
  if (renderedVNode != null) {
    // --- ProviderScope Handling ---
    // Determine the context to pass down. If this component is a ProviderScope,
    // use the context created within its state. Otherwise, use the inherited context.
    BuildContext contextForChild; // Removed final
    // Check if the component is ProviderScope and its state object exists on the VNode
    if (component is ProviderScope && componentVNode.state != null) {
      try {
        // Use the public getter 'childContext'
        contextForChild = (componentVNode.state as dynamic).childContext;
        print('  -> Using ProviderScope child context for patching child.');
      } catch (e) {
        print(
            'Error accessing childContext from ProviderScope state: $e. Falling back to inherited context.');
        contextForChild = context; // Fallback
      }
    } else {
      contextForChild = context; // Use the context passed into _mountComponent
    }
    // --- End ProviderScope Handling ---

    print(
        '  -> Patching rendered VNode into parent DOM (after start anchor)...');
    // Pass end anchor as reference node and the determined context
    _patch(
        parentElement,
        renderedVNode,
        null,
        contextForChild, // Use contextForChild
        componentVNode.endNode as dom.DomNode?);
    print('  -> Finished patching rendered VNode.');
  } else {
    print('  -> Component returned null VNode, nothing to patch.');
  }

  // End anchor is already inserted.

  print('Finished mounting component: ${component.runtimeType}');
}

// Helper function to handle updating an existing component VNode
void _updateComponent(dom.DomElement parentElement, VNode newComponentVNode,
    VNode oldComponentVNode, BuildContext context) {
  final newComponent = newComponentVNode.component;
  final oldComponent = oldComponentVNode.component;

  if (newComponent == null || oldComponent == null) {
    print('Error: _updateComponent called with non-component VNodes.');
    return;
  }

  // Check if component types or keys don't match. If they do, unmount old and mount new.
  if (newComponent.runtimeType != oldComponent.runtimeType ||
      newComponent.key != oldComponent.key) {
    print(
        'Component type or key mismatch during update. Unmounting old and mounting new.');
    _unmountComponent(oldComponentVNode);
    // Pass null as referenceNode, effectively appending where the old component was
    _mountComponent(parentElement, newComponentVNode, context, null);
    return;
  }

  // --- Types and Keys Match: Reuse existing state and update ---
  // Carry over the state object from the old VNode to the new one
  newComponentVNode.state = oldComponentVNode.state;
  // Carry over the DOM node (start anchor) reference
  newComponentVNode.domNode = oldComponentVNode.domNode;
  // Carry over the end anchor reference
  newComponentVNode.endNode = oldComponentVNode.endNode;
  // Carry over the rendered VNode reference initially
  newComponentVNode.renderedVNode = oldComponentVNode.renderedVNode;

  print(
      'Updating component: ${newComponent.runtimeType} with key ${newComponent.key}');

  VNode? newRenderedVNode;
  final oldRenderedVNode =
      oldComponentVNode.renderedVNode; // Get old rendered tree

  if (newComponent is StatefulWidget) {
    print('  -> StatefulWidget update');
    // --- DEBUG REMOVED ---
    // 1. Get existing State object
    final state = oldComponentVNode.state; // Should be carried over now
    if (state == null) {
      print('Error: State object not found for StatefulWidget during update.');
      // Fallback: Treat as a new mount? This indicates a logic error.
      _unmountComponent(oldComponentVNode); // Clean up old if possible
      // Pass null as referenceNode
      _mountComponent(parentElement, newComponentVNode, context, null);
      return;
    }

    // 2. Associate state with new VNode (already done above)
    // newComponentVNode.state = state;

    // 3. Update state's internal widget reference (triggers didUpdateWidget)
    state.frameworkUpdateWidget(newComponent);

    // 4. Build the new VNode tree
    newRenderedVNode = state.build();
    print(
        '  -> Updated build returned VNode: ${newRenderedVNode.tag ?? newRenderedVNode.component?.runtimeType ?? 'text'}');
  } else if (newComponent is StatelessWidget) {
    print('  -> StatelessWidget update');
    // Build the new VNode tree
    // Pass context to StatelessWidget build method
    newRenderedVNode = newComponent.build(context);
    print(
        '  -> Build returned VNode: ${newRenderedVNode?.tag ?? newRenderedVNode?.component?.runtimeType ?? 'text'}');
  } else {
    print(
        'Error: Unknown component type during update: ${newComponent.runtimeType}');
    return; // Or handle differently
  }

  // 5. Store the new rendered VNode
  newComponentVNode.renderedVNode = newRenderedVNode;

  // 6. Patch the DOM by diffing the new rendered tree against the old one, inserting before the end anchor
  if (newRenderedVNode != null || oldRenderedVNode != null) {
    // --- ProviderScope Handling ---
    // Determine the context to pass down. If this component is a ProviderScope,
    // use the context created within its state. Otherwise, use the inherited context.
    BuildContext contextForChild; // Removed final
    final state =
        newComponentVNode.state; // Get the state associated with the NEW VNode
    // Check if the component is ProviderScope and its state object exists
    if (newComponent is ProviderScope && state != null) {
      try {
        // Use the public getter 'childContext'
        contextForChild = (state as dynamic).childContext;
        print(
            '  -> Using ProviderScope child context for patching child update.');
      } catch (e) {
        print(
            'Error accessing childContext from ProviderScope state during update: $e. Falling back to inherited context.');
        contextForChild = context; // Fallback
      }
    } else {
      contextForChild = context; // Use the context passed into _updateComponent
    }
    // --- End ProviderScope Handling ---

    print(
        '  -> Patching updated rendered VNode against old rendered VNode (before end anchor)...');
    // The parent element is the one containing the anchors
    final parentForRenderedTree = parentElement; // Passed into _updateComponent
    final endAnchor =
        oldComponentVNode.endNode as dom.DomNode?; // Get the end anchor

    if (endAnchor == null) {
      print(
          'Error: End anchor not found during component update for key ${newComponent.key}. Cannot patch.');
      // Maybe attempt full unmount/remount?
    } else {
      _patch(
          parentForRenderedTree,
          newRenderedVNode,
          oldRenderedVNode,
          contextForChild, // Use contextForChild
          endAnchor); // Pass endAnchor as reference node for insertions

      // The component's domNode (start anchor) and endNode (end anchor) remain the same.
      // Do NOT update newComponentVNode.domNode based on renderedVNode.
      print('  -> Finished patching rendered tree between anchors.');
    }
  } else {
    print('  -> Both old and new rendered VNodes are null, nothing to patch.');
  }

  print('Finished updating component: ${newComponent.runtimeType}');
}

// Helper function to handle unmounting a component VNode
void _unmountComponent(VNode componentVNode) {
  final component = componentVNode.component;
  if (component == null) {
    print('Error: _unmountComponent called with a non-component VNode.');
    return;
  }

  print(
      'Unmounting component: ${component.runtimeType} with key ${component.key}');

  // 1. Call dispose on the State object if it's a StatefulWidget
  final state = componentVNode.state;
  if (state != null) {
    print('  -> Calling dispose() on state object');
    try {
      state.dispose();
    } catch (e, s) {
      print('Error during state dispose: $e\n$s');
      // Decide if we should continue or rethrow
    }
    componentVNode.state = null; // Clear the state reference
  }

  // 2. Remove rendered DOM nodes between anchors
  final startAnchor = componentVNode.domNode as dom.DomNode?;
  final endAnchor = componentVNode.endNode as dom.DomNode?;

  if (startAnchor != null &&
      endAnchor != null &&
      startAnchor.parentNode is dom.DomElement) {
    final parentElement = startAnchor.parentNode as dom.DomElement;
    print('  -> Removing DOM nodes between anchors...');

    // Recursively clean up listeners in the rendered tree *before* removing DOM nodes
    if (componentVNode.renderedVNode != null) {
      _removeListenersRecursively(componentVNode.renderedVNode!);
    }

    // Remove nodes between startAnchor (exclusive) and endAnchor (exclusive)
    var currentNode = startAnchor.nextNode; // Use JS interop for nextSibling
    while (currentNode != null && currentNode != endAnchor) {
      final nodeToRemove = currentNode;
      currentNode = currentNode.nextNode; // Move to next before removing
      print('     - Removing node: ${nodeToRemove.hashCode}');
      parentElement.removeChild(nodeToRemove);
    }
    print('  -> Finished removing nodes between anchors.');

    // 3. Remove the anchor nodes themselves
    print('  -> Removing anchor nodes...');
    parentElement.removeChild(startAnchor);
    parentElement.removeChild(endAnchor);
    print('  -> Anchor nodes removed.');
  } else {
    print(
        'Warning: Could not find valid anchors or parent element during unmount for component ${component.runtimeType}. Listener cleanup might be incomplete.');
    // Attempt listener cleanup on the rendered tree even if anchors are missing
    if (componentVNode.renderedVNode != null) {
      print('  -> Attempting listener cleanup on rendered tree anyway...');
      _removeListenersRecursively(componentVNode.renderedVNode!);
    }
  }
  componentVNode.renderedVNode = null; // Clear the rendered VNode reference

  // 4. Clear the anchor references on the componentVNode
  componentVNode.domNode = null;
  componentVNode.endNode = null;

  print('Finished unmounting component: ${component.runtimeType}');
}

/// Mounts a new element or text VNode and its children into the DOM.
/// This is called by _patch during initial render (`oldVNode == null`) for non-component nodes.
/// It creates the immediate DOM node, sets attributes/listeners, recursively mounts children
/// using _patch, and appends the result to the parent element.
void _mountNodeAndChildren(dom.DomElement parentElement, VNode vnode,
    BuildContext context, dom.DomNode? referenceNode) {
  // Add referenceNode
  // 1. Create the current DOM node (element or text)
  final dom.DomNode currentNode;
  if (vnode.tag == null) {
    // Text node
    currentNode = dom.document.createTextNode(vnode.text ?? '');
    vnode.domNode = currentNode;
  } else {
    // Element node
    final dom.DomElement element = dom.createElement(vnode.tag!);
    vnode.domNode = element;
    currentNode = element;

    // Set Attributes
    if (vnode.attributes != null) {
      vnode.attributes!.forEach((name, value) {
        element.setAttribute(name, value);
        // print('Set attribute $name="$value" on <${vnode.tag}>'); // Keep logs less verbose
      });
    }

    // Attach Event Listeners
    if (vnode.listeners != null) {
      vnode.listeners!.forEach((eventName, callback) {
        final jsFunction = ((JSAny jsEvent) {
          callback(DomEvent(jsEvent));
        }).toJS;
        element.addEventListener(eventName, jsFunction);
        print('Added listener for "$eventName" on <${vnode.tag}>');
        (vnode.jsFunctionRefs ??= {})[eventName] = jsFunction;
        (vnode.dartCallbackRefs ??= {})[eventName] = callback;
      });
    }

    // 2. Recursively Mount Children using _patch
    if (vnode.children != null) {
      // print('>>> _mountNodeAndChildren: Mounting children for <${vnode.tag}>');
      for (final childVNode in vnode.children!) {
        // Use _patch with oldVNode = null to handle mounting components or elements/text correctly
        // Append child, no specific reference node needed here
        _patch(element, childVNode, null, context, null);
      }
      // print('>>> _mountNodeAndChildren: Finished mounting children for <${vnode.tag}>');
    }
  }
  // 3. Insert the fully constructed node (with children) into the parent before the reference node
  parentElement.insertBefore(currentNode, referenceNode);
}

// --- Helper Functions ---

// Helper to remove listeners from a single node
void _removeListenersFromNode(VNode vnode) {
  if (vnode.domNode is dom.DomElement && vnode.jsFunctionRefs != null) {
    final domElement = vnode.domNode as dom.DomElement;
    if (vnode.jsFunctionRefs!.isNotEmpty) {
      print(
          '  -> Removing ${vnode.jsFunctionRefs!.length} listeners for node key ${vnode.key}');
      vnode.jsFunctionRefs!.forEach((eventName, jsFunction) {
        print(
            '     - Removing listener for "$eventName" via _removeListenersFromNode');
        domElement.removeEventListener(eventName, jsFunction);
      });
      // Clear the refs after removing
      vnode.jsFunctionRefs!.clear();
      vnode.dartCallbackRefs?.clear(); // Also clear dart refs
    }
  }
}

// Helper to recursively remove listeners from a node and its children
void _removeListenersRecursively(VNode vnode) {
  // Remove listeners from the current node first
  _removeListenersFromNode(vnode);

  // Then, recursively remove from children
  // Check if the node represents a component and has a rendered tree
  if (vnode.component != null && vnode.renderedVNode != null) {
    _removeListenersRecursively(vnode.renderedVNode!);
  } else if (vnode.children != null) {
    // Otherwise, check standard children
    for (final childVNode in vnode.children!) {
      _removeListenersRecursively(childVNode);
    }
  }
}

// Modified removeVNode to accept parentDomNode
void removeVNode(dom.DomElement parentDomNode, VNode vnode) {
  if (vnode.domNode == null) {
    print(
        'Warning: removeVNode called but vnode.domNode is null for key ${vnode.key}');
    return;
  }

  print('Removing DOM node (key: ${vnode.key}): ${vnode.domNode.hashCode}');

  // --- Recursively Remove Listeners BEFORE removing the node ---
  _removeListenersRecursively(vnode);
  // --- End Recursive Listener Removal ---

  // Now remove the DOM node itself
  if (vnode.domNode is dom.DomNode) {
    // Check if it's a valid DomNode
    // Use the removeChild from DomNodeExtension
    parentDomNode
        .removeChild(vnode.domNode as dom.DomNode); // Use passed parentDomNode
  } else {
    // This case should ideally not happen if domNode was set correctly
    print('Error: Cannot remove, vnode.domNode is not a valid DomNode type.');
  }
}

// --- End Helper Functions ---

void _patch(dom.DomElement parentElement, VNode? newVNode, VNode? oldVNode,
    BuildContext context,
    [dom.DomNode? referenceNode]) {
  // Add optional referenceNode
  // Helper functions moved outside _patch
  // --- DEBUG REMOVED ---
  print(
      'Patching: parent=${parentElement.hashCode}, new=[${newVNode?.tag ?? newVNode?.component?.runtimeType ?? newVNode?.text?.substring(0, min(5, newVNode.text?.length ?? 0)) ?? 'null'}], old=[${oldVNode?.tag ?? oldVNode?.component?.runtimeType ?? oldVNode?.text?.substring(0, min(5, oldVNode.text?.length ?? 0)) ?? 'null'}]');

  // --- Initial Render / Removal Logic ---
  // Case 1: New VNode is null -> Remove the old DOM node
  if (newVNode == null) {
    if (oldVNode != null) {
      if (oldVNode.component != null) {
        // Unmount old component
        print('Unmounting old component (newVNode is null)...');
        _unmountComponent(oldVNode);
      } else if (oldVNode.domNode != null) {
        // Remove old element/text node
        print(
            'Removing old DOM node (newVNode is null): ${oldVNode.domNode.hashCode}');
        removeVNode(parentElement, oldVNode); // Handles listener cleanup
      } else {
        print('Old VNode or its DOM node is null, nothing to remove.');
      }
    }
    return; // Nothing further to do if newVNode is null
  }

  // Case 2: Old VNode is null -> Mount the new VNode
  if (oldVNode == null) {
    if (newVNode.component != null) {
      // Mount new component
      print('Mounting new component (oldVNode was null)...');
      _mountComponent(parentElement, newVNode, context,
          referenceNode); // Pass referenceNode
    } else {
      // Mount new element/text node and its children correctly
      print('Mounting new element/text node (oldVNode was null)...');
      _mountNodeAndChildren(parentElement, newVNode, context,
          referenceNode); // Pass referenceNode
    }
    return; // Node mounted, exit patch for this level
  }

  // --- Update Logic (Both newVNode and oldVNode exist) ---

  // --- Component Handling Logic ---
  final bool isNewComponent = newVNode.component != null;
  final bool isOldComponent = oldVNode.component != null;

  if (isNewComponent) {
    if (isOldComponent) {
      // Update existing component
      print('Updating component...');
      _updateComponent(parentElement, newVNode, oldVNode, context);
    } else {
      // Mount new component (replacing old element/text if necessary)
      print('Mounting new component (replacing element/text)...');
      // Unmount old element/text node first
      removeVNode(parentElement, oldVNode); // Pass parentElement
      // When replacing, the reference node is the one after the old node being removed.
      // However, since we remove first, we can just pass the original referenceNode.
      _mountComponent(parentElement, newVNode, context, referenceNode);
    }
    return; // Component logic handled, exit patch
  } else if (isOldComponent) {
    // Unmount old component (newVNode is element/text)
    print('Unmounting old component (replacing with element/text)...');
    _unmountComponent(oldVNode);
    // Mount new element/text node
    print('Mounting new element/text node after unmounting component...');
    // Pass the original referenceNode
    _mountNodeAndChildren(parentElement, newVNode, context, referenceNode);
    return; // Component logic handled, exit patch
  }

  // --- Non-Component Handling Logic (Elements and Text Nodes) ---
  // Only reach here if both newVNode and oldVNode are NOT components
  print('Handling non-component patch...');

  // Case 3: Both VNodes exist, but represent different types -> Replace
  // Different tags OR one is text and the other is element
  bool differentTypes =
      oldVNode.tag != newVNode.tag; // Includes null comparison for text nodes
  if (differentTypes) {
    print('Replacing node due to different element/text types...');
    final Object? oldDomNodeObject = oldVNode.domNode;

    if (oldDomNodeObject is dom.DomNode) {
      // Mount the new node first (using helper to handle children)
      // We need a temporary parent or mount differently.
      // Simpler: remove old, then mount new.
      removeVNode(parentElement, oldVNode); // Remove old node and listeners
      // Pass the original referenceNode
      _mountNodeAndChildren(parentElement, newVNode, context, referenceNode);
    } else {
      // Fallback: If the old reference is invalid, just mount the new node.
      print(
          'Warning/Error: Cannot replace node, old DOM node reference invalid. Mounting new node.');
      // Pass the original referenceNode
      _mountNodeAndChildren(parentElement, newVNode, context, referenceNode);
    }
    return;
  }

  // Case 4: Both VNodes exist and are of the same type

  // Ensure the domNode reference is carried over for patching
  final dom.DomNode domNode = oldVNode.domNode as dom.DomNode;
  newVNode.domNode = domNode; // Carry over the DOM node reference (DomNode)

  // Carry over the JSFunction and Dart callback references from the old VNode
  // to the new one initially. We'll update them during listener patching.
  if (oldVNode.jsFunctionRefs != null) {
    newVNode.jsFunctionRefs = Map.from(oldVNode.jsFunctionRefs!);
  }
  if (oldVNode.dartCallbackRefs != null) {
    newVNode.dartCallbackRefs = Map.from(oldVNode.dartCallbackRefs!);
  }

  // 4a: Patch Text Nodes
  if (newVNode.tag == null) {
    // It's a text node
    if (oldVNode.text != newVNode.text) {
      print('Updating text node content...');
      // Use the textContent setter from DomNodeExtension
      domNode.textContent = newVNode.text ?? '';
    }
    return; // Nothing more to do for text nodes
  }

  // 4b: Patch Element Nodes (Attributes and Children)
  print('Patching element <${newVNode.tag}>...');

  final oldAttributes = oldVNode.attributes ?? const {};
  final newAttributes = newVNode.attributes ?? const {};

  // --- Optimization: Check for identical attribute maps ---
  if (identical(oldAttributes, newAttributes)) {
    // print('  -> Skipping attribute update (identical maps)'); // Optional: Keep for debugging
  } else {
    // --- Maps are different, proceed with detailed patching ---
    // print('  -> Updating attributes...'); // Optional: Keep for debugging

    // Remove attributes that are in old but not in new
    oldAttributes.forEach((name, _) {
      if (!newAttributes.containsKey(name)) {
        // print('Removing attribute $name from <${newVNode.tag}>'); // Optional: Keep for debugging
        (domNode as dom.DomElement).removeAttribute(name);
      }
    });

    // Add or update attributes that are in new
    newAttributes.forEach((name, value) {
      final oldValue = oldAttributes[name];
      if (oldValue != value) {
        // print('Setting attribute $name="$value" on <${newVNode.tag}>'); // Optional: Keep for debugging
        (domNode as dom.DomElement).setAttribute(name, value);
      }
    });
    // print('  -> Finished updating attributes.'); // Optional: Keep for debugging
  } // End of attribute patching block

  // 4c: Patch Event Listeners
  final oldListeners = oldVNode.listeners ?? const {};
  final newListeners = newVNode.listeners ?? const {};

  // Remove listeners that are in old but not in new
  oldListeners.forEach((eventName, oldCallback) {
    if (!newListeners.containsKey(eventName)) {
      final oldJsFunction = oldVNode.jsFunctionRefs?[eventName];
      if (oldJsFunction != null) {
        print('Removing listener for "$eventName" from <${newVNode.tag}>');
        // Use the removeEventListener from DomElementExtension
        (domNode as dom.DomElement)
            .removeEventListener(eventName, oldJsFunction);
        print(
            '  -> Listener for "$eventName" removed via _patch (event removed)');
        // Remove references from the newVNode as well, since it initially copied them
        newVNode.jsFunctionRefs?.remove(eventName);
        newVNode.dartCallbackRefs?.remove(eventName); // Also remove Dart ref
      } else {
        print(
            'Warning: Could not remove listener for "$eventName" on <${newVNode.tag}> - JSFunction reference not found.');
      }
    }
  });

  // Add or update listeners that are in new
  newListeners.forEach((eventName, newCallback) {
    final oldDartCallback = oldVNode.dartCallbackRefs?[eventName];

    // --- Optimization: Check if callback is identical ---
    if (identical(newCallback, oldDartCallback)) {
      print(
          '  -> Skipping listener update for "$eventName" on <${newVNode.tag}> (callback identical)');
      // No need to remove/add, references were already carried over.
      return; // Move to the next listener
    }

    // --- Callback has changed or is new ---
    print('Updating listener for "$eventName" on <${newVNode.tag}>');

    // Remove the old listener if it exists and we have its reference
    final oldJsFunction = oldVNode.jsFunctionRefs?[eventName];
    if (oldJsFunction != null) {
      print('  -> Removing old listener first');
      // Use the removeEventListener from DomElementExtension
      (domNode as dom.DomElement).removeEventListener(eventName, oldJsFunction);
      print(
          '  -> Listener for "$eventName" removed via _patch (callback changed)');
    } else if (oldListeners.containsKey(eventName)) {
      // Log if old listener existed but we didn't have its JS ref
      print(
          '  -> Warning: Old listener for "$eventName" existed but no JSFunction reference was found for removal.');
    }

    // Add the new listener
    // Create a JS function that wraps the new Dart callback
    final newJsFunction = ((JSAny jsEvent) {
      newCallback(DomEvent(jsEvent));
    }).toJS;
    // Use the addEventListener from DomElementExtension
    (domNode as dom.DomElement).addEventListener(eventName, newJsFunction);
    print('  -> Added new listener');

    // Store the new references, overwriting any old ones
    (newVNode.jsFunctionRefs ??= {})[eventName] = newJsFunction;
    (newVNode.dartCallbackRefs ??= {})[eventName] =
        newCallback; // Store Dart callback
  });

  // 4d: Patch Children (Keyed Reconciliation)
  // Assume domNode is DomElement here since we are patching children
  _patchChildren(domNode as dom.DomElement, oldVNode.children,
      newVNode.children, context); // Pass context

  print('Finished patching children for <${newVNode.tag}>.');
}

// Helper function for min to avoid import 'dart:math' just for this
int min(int a, int b) => a < b ? a : b;

/// Patches the children of a DOM element using a keyed reconciliation algorithm.
/// Based on common algorithms found in frameworks like Vue and Inferno.
void _patchChildren(dom.DomElement parentDomNode, List<VNode>? oldChOriginal,
    List<VNode>? newChOriginal, BuildContext context) {
  // Add context parameter
  // Use DomElement
  // Work with copies that allow nulls for marking moved nodes
  List<VNode?> oldCh = oldChOriginal?.map((e) => e as VNode?).toList() ?? [];
  List<VNode?> newCh = newChOriginal?.map((e) => e as VNode?).toList() ?? [];

  // Use the new tagName getter from JSAnyExtension
  final parentTag = parentDomNode.tagName; // Use DomElement extension
  print(
      '>>> _patchChildren START for parent <$parentTag>: old=${oldCh.length}, new=${newCh.length}');

  int oldStartIdx = 0;
  int newStartIdx = 0;
  int oldEndIdx = oldCh.length - 1;
  int newEndIdx = newCh.length - 1;

  VNode? oldStartVNode = oldCh.isNotEmpty ? oldCh[0] : null;
  VNode? newStartVNode = newCh.isNotEmpty ? newCh[0] : null;
  VNode? oldEndVNode = oldCh.isNotEmpty ? oldCh[oldEndIdx] : null;
  VNode? newEndVNode = newCh.isNotEmpty ? newCh[newEndIdx] : null;

  Map<Object, int>? oldKeyToIdx; // Lazily created map for old keys

  bool isSameVNode(VNode? vnode1, VNode? vnode2) {
    // Basic check: same key and same tag (or both text nodes)
    // Also check if both are components of the same runtime type
    if (vnode1?.key != vnode2?.key) return false;
    if (vnode1?.component != null && vnode2?.component != null) {
      return vnode1!.component.runtimeType == vnode2!.component.runtimeType;
    }
    return vnode1?.tag == vnode2?.tag; // Handles element/text comparison
  }

  // Helper functions (_removeListenersFromNode, _removeListenersRecursively, removeVNode) moved outside _patchChildren

  dom.DomNode? getDomNodeBefore(int index) {
    // Return DomNode?
    // Helper to find the DOM node to insert before
    // FIX: Add null checks (!) since newCh is List<VNode?>
    if (index < newCh.length) {
      // Removed !
      // Check length first
      final nextVNode = newCh[index]; // Access element
      if (nextVNode != null && nextVNode.domNode is dom.DomNode) {
        // Check if VNode and its domNode are valid DomNode
        return nextVNode.domNode as dom.DomNode;
      }
    }
    return null; // Insert at the end
  }

  // Renamed helper to avoid potential conflicts and clarify purpose
  void _domInsertBefore(dom.DomNode newNode, dom.DomNode? referenceNode) {
    // Use DomNode
    // Use the insertBefore from DomNodeExtension
    parentDomNode.insertBefore(newNode, referenceNode);
    print(
        'Inserted DOM node ${newNode.hashCode} before ${referenceNode?.hashCode ?? 'end'}');
  }

  while (oldStartIdx <= oldEndIdx && newStartIdx <= newEndIdx) {
    // --- Skip null markers (nodes that were moved) ---
    if (oldStartVNode == null) {
      oldStartVNode = ++oldStartIdx <= oldEndIdx ? oldCh[oldStartIdx] : null;
    } else if (oldEndVNode == null) {
      oldEndVNode = --oldEndIdx >= oldStartIdx ? oldCh[oldEndIdx] : null;
      // --- Skip null nodes in new list (less common but possible) ---
    } else if (newStartVNode == null) {
      newStartVNode = ++newStartIdx <= newEndIdx ? newCh[newStartIdx] : null;
    } else if (newEndVNode == null) {
      newEndVNode = --newEndIdx >= newStartIdx ? newCh[newEndIdx] : null;
      // --- Core comparison logic ---
    } else if (isSameVNode(oldStartVNode, newStartVNode)) {
      // Same start nodes
      print(
          '>>> _patchChildren [Case 1: Same Start]: Patching key ${newStartVNode.key}');
      // --- DEBUG REMOVED ---
      // Patch existing node, no reference node needed for the patch itself
      _patch(parentDomNode, newStartVNode, oldStartVNode, context, null);
      oldStartVNode = ++oldStartIdx <= oldEndIdx ? oldCh[oldStartIdx] : null;
      newStartVNode = ++newStartIdx <= newEndIdx ? newCh[newStartIdx] : null;
    } else if (isSameVNode(oldEndVNode, newEndVNode)) {
      // Same end nodes
      print(
          '>>> _patchChildren [Case 2: Same End]: Patching key ${newEndVNode.key}');
      // Patch existing node, no reference node needed
      _patch(parentDomNode, newEndVNode, oldEndVNode, context, null);
      oldEndVNode = --oldEndIdx >= oldStartIdx ? oldCh[oldEndIdx] : null;
      newEndVNode = --newEndIdx >= newStartIdx ? newCh[newEndIdx] : null;
    } else if (isSameVNode(oldStartVNode, newEndVNode)) {
      // Node moved right
      print(
          '>>> _patchChildren [Case 3: Moved Right]: Patching key ${newEndVNode.key}, moving DOM node');
      // Patch existing node before move, no reference node needed
      _patch(parentDomNode, newEndVNode, oldStartVNode, context, null);
      _domInsertBefore(
          // Use renamed helper
          oldStartVNode.domNode as dom.DomNode, // Pass DomNode
          getDomNodeBefore(newEndIdx + 1)); // Returns DomNode?
      oldStartVNode = ++oldStartIdx <= oldEndIdx ? oldCh[oldStartIdx] : null;
      newEndVNode = --newEndIdx >= newStartIdx ? newCh[newEndIdx] : null;
    } else if (isSameVNode(oldEndVNode, newStartVNode)) {
      // Node moved left
      print(
          '>>> _patchChildren [Case 4: Moved Left]: Patching key ${newStartVNode.key}, moving DOM node');
      // Patch existing node before move, no reference node needed
      _patch(parentDomNode, newStartVNode, oldEndVNode, context, null);
      _domInsertBefore(
          // Use renamed helper
          oldEndVNode.domNode as dom.DomNode, // Pass DomNode
          getDomNodeBefore(newStartIdx)); // Returns DomNode?
      oldEndVNode = --oldEndIdx >= oldStartIdx ? oldCh[oldEndIdx] : null;
      newStartVNode = ++newStartIdx <= newEndIdx ? newCh[newStartIdx] : null;
    } else {
      // Fallback: Use keys to find the node or create a new one
      oldKeyToIdx ??= {
        for (int i = oldStartIdx; i <= oldEndIdx; i++)
          if (oldCh[i]?.key != null) oldCh[i]!.key!: i
      };

      final idxInOld =
          newStartVNode.key == null ? null : oldKeyToIdx[newStartVNode.key!];

      if (idxInOld == null) {
        // New node, create and insert
        // New node, patch it into the DOM (oldVNode is null)
        print(
            '>>> _patchChildren [Case 5a: New Node]: Patching new node with key ${newStartVNode.key}');
        // Call _patch recursively, which will handle mounting components or creating elements
        // Mount new node, pass the calculated reference node
        _patch(parentDomNode, newStartVNode, null, context,
            getDomNodeBefore(newStartIdx));
        // Get the newly created/mounted DOM node from the VNode after patching
        final newDomNode = newStartVNode.domNode;
        if (newDomNode is dom.DomNode) {
          _domInsertBefore(newDomNode, getDomNodeBefore(newStartIdx));
        } else {
          print('Error: New node patch did not result in a valid domNode.');
        }
      } else {
        // Found old node with same key, patch and move
        print(
            '>>> _patchChildren [Case 5b: Found Key]: Patching key ${newStartVNode.key}, moving DOM node');
        final vnodeToMove = oldCh[idxInOld];
        if (vnodeToMove == null) {
          print(
              'Error: Found null VNode in oldChildren at index $idxInOld for key ${newStartVNode.key}. This might indicate a duplicate key or logic error.');
        } else {
          // Patch existing node before move, no reference node needed
          _patch(parentDomNode, newStartVNode, vnodeToMove, context, null);
          _domInsertBefore(
              vnodeToMove.domNode as dom.DomNode, // Pass DomNode
              getDomNodeBefore(newStartIdx)); // Returns DomNode?
          // FIX: Assign null to List<VNode?> - This is now valid because oldCh is List<VNode?>
          oldCh[idxInOld] =
              null; // Mark as moved/processed - Should be valid now
        }
      }
      newStartVNode = ++newStartIdx <= newEndIdx ? newCh[newStartIdx] : null;
    }
  }

  // Cleanup remaining nodes in old list
  if (oldStartIdx <= oldEndIdx) {
    // Remove remaining old nodes
    print(
        '>>> _patchChildren [Cleanup Old]: Removing ${oldEndIdx - oldStartIdx + 1} nodes from index $oldStartIdx');
    for (int i = oldStartIdx; i <= oldEndIdx; i++) {
      // Only remove nodes that weren't marked as null (moved)
      if (oldCh[i] != null) {
        removeVNode(parentDomNode, oldCh[i]!); // Pass parentDomNode
      }
    }
  }

  // Add remaining new nodes
  if (newStartIdx <= newEndIdx) {
    // Add remaining new nodes
    print(
        '>>> _patchChildren [Cleanup New]: Adding ${newEndIdx - newStartIdx + 1} nodes from index $newStartIdx');
    final dom.DomNode? referenceNode =
        getDomNodeBefore(newEndIdx + 1); // Returns DomNode?
    for (int i = newStartIdx; i <= newEndIdx; i++) {
      // Only add nodes that aren't null (shouldn't happen with newCh, but safe)
      if (newCh[i] != null) {
        // Use _patch with oldVNode = null to correctly mount the new node
        // Mount new node, pass the calculated reference node
        _patch(parentDomNode, newCh[i], null, context, referenceNode);
        // Get the newly created/mounted DOM node from the VNode after patching
        final newDomNode = newCh[i]?.domNode;
        if (newDomNode is dom.DomNode) {
          _domInsertBefore(newDomNode, referenceNode); // Pass DomNode, DomNode?
        } else {
          print(
              'Error: New node patch (in cleanup) did not result in a valid domNode.');
        }
      }
    }
  }
  print('>>> _patchChildren END for parent <$parentTag>');
}

/// Renders a component into a target DOM element for the first time.
// Internal render function, now requires context
void _renderInternal(
    Component component, String targetElementId, BuildContext context) {
  print(
    'Starting initial render process for component $component into #$targetElementId',
  );

  // 1. Get the target DOM element
  _targetElement = dom.getElementById(targetElementId); // Use dom function
  if (_targetElement == null) {
    print('Error: Target element #$targetElementId not found.');
    return;
  }

  // 2. Create the root VNode representing the component
  //    We don't build the component directly here anymore.
  //    We create a VNode for the root component and let _patch handle mounting.
  final VNode rootComponentVNode =
      VNode.component(component); // Key is taken from component internally

  // 3. Patch the target element with the root component VNode
  //    Since this is the initial render, oldVNode is null.
  // Initial root render, append to target, no reference node needed
  _patch(_targetElement!, rootComponentVNode, null, context, null);

  // 4. Store the root component VNode as the last rendered tree
  // _lastRenderedVNode = rootComponentVNode; // No longer needed

  // --- Old Logic (Removed) ---
  // if (component is StatefulWidget) { ... } else if (component is StatelessWidget) { ... }
  // The logic for creating state, calling build, etc., is now handled within
  // _mountComponent, which is called by _patch when oldVNode is null.
  // --- End Old Logic ---

  print('Initial render process finished.');
}

/// Public entry point for running a Dust application.
///
/// Mounts the given [rootComponent] into the DOM element with the specified
/// [targetElementId].
void runApp(Component rootComponent, String targetElementId) {
  print('Dust runApp starting...');

  // 1. Create the root ProviderContainer
  // Dispose previous container if exists (e.g., during hot restart in dev) - Handled by framework restart now.
  final ProviderContainer container = ProviderContainer();
  // Removed global assignment: _appProviderContainer = container;
  print('Dust ProviderContainer created.');

  // 2. Create the root BuildContext
  final BuildContext rootContext = BuildContext(container);
  print('Dust root BuildContext created.');

  // 3. Call the internal render function with the root context
  try {
    // Rename the internal function to avoid confusion
    _renderInternal(rootComponent, targetElementId, rootContext);
  } catch (e, s) {
    print('Error during initial render in runApp: $e\n$s');
    // Dispose container on error during initial render
    container.dispose(); // Dispose the locally created container
    // Removed global assignment: _appProviderContainer = null;
    rethrow; // Rethrow the error after logging
  }
  // Note: Container disposal on app unmount is not handled yet.
  print('Dust runApp finished initial render call.');
}
