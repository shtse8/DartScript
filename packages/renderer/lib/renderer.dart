// packages/renderer/lib/renderer.dart

import 'package:dust_component/component.dart';
import 'package:dust_component/stateful_component.dart';
import 'package:dust_component/state.dart';
import 'dart:js_interop'; // Still needed for JSFunction, JSAny etc. in callbacks for now
import 'package:dust_component/stateless_component.dart'; // Import StatelessWidget
import 'package:dust_component/vnode.dart'; // Import VNode
import 'dom_event.dart'; // Import DomEvent wrapper
import 'package:dust_dom/dom.dart' as dom; // Import the new DOM abstraction
import 'package:riverpod/riverpod.dart'; // Import Riverpod
import 'package:dust_component/context.dart'; // Import BuildContext
// --- Old JS Interop (To be removed) ---
// @JS('document.createElement') ... etc.
// extension JSAnyExtension on JSAny { ... }
// --- End Old JS Interop ---

// --- Simple Renderer State ---
// Store the state and target element for updates (very basic)
State? _mountedState;
dom.DomElement? _targetElement; // Use DomElement from dust_dom
VNode? _lastRenderedVNode; // Store the last rendered VNode tree
// --- End Simple Renderer State ---

// --- Global Provider Container (Temporary) ---
// This is a simplification for now. Ideally, this should be managed
// without a global variable, perhaps via context passed down the tree.
ProviderContainer? _appProviderContainer;
ProviderContainer get appProviderContainer {
  if (_appProviderContainer == null) {
    throw StateError('ProviderContainer not initialized. Call runApp first.');
  }
  return _appProviderContainer!;
}
// --- End Global Provider Container ---

/// Recursively creates a DOM element (or text node) from a VNode.
dom.DomNode _createDomElement(VNode vnode) {
  // Return DomNode (base for Element/Text)
  // 1. Handle Text Nodes
  if (vnode.tag == null) {
    // Assume it's a text node if tag is null
    // createTextNode is available in dust_dom
    final dom.DomNode domNode = dom.document
        .createTextNode(vnode.text ?? ''); // Pass Dart String directly
    vnode.domNode = domNode; // Store reference (now DomNode)
    return domNode;
  }

  // 2. Handle Element Nodes
  final dom.DomElement element = dom.createElement(vnode.tag!);

  // 3. Set Attributes
  if (vnode.attributes != null) {
    vnode.attributes!.forEach((name, value) {
      element.setAttribute(name, value); // Use DomElement extension
      print('Set attribute $name="$value" on <${vnode.tag}>');
    });
  }
// 4. Attach Event Listeners
  if (vnode.listeners != null) {
    vnode.listeners!.forEach((eventName, callback) {
      // Create a JS function that wraps the Dart callback and passes a DomEvent
      final jsFunction = ((JSAny jsEvent) {
        callback(DomEvent(jsEvent));
      }).toJS;
      // Use the addEventListener from DomElementExtension
      element.addEventListener(eventName, jsFunction);
      print('Added listener for "$eventName" on <${vnode.tag}>');
      // Store the JSFunction reference on the VNode for later removal
      (vnode.jsFunctionRefs ??= {})[eventName] = jsFunction;
      // Store the original Dart callback as well
      (vnode.dartCallbackRefs ??= {})[eventName] = callback;
    });
  }

// 5. Recursively Create and Append Children
  if (vnode.children != null) {
    if (vnode.tag == 'ul')
      print('>>> _createDomElement: Creating children for <ul>');
    for (final childVNode in vnode.children!) {
      print(
          '>>> _createDomElement: Creating child ${childVNode.tag ?? 'text'} (key: ${childVNode.key}) for parent <${vnode.tag}>');
      final dom.DomNode childNode =
          _createDomElement(childVNode); // Returns DomNode
      element.appendChild(childNode); // Use DomElement extension
    }
    if (vnode.tag == 'ul')
      print('>>> _createDomElement: Finished creating children for <ul>');
  } else if (vnode.text != null) {
    // Handle case where an element node might have direct text content specified
    // (though children is preferred for text content via text nodes)
    element.textContent = vnode.text; // Use DomElement extension
    print('Set textContent "${vnode.text}" on <${vnode.tag}>');
  }

  vnode.domNode = element; // Store reference (now DomElement)
  return element;
}

