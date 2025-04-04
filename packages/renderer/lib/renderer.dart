// packages/renderer/lib/renderer.dart

import 'package:dust_component/component.dart';
import 'package:dust_component/stateful_component.dart';
import 'package:dust_component/state.dart';
import 'dart:js_interop'; // Import JSAny, JSString, JSFunction, JS, allowInterop etc.
// import 'dart:js_interop_unsafe'; // No longer needed? .toJS is on Function via js_interop
import 'package:dust_component/stateless_component.dart'; // Import StatelessWidget
import 'package:dust_component/vnode.dart'; // Import VNode

// --- JS Interop ---
@JS('document.createElement')
external JSAny _createElement(JSString tagName);

@JS('document.createTextNode') // Added for text nodes
external JSAny _createTextNode(JSString data);

@JS('document.getElementById')
external JSAny? _getElementById(JSString id);

extension JSAnyExtension on JSAny {
  external set textContent(JSString text);
  external void appendChild(JSAny child);
  // Needed to clear content before update
  external set innerHTML(JSString html);
  external void setAttribute(
      JSString name, JSString value); // Added for attributes
  external void removeChild(JSAny child); // Added for removing nodes
  external void replaceChild(
      JSAny newChild, JSAny oldChild); // Added for replacing nodes
  external JSAny?
      get parentNode; // Added to access parent for removal/replacement
  external void removeAttribute(JSString name); // Added for removing attributes
  external void insertBefore(
      JSAny newNode, JSAny? referenceNode); // Added for inserting nodes
  external JSString get tagName; // Added for getting element tag name
  external void addEventListener(
      JSString type, JSFunction listener); // Added for events
  external void removeEventListener(
      JSString type, JSFunction listener); // Added for events
}
// --- End JS Interop ---

// --- Simple Renderer State ---
// Store the state and target element for updates (very basic)
State? _mountedState;
JSAny? _targetElement;
VNode? _lastRenderedVNode; // Store the last rendered VNode tree
// --- End Simple Renderer State ---

