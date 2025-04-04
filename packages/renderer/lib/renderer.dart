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
    // TODO: Add createTextNode to dom.dart
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
void _patch(dom.DomElement parentElement, VNode? newVNode, VNode? oldVNode,
    BuildContext context) {
  // Use DomElement
  print(
      'Patching: parent=${parentElement.hashCode}, new=[${newVNode?.tag ?? newVNode?.text?.substring(0, min(5, newVNode.text?.length ?? 0)) ?? 'null'}], old=[${oldVNode?.tag ?? oldVNode?.text?.substring(0, min(5, oldVNode.text?.length ?? 0)) ?? 'null'}]');

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
  bool differentTypes =
      oldVNode.tag != newVNode.tag; // Includes null comparison for text nodes
  if (differentTypes) {
    print('Replacing node due to different types/tags...');
    final dom.DomNode newDomNode =
        _createDomElement(newVNode); // Returns DomNode
    final Object? oldDomNodeObject = oldVNode.domNode;

    // Try to replace if the old DOM node reference is valid JSAny
    if (oldDomNodeObject is JSAny) {
      // Use the replaceChild from DomNodeExtension
      parentElement.replaceChild(newDomNode, oldDomNodeObject as dom.DomNode);
    } else {
      // Fallback: If the reference is lost or invalid, just append the new node.
      // This relies on the parentElement potentially being cleared beforehand
      // or handles cases where the old node wasn't properly tracked.
      print(
          'Warning/Error: Cannot replace node, old DOM node reference invalid or not JSAny. Appending new node.');
      parentElement.appendChild(newDomNode); // Use DomElement extension
    }
    return;
  }

  // Case 4: Both VNodes exist and are of the same type

  // Ensure the domNode reference is carried over for patching
  // Assume it's DomNode if types match
  final dom.DomNode domNode = oldVNode.domNode as dom.DomNode;
  newVNode.domNode = domNode; // Carry over the DOM node reference (DomNode)

  // Carry over the JSFunction references from the old VNode to the new one
  // so we can potentially remove old listeners later.
  if (oldVNode.jsFunctionRefs != null) {
    newVNode.jsFunctionRefs = Map.from(oldVNode.jsFunctionRefs!);
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
        newVNode.jsFunctionRefs
            ?.remove(eventName); // Remove from new VNode's refs too
      } else {
        print(
            'Warning: Could not remove listener for "$eventName" on <${newVNode.tag}> - JSFunction reference not found.');
      }
    }
  });

  // Add or update listeners that are in new
  newListeners.forEach((eventName, newCallback) {
    final oldCallback = oldListeners[eventName];
    // If the listener exists in the new VNode, ensure it's correctly attached.
    // Always remove the old one (if found) and add the new one to handle
    // cases where callback instances change (e.g., inline functions).
    if (newListeners.containsKey(eventName)) {
      print('Ensuring listener for "$eventName" on <${newVNode.tag}>');

      // Remove the old listener if it exists and we have its reference
      final oldJsFunction = oldVNode.jsFunctionRefs?[eventName];
      if (oldJsFunction != null) {
        // Only remove if the callback function itself has actually changed,
        // otherwise, we might remove a listener we intend to keep if the
        // instance is the same (e.g., a method reference).
        // However, always removing/adding is safer for inline functions.
        // Let's stick to always removing/adding for simplicity and robustness.
        print('  -> Removing old listener first (if found)');
        // Use the removeEventListener from DomElementExtension
        (domNode as dom.DomElement)
            .removeEventListener(eventName, oldJsFunction);
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

      // Store the new reference, overwriting any old one
      (newVNode.jsFunctionRefs ??= {})[eventName] = newJsFunction;
    }
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

  // Helper to remove listeners from a single node
  void _removeListenersFromNode(VNode vnode) {
    if (vnode.domNode is dom.DomElement && vnode.jsFunctionRefs != null) {
      final domElement = vnode.domNode as dom.DomElement;
      if (vnode.jsFunctionRefs!.isNotEmpty) {
        print(
            '  -> Removing ${vnode.jsFunctionRefs!.length} listeners for node key ${vnode.key}');
        vnode.jsFunctionRefs!.forEach((eventName, jsFunction) {
          print('     - Removing listener for "$eventName"');
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

  void removeVNode(VNode vnode) {
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
      parentDomNode.removeChild(vnode.domNode as dom.DomNode);
    } else {
      // This case should ideally not happen if domNode was set correctly
      print('Error: Cannot remove, vnode.domNode is not a valid DomNode type.');
    }
    // TODO: Call component lifecycle hooks (dispose) if applicable
  }

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
        print(
            '>>> _patchChildren [Case 5a: New Node]: Creating key ${newStartVNode?.key}');
        final dom.DomNode newDomNode =
            _createDomElement(newStartVNode!); // Returns DomNode
        _domInsertBefore(newDomNode,
            getDomNodeBefore(newStartIdx)); // Pass DomNode, returns DomNode?
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
        removeVNode(oldCh[i]!); // Not null checked above
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
      final VNode newRootVNode = component.build();
      print('Stateless build returned VNode: [${newRootVNode.tag ?? 'text'}]');

      // Patch the DOM (initial render, so oldVNode is null)
      // TODO: How should context be handled for StatelessWidget?
      // For now, pass the parent context. A dedicated context might be needed if
      // stateless widgets need to access context directly (e.g., for theme).
      _patch(_targetElement!, newRootVNode, null, context); // Pass context

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