/// Performs the rendering or re-rendering by building the VNode and patching the DOM.
void _performRender(
    State componentState, dom.DomElement targetElement, BuildContext context) {
  // Use DomElement
  print('Performing render/update...');
  try {
    // 1. Build the new VNode tree
    final VNode newRootVNode = componentState.build();
    print('State build returned VNode: [${newRootVNode.tag ?? 'text'}]');

    // 2. Patch the DOM based on the new and old VNode trees
    _patch(targetElement, newRootVNode, _lastRenderedVNode,
        context); // Pass context

    // 3. Store the newly rendered VNode tree for the next comparison
    _lastRenderedVNode = newRootVNode;
  } catch (e, s) {
    print('Error during _performRender: $e\n$s');
    // Attempt to display error in the target element
    try {
      targetElement.textContent =
          'Render Error: $e'; // Use DomElement extension
    } catch (_) {
      // Ignore if setting textContent also fails
    }
  }
}

/// Patches the DOM to reflect the difference between the new and old VNode trees.
// Forward declaration for helper functions (implementation will be added later)
// Helper function to handle mounting a new component VNode
void _mountComponent(
    dom.DomElement parentElement, VNode componentVNode, BuildContext context) {
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
      final parent = (componentVNode.domNode as dom.DomNode).parentNode
          as dom.DomElement; // Cast before accessing parentNode
      final oldRenderedVNode = componentVNode.renderedVNode;

      print('  -> Re-building component...');
      final newRenderedVNode = state.build();
      print('  -> Patching new rendered tree against old...');
      _patch(parent, newRenderedVNode, oldRenderedVNode, context);

      // Update references on the component VNode
      componentVNode.renderedVNode = newRenderedVNode;
      // Assume the root DOM node reference might change if the rendered root type changes
      componentVNode.domNode =
          newRenderedVNode?.domNode ?? oldRenderedVNode?.domNode;
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

  // 5. Store rendered VNode on the component VNode
  componentVNode.renderedVNode = renderedVNode;

  // 6. Patch the DOM with the rendered VNode tree
  // Note: The parentElement for the *rendered* tree is the same parentElement
  // passed to _mountComponent. The component itself doesn't have a direct DOM node yet.
  // We pass null as oldVNode because this is the initial mount.
  if (renderedVNode != null) {
    print('  -> Patching rendered VNode into parent DOM...');
    _patch(parentElement, renderedVNode, null, context);
    // After patching, the renderedVNode will have its domNode set.
    // We need to associate this DOM node (or nodes if it renders a fragment)
    // with the componentVNode for future updates/unmounting.
    // For simplicity now, let's assume component renders a single root node.
    componentVNode.domNode = renderedVNode.domNode; // Simplification!
    print(
        '  -> Associated DOM node ${componentVNode.domNode?.hashCode} with component VNode');
  } else {
    print('  -> Component returned null VNode, nothing to patch.');
  }

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
    _mountComponent(parentElement, newComponentVNode, context);
    return;
  }

  // --- Types and Keys Match: Reuse existing state and update ---
  // Carry over the state object from the old VNode to the new one
  newComponentVNode.state = oldComponentVNode.state;
  // Carry over the DOM node reference as well (might be updated after patching rendered tree)
  newComponentVNode.domNode = oldComponentVNode.domNode;

  print(
      'Updating component: ${newComponent.runtimeType} with key ${newComponent.key}');

  VNode? newRenderedVNode;
  final oldRenderedVNode =
      oldComponentVNode.renderedVNode; // Get old rendered tree

  if (newComponent is StatefulWidget) {
    print('  -> StatefulWidget update');
    // 1. Get existing State object
    final state = oldComponentVNode.state;
    if (state == null) {
      print('Error: State object not found for StatefulWidget during update.');
      // Fallback: Treat as a new mount? This indicates a logic error.
      _unmountComponent(oldComponentVNode); // Clean up old if possible
      _mountComponent(parentElement, newComponentVNode, context);
      return;
    }

    // 2. Associate state with new VNode
    newComponentVNode.state = state;

    // 3. Update state's internal widget reference (triggers didUpdateWidget)
    state.frameworkUpdateWidget(newComponent);

    // 4. Build the new VNode tree
    newRenderedVNode = state.build();
    print(
        '  -> Updated build returned VNode: ${newRenderedVNode?.tag ?? newRenderedVNode?.component?.runtimeType ?? 'text'}');
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

  // 6. Patch the DOM by diffing the new rendered tree against the old one
  if (newRenderedVNode != null || oldRenderedVNode != null) {
    print('  -> Patching updated rendered VNode against old rendered VNode...');
    // The parentElement for the rendered tree is the same parentElement
    // passed to _updateComponent.
    _patch(parentElement, newRenderedVNode, oldRenderedVNode, context);
    // Carry over the DOM node reference from the potentially updated renderedVNode
    // This assumes the root DOM node of the rendered tree doesn't change type.
    newComponentVNode.domNode =
        newRenderedVNode?.domNode ?? oldRenderedVNode?.domNode;
    print(
        '  -> Updated component VNode DOM node association: ${newComponentVNode.domNode?.hashCode}');
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

  // 2. Recursively unmount the rendered VNode tree (if it exists)
  // This ensures listeners are removed and child components are disposed.
  final renderedVNode = componentVNode.renderedVNode;
  if (renderedVNode != null) {
    print('  -> Recursively unmounting rendered VNode tree...');
    // The componentVNode.domNode *should* point to the root DOM node rendered by the component.
    // However, due to simplification (line 225), this might be inaccurate if the
    // rendered root changed type or structure. Add checks.
    final domNode = componentVNode.domNode; // This is Object?

    // Check if domNode is a valid DomNode first
    if (domNode is dom.DomNode) {
      final parentNode = domNode.parentNode; // Now safe to access parentNode

      // Check if parentNode is a valid DomElement
      if (parentNode is dom.DomElement) {
        // Check if the node is still attached to the expected parent
        // This is not foolproof but adds a layer of safety.
        print('  -> Found valid DOM node and parent for removal.');
        final parentDomElement = parentNode; // Already checked type
        // Use removeVNode which handles recursive listener cleanup and DOM removal
        // Pass the verified parentDomElement.
        removeVNode(parentDomElement, renderedVNode);
      } else {
        // domNode exists but parent is not a DomElement (or null)
        print(
            'Warning: Could not find valid parent DOM element to remove rendered tree during unmount (domNode: ${domNode.hashCode}, parentNode: ${parentNode?.hashCode}).');
        print('  -> Attempting listener cleanup only.');
        _removeListenersRecursively(renderedVNode);
      }
    } else {
      // domNode itself is null or not a DomNode
      print(
          'Warning: domNode reference on componentVNode is invalid or null during unmount (domNode: ${domNode?.hashCode}).');
      print('  -> Attempting listener cleanup only.');
      _removeListenersRecursively(renderedVNode);
    }
    componentVNode.renderedVNode = null; // Clear the rendered VNode reference
  } else if (componentVNode.domNode != null) {
    // If renderedVNode is null but domNode exists (shouldn't happen often),
    // try to remove the domNode directly.
    print(
        'Warning: renderedVNode is null but domNode exists during unmount. Attempting direct DOM removal.');
    final domNode = componentVNode.domNode;
    if (domNode is dom.DomNode && domNode.parentNode is dom.DomElement) {
      final parentDomElement = domNode.parentNode as dom.DomElement;
      parentDomElement.removeChild(domNode);
    }
  }

  // 3. Clear the domNode reference on the componentVNode
  componentVNode.domNode = null;

  print('Finished unmounting component: ${component.runtimeType}');
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
    }
  }
}