/// Recursively creates a DOM element (or text node) from a VNode.
JSAny _createDomElement(VNode vnode) {
  // 1. Handle Text Nodes
  if (vnode.tag == null) {
    // Assume it's a text node if tag is null
    final JSAny domNode = _createTextNode((vnode.text ?? '').toJS);
    vnode.domNode = domNode; // Store reference
    return domNode;
  }

  // 2. Handle Element Nodes
  final JSAny element = _createElement(vnode.tag!.toJS);

  // 3. Set Attributes
  if (vnode.attributes != null) {
    vnode.attributes!.forEach((name, value) {
      element.setAttribute(name.toJS, value.toJS);
      print('Set attribute $name="$value" on <${vnode.tag}>');
    });
  }
// 4. Attach Event Listeners
  if (vnode.listeners != null) {
    vnode.listeners!.forEach((eventName, callback) {
      // Convert the Dart callback directly to a JSFunction using the .toJS extension
      final jsFunction = callback.toJS;
      element.addEventListener(eventName.toJS, jsFunction);
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
      final JSAny childElement = _createDomElement(childVNode);
      element.appendChild(childElement);
    }
    if (vnode.tag == 'ul')
      print('>>> _createDomElement: Finished creating children for <ul>');
  } else if (vnode.text != null) {
    // Handle case where an element node might have direct text content specified
    // (though children is preferred for text content via text nodes)
    element.textContent = vnode.text!.toJS;
    print('Set textContent "${vnode.text}" on <${vnode.tag}>');
  }

  vnode.domNode = element; // Store reference
  return element;
}

/// Performs the rendering or re-rendering by building the VNode and patching the DOM.
void _performRender(State componentState, JSAny targetElement) {
  print('Performing render/update...');
  try {
    // 1. Build the new VNode tree
    final VNode newRootVNode = componentState.build();
    print('State build returned VNode: [${newRootVNode.tag ?? 'text'}]');

    // 2. Patch the DOM based on the new and old VNode trees
    _patch(targetElement, newRootVNode, _lastRenderedVNode);

    // 3. Store the newly rendered VNode tree for the next comparison
    _lastRenderedVNode = newRootVNode;
  } catch (e, s) {
    print('Error during _performRender: $e\n$s');
    // Attempt to display error in the target element
    try {
      targetElement.textContent = 'Render Error: $e'.toJS;
    } catch (_) {
      // Ignore if setting textContent also fails
    }
  }
}

/// Patches the DOM to reflect the difference between the new and old VNode trees.
void _patch(JSAny parentElement, VNode? newVNode, VNode? oldVNode) {
  print(
      'Patching: parent=${parentElement.hashCode}, new=[${newVNode?.tag ?? newVNode?.text?.substring(0, min(5, newVNode.text?.length ?? 0)) ?? 'null'}], old=[${oldVNode?.tag ?? oldVNode?.text?.substring(0, min(5, oldVNode.text?.length ?? 0)) ?? 'null'}]');

  // Case 1: Old VNode exists, New VNode is null -> Remove the old DOM node
  if (newVNode == null) {
    if (oldVNode?.domNode != null) {
      print('Removing old DOM node: ${oldVNode!.domNode.hashCode}');
      // Ensure oldVNode.domNode is JSAny before calling removeChild
      if (oldVNode.domNode is JSAny) {
        parentElement.removeChild(oldVNode.domNode as JSAny);
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
    final JSAny newDomNode = _createDomElement(newVNode);
    parentElement.appendChild(newDomNode);
    return;
  }

  // Case 3: Both VNodes exist, but represent different types -> Replace
  // Different tags OR one is text and the other is element
  bool differentTypes =
      oldVNode.tag != newVNode.tag; // Includes null comparison for text nodes
  if (differentTypes) {
    print('Replacing node due to different types/tags...');
    final JSAny newDomNode = _createDomElement(newVNode);
    final Object? oldDomNodeObject = oldVNode.domNode;

    // Try to replace if the old DOM node reference is valid JSAny
    if (oldDomNodeObject is JSAny) {
      parentElement.replaceChild(newDomNode, oldDomNodeObject);
    } else {
      // Fallback: If the reference is lost or invalid, just append the new node.
      // This relies on the parentElement potentially being cleared beforehand
      // or handles cases where the old node wasn't properly tracked.
      print(
          'Warning/Error: Cannot replace node, old DOM node reference invalid or not JSAny. Appending new node.');
      parentElement.appendChild(newDomNode);
    }
    return;
  }

  // Case 4: Both VNodes exist and are of the same type

  // Ensure the domNode reference is carried over for patching
  final JSAny domNode =
      oldVNode.domNode as JSAny; // Assume it's JSAny if types match
  newVNode.domNode = domNode; // Carry over the DOM node reference

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
      domNode.textContent = (newVNode.text ?? '').toJS;
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
      domNode.removeAttribute(name.toJS);
    }
  });

  // Add or update attributes that are in new
  newAttributes.forEach((name, value) {
    final oldValue = oldAttributes[name];
    if (oldValue != value) {
      print('Setting attribute $name="$value" on <${newVNode.tag}>');
      domNode.setAttribute(name.toJS, value.toJS);
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
        domNode.removeEventListener(eventName.toJS, oldJsFunction);
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
    // Only add/update if the callback function instance has changed
    // or if it's a new listener.
    if (!oldListeners.containsKey(eventName) || oldCallback != newCallback) {
      print('Adding/Updating listener for "$eventName" on <${newVNode.tag}>');

      // Remove the old listener if it exists and we have its reference
      final oldJsFunction = oldVNode.jsFunctionRefs?[eventName];
      if (oldJsFunction != null) {
        print('  -> Removing old listener first');
        domNode.removeEventListener(eventName.toJS, oldJsFunction);
      }

      // Add the new listener
      final newJsFunction = newCallback.toJS;
      domNode.addEventListener(eventName.toJS, newJsFunction);

      // Store the new reference
      (newVNode.jsFunctionRefs ??= {})[eventName] = newJsFunction;
    }
    // If oldCallback == newCallback, assume the listener is the same and do nothing.
  });

  // 4d: Patch Children (Keyed Reconciliation)
  _patchChildren(domNode, oldVNode.children, newVNode.children);

  print('Finished patching children for <${newVNode.tag}>.');
}

// Helper function for min to avoid import 'dart:math' just for this
int min(int a, int b) => a < b ? a : b;

/// Patches the children of a DOM element using a keyed reconciliation algorithm.
/// Based on common algorithms found in frameworks like Vue and Inferno.
void _patchChildren(JSAny parentDomNode, List<VNode>? oldChOriginal,
    List<VNode>? newChOriginal) {
  // Work with copies that allow nulls for marking moved nodes
  List<VNode?> oldCh = oldChOriginal?.map((e) => e as VNode?).toList() ?? [];
  List<VNode?> newCh = newChOriginal?.map((e) => e as VNode?).toList() ?? [];

  // Use the new tagName getter from JSAnyExtension
  final parentTag = (parentDomNode as JSAny).tagName.toDart;
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

  void removeVNode(VNode vnode) {
    if (vnode.domNode != null) {
      print('Removing DOM node (key: ${vnode.key}): ${vnode.domNode.hashCode}');
      if (vnode.domNode is JSAny) {
        // FIX: Use parentDomNode
        parentDomNode.removeChild(vnode.domNode as JSAny);
      } else {
        print('Error: Cannot remove, vnode.domNode is not JSAny');
      }
      // TODO: Call component lifecycle hooks (dispose) if applicable
    }
  }

  JSAny? getDomNodeBefore(int index) {
    // Helper to find the DOM node to insert before
    // FIX: Add null checks (!) since newCh is List<VNode?>
    if (index < newCh!.length) {
      // Check length first with !
      final nextVNode = newCh[index]; // Access element
      if (nextVNode != null && nextVNode.domNode is JSAny) {
        // Check if VNode and its domNode are valid
        return nextVNode.domNode as JSAny;
      }
    }
    return null; // Insert at the end
  }

  // Renamed helper to avoid potential conflicts and clarify purpose
  void _domInsertBefore(JSAny newNode, JSAny? referenceNode) {
    // FIX: Use the extension method directly
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
      _patch(parentDomNode, newStartVNode, oldStartVNode);
      oldStartVNode = ++oldStartIdx <= oldEndIdx ? oldCh[oldStartIdx] : null;
      newStartVNode = ++newStartIdx <= newEndIdx ? newCh[newStartIdx] : null;
    } else if (isSameVNode(oldEndVNode, newEndVNode)) {
      // Same end nodes
      print(
          '>>> _patchChildren [Case 2: Same End]: Patching key ${newEndVNode?.key}');
      _patch(parentDomNode, newEndVNode, oldEndVNode);
      oldEndVNode = --oldEndIdx >= oldStartIdx ? oldCh[oldEndIdx] : null;
      newEndVNode = --newEndIdx >= newStartIdx ? newCh[newEndIdx] : null;
    } else if (isSameVNode(oldStartVNode, newEndVNode)) {
      // Node moved right
      print(
          '>>> _patchChildren [Case 3: Moved Right]: Patching key ${newEndVNode?.key}, moving DOM node');
      _patch(parentDomNode, newEndVNode, oldStartVNode);
      _domInsertBefore(
          // Use renamed helper
          oldStartVNode.domNode as JSAny,
          getDomNodeBefore(newEndIdx + 1));
      oldStartVNode = ++oldStartIdx <= oldEndIdx ? oldCh[oldStartIdx] : null;
      newEndVNode = --newEndIdx >= newStartIdx ? newCh[newEndIdx] : null;
    } else if (isSameVNode(oldEndVNode, newStartVNode)) {
      // Node moved left
      print(
          '>>> _patchChildren [Case 4: Moved Left]: Patching key ${newStartVNode?.key}, moving DOM node');
      _patch(parentDomNode, newStartVNode, oldEndVNode);
      _domInsertBefore(
          // Use renamed helper
          oldEndVNode.domNode as JSAny,
          getDomNodeBefore(
              newStartIdx)); // Insert before the current newStartVNode's eventual position
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
        final JSAny newDomNode = _createDomElement(
            newStartVNode!); // Assume newStartVNode is not null here
        _domInsertBefore(
            newDomNode, getDomNodeBefore(newStartIdx)); // Use renamed helper
      } else {
        // Found old node with same key, patch and move
        print(
            '>>> _patchChildren [Case 5b: Found Key]: Patching key ${newStartVNode?.key}, moving DOM node');
        final vnodeToMove = oldCh[idxInOld];
        if (vnodeToMove == null) {
          print(
              'Error: Found null VNode in oldChildren at index $idxInOld for key ${newStartVNode?.key}. This might indicate a duplicate key or logic error.');
        } else {
          _patch(parentDomNode, newStartVNode!, vnodeToMove);
          _domInsertBefore(
              // Use renamed helper
              vnodeToMove.domNode as JSAny,
              getDomNodeBefore(newStartIdx));
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
    final JSAny? referenceNode =
        getDomNodeBefore(newEndIdx + 1); // Find node after the last new node
    for (int i = newStartIdx; i <= newEndIdx; i++) {
      // Only add nodes that aren't null (shouldn't happen with newCh, but safe)
      if (newCh[i] != null) {
        final JSAny newDomNode =
            _createDomElement(newCh[i]!); // Not null checked above
        _domInsertBefore(newDomNode, referenceNode); // Use renamed helper
      }
    }
  }
  print('>>> _patchChildren END for parent <$parentTag>');
}

/// Renders a component into a target DOM element for the first time.
void render(Component component, String targetElementId) {
  print(
    'Starting initial render process for component $component into #$targetElementId',
  );

  // 1. Get the target DOM element
  _targetElement = _getElementById(targetElementId.toJS);
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
        _performRender(_mountedState!, _targetElement!);
      }
    });

    // Initialize the state (calls initState)
    _mountedState!.frameworkUpdateWidget(component);

    // Perform the initial render using the state
    _performRender(_mountedState!, _targetElement!);
  } else if (component is StatelessWidget) {
    print('Component is StatelessWidget, performing initial build...');
    // For stateless, we just build once and render (no updates handled yet)
    try {
      // Build the VNode tree
      final VNode newRootVNode = component.build();
      print('Stateless build returned VNode: [${newRootVNode.tag ?? 'text'}]');

      // Patch the DOM (initial render, so oldVNode is null)
      _patch(_targetElement!, newRootVNode, null); // Pass null for oldVNode

      // Store the initially rendered VNode tree
      _lastRenderedVNode = newRootVNode;
    } catch (e, s) {
      print('Error during stateless render: $e\n$s');
      _targetElement!.textContent = 'Render Error: $e'.toJS;
    }
  } else {
    print('Error: Component type not supported by this basic renderer.');
    _targetElement!.textContent = 'Error: Unsupported component type'.toJS;
  }

  print('Initial render process finished.');
}