// Helper to recursively remove listeners from a node and its children
void _removeListenersRecursively(VNode vnode) {
  // Remove listeners from the current node first
  _removeListenersFromNode(vnode);

  // Then, recursively remove from children
  if (vnode.children != null) {
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
    BuildContext context) {
  // Helper functions moved outside _patch
  print(
      'Patching: parent=${parentElement.hashCode}, new=[${newVNode?.tag ?? newVNode?.component?.runtimeType ?? newVNode?.text?.substring(0, min(5, newVNode.text?.length ?? 0)) ?? 'null'}], old=[${oldVNode?.tag ?? oldVNode?.component?.runtimeType ?? oldVNode?.text?.substring(0, min(5, oldVNode.text?.length ?? 0)) ?? 'null'}]');

  // --- Component Handling Logic ---
  final bool isNewComponent = newVNode?.component != null;
  final bool isOldComponent = oldVNode?.component != null;

  if (isNewComponent) {
    if (isOldComponent) {
      // Update existing component
      print('Updating component...');
      _updateComponent(parentElement, newVNode!, oldVNode!, context);
    } else {
      // Mount new component (replacing old element/text if necessary)
      print('Mounting new component...');
      if (oldVNode != null) {
        // Unmount old element/text node first
        removeVNode(parentElement, oldVNode); // Pass parentElement
      }
      _mountComponent(parentElement, newVNode!, context);
    }
    return; // Component logic handled, exit patch
  } else if (isOldComponent) {
    // Unmount old component (newVNode is element/text or null)
    print('Unmounting old component...');
    _unmountComponent(oldVNode!);
    if (newVNode != null) {
      // Mount new element/text node
      print('Mounting new element/text node after unmounting component...');
      final dom.DomNode newDomNode = _createDomElement(newVNode);
      parentElement.appendChild(newDomNode);
    }
    return; // Component logic handled, exit patch
  }

  // --- Non-Component Handling Logic (Elements and Text Nodes) ---
  // Only reach here if both newVNode and oldVNode are NOT components
  print('Handling non-component patch...');

  // Case 1: Old VNode exists, New VNode is null -> Remove the old DOM node
  if (newVNode == null) {
    if (oldVNode?.domNode != null) {
      print('Removing old DOM node: ${oldVNode!.domNode.hashCode}');
      // Ensure oldVNode.domNode is JSAny before calling removeChild
      if (oldVNode.domNode is JSAny) {
        // Use the removeChild from DomNodeExtension
        parentElement.removeChild(oldVNode.domNode as dom.DomNode);
      } else {
        print('Error: oldVNode.domNode is not JSAny');
      }
    } else {
      print('Old VNode or its DOM node is null, nothing to remove.');
    }
    return;
  }

  // Case 2: Old VNode is null, New VNode exists -> Create and append the new DOM node
  if (oldVNode == null) {
    print('Creating and appending new DOM node...');
    final dom.DomNode newDomNode =
        _createDomElement(newVNode); // Returns DomNode
    parentElement.appendChild(newDomNode); // Use DomElement extension
    return;
  }

  // Case 3: Both VNodes exist, but represent different types -> Replace
  // Different tags OR one is text and the other is element
  // Check for different types (element vs text) - Component vs non-component handled above
  bool differentTypes =
      oldVNode.tag != newVNode.tag; // Includes null comparison for text nodes
  if (differentTypes) {
    print('Replacing node due to different element/text types...');
    final dom.DomNode newDomNode =
        _createDomElement(newVNode); // Create new DOM node
    final Object? oldDomNodeObject = oldVNode.domNode;

    if (oldDomNodeObject is dom.DomNode) {
      // Use the replaceChild from DomNodeExtension
      parentElement.replaceChild(newDomNode, oldDomNodeObject);
      // Clean up listeners from the old node that was replaced
      _removeListenersRecursively(oldVNode);
    } else {
      // Fallback: If the old reference is invalid, just append the new node.
      print(
          'Warning/Error: Cannot replace node, old DOM node reference invalid. Appending new node.');
      parentElement.appendChild(newDomNode);
    }
    return;
  }

  // Case 4: Both VNodes exist and are of the same type

  // Ensure the domNode reference is carried over for patching
  // Assume it's DomNode if types match
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

  // Remove attributes that are in old but not in new
  oldAttributes.forEach((name, _) {
    if (!newAttributes.containsKey(name)) {
      print('Removing attribute $name from <${newVNode.tag}>');
      // Assume domNode is DomElement here since we are patching attributes
      (domNode as dom.DomElement).removeAttribute(name);
    }
  });

  // Add or update attributes that are in new
  newAttributes.forEach((name, value) {
    final oldValue = oldAttributes[name];
    if (oldValue != value) {
      print('Setting attribute $name="$value" on <${newVNode.tag}>');
      (domNode as dom.DomElement).setAttribute(name, value);
    }
  });

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
            '  -> Listener for "$eventName" removed via _patch (callback changed or event removed)');
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
    return vnode1?.key == vnode2?.key && vnode1?.tag == vnode2?.tag;
  }

  // Helper functions (_removeListenersFromNode, _removeListenersRecursively, removeVNode) moved outside _patchChildren

  dom.DomNode? getDomNodeBefore(int index) {
    // Return DomNode?
    // Helper to find the DOM node to insert before
    // FIX: Add null checks (!) since newCh is List<VNode?>
    if (index < newCh!.length) {
      // Check length first with !
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
          '>>> _patchChildren [Case 1: Same Start]: Patching key ${newStartVNode?.key}');
      _patch(
          parentDomNode, newStartVNode, oldStartVNode, context); // Pass context
      oldStartVNode = ++oldStartIdx <= oldEndIdx ? oldCh[oldStartIdx] : null;
      newStartVNode = ++newStartIdx <= newEndIdx ? newCh[newStartIdx] : null;
    } else if (isSameVNode(oldEndVNode, newEndVNode)) {
      // Same end nodes
      print(
          '>>> _patchChildren [Case 2: Same End]: Patching key ${newEndVNode?.key}');
      _patch(parentDomNode, newEndVNode, oldEndVNode, context); // Pass context
      oldEndVNode = --oldEndIdx >= oldStartIdx ? oldCh[oldEndIdx] : null;
      newEndVNode = --newEndIdx >= newStartIdx ? newCh[newEndIdx] : null;
    } else if (isSameVNode(oldStartVNode, newEndVNode)) {
      // Node moved right
      print(
          '>>> _patchChildren [Case 3: Moved Right]: Patching key ${newEndVNode?.key}, moving DOM node');
      _patch(
          parentDomNode, newEndVNode, oldStartVNode, context); // Pass context
      _domInsertBefore(
          // Use renamed helper
          oldStartVNode.domNode as dom.DomNode, // Pass DomNode
          getDomNodeBefore(newEndIdx + 1)); // Returns DomNode?
      oldStartVNode = ++oldStartIdx <= oldEndIdx ? oldCh[oldStartIdx] : null;
      newEndVNode = --newEndIdx >= newStartIdx ? newCh[newEndIdx] : null;
    } else if (isSameVNode(oldEndVNode, newStartVNode)) {
      // Node moved left
      print(
          '>>> _patchChildren [Case 4: Moved Left]: Patching key ${newStartVNode?.key}, moving DOM node');
      _patch(
          parentDomNode, newStartVNode, oldEndVNode, context); // Pass context
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
          newStartVNode?.key == null ? null : oldKeyToIdx[newStartVNode!.key!];

      if (idxInOld == null) {
        // New node, create and insert
        // New node, patch it into the DOM (oldVNode is null)
        print(
            '>>> _patchChildren [Case 5a: New Node]: Patching new node with key ${newStartVNode?.key}');
        // Call _patch recursively, which will handle mounting components or creating elements
        _patch(parentDomNode, newStartVNode, null, context);
        // Get the newly created/mounted DOM node from the VNode after patching
        final newDomNode = newStartVNode?.domNode;
        if (newDomNode is dom.DomNode) {
          _domInsertBefore(newDomNode, getDomNodeBefore(newStartIdx));
        } else {
          print('Error: New node patch did not result in a valid domNode.');
        }
      } else {
        // Found old node with same key, patch and move
        print(
            '>>> _patchChildren [Case 5b: Found Key]: Patching key ${newStartVNode?.key}, moving DOM node');
        final vnodeToMove = oldCh[idxInOld];
        if (vnodeToMove == null) {
          print(
              'Error: Found null VNode in oldChildren at index $idxInOld for key ${newStartVNode?.key}. This might indicate a duplicate key or logic error.');
        } else {
          _patch(parentDomNode, newStartVNode!, vnodeToMove,
              context); // Pass context
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
        final dom.DomNode newDomNode =
            _createDomElement(newCh[i]!); // Returns DomNode
        _domInsertBefore(newDomNode, referenceNode); // Pass DomNode, DomNode?
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

  // 2. Handle component type and initial build
  if (component is StatefulWidget) {
    print('Component is StatefulWidget, creating state...');
    // Create the state
    _mountedState = component.createState();

    // Set the update requester callback
    _mountedState!.setUpdateRequester(() {
      print('Update requested by state!');
      // When state requests update, re-run the render logic
      if (_mountedState != null && _targetElement != null) {
        // Pass context to _performRender
        _performRender(_mountedState!, _targetElement!, context);
      }
    });

    // Initialize the state (calls initState)
    // Assign context BEFORE calling initState (which happens inside frameworkUpdateWidget)
    _mountedState!.context = context;
    _mountedState!.frameworkUpdateWidget(component);

    // Perform the initial render using the state
    _performRender(_mountedState!, _targetElement!, context); // Pass context
  } else if (component is StatelessWidget) {
    print('Component is StatelessWidget, performing initial build...');
    // For stateless, we just build once and render (no updates handled yet)
    try {
      // Build the VNode tree
      // Build returns VNode?, handle potential null
      final VNode? newRootVNode = component.build(context);
      print(
          'Stateless build returned VNode: [${newRootVNode?.tag ?? 'null or text'}]'); // Add null check

      // Patch the DOM (initial render, so oldVNode is null)
      // TODO: How should context be handled for StatelessWidget?
      // For now, pass the parent context. A dedicated context might be needed if
      // stateless widgets need to access context directly (e.g., for theme).
      // Only patch if build returned a non-null VNode
      if (newRootVNode != null) {
        _patch(_targetElement!, newRootVNode, null, context); // Pass context
        // Store the initially rendered VNode tree
        // _lastRenderedVNode is now set inside the if/else block above
      } else {
        // Handle case where stateless build returns null (e.g., clear content)
        _targetElement!.textContent = ''; // Clear target element
        _lastRenderedVNode = null;
      }

      // Store the initially rendered VNode tree
      _lastRenderedVNode = newRootVNode;
    } catch (e, s) {
      print('Error during stateless render: $e\n$s');
      _targetElement!.textContent =
          'Render Error: $e'; // Use DomElement extension
    }
  } else {
    print('Error: Component type not supported by this basic renderer.');
    _targetElement!.textContent =
        'Error: Unsupported component type'; // Use DomElement extension
  }

  print('Initial render process finished.');
}

/// Public entry point for running a Dust application.
///
/// Mounts the given [rootComponent] into the DOM element with the specified
/// [targetElementId].
void runApp(Component rootComponent, String targetElementId) {
  print('Dust runApp starting...');

  // 1. Create the root ProviderContainer
  // Dispose previous container if exists (e.g., during hot restart in dev)
  _appProviderContainer?.dispose();
  final ProviderContainer container = ProviderContainer();
  _appProviderContainer =
      container; // Still store globally for now (needed by Consumer)
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
    _appProviderContainer?.dispose();
    _appProviderContainer = null;
    rethrow; // Rethrow the error after logging
  }
  // Note: Container disposal on app unmount is not handled yet.
  print('Dust runApp finished initial render call.');
}
