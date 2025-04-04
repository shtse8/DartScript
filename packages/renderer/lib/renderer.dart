// packages/renderer/lib/renderer.dart

import 'package:dust_component/component.dart';
import 'package:dust_component/stateful_component.dart';
import 'package:dust_component/state.dart';
import 'dart:js_interop';
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

  // 4. Recursively Create and Append Children
  if (vnode.children != null) {
    for (final childVNode in vnode.children!) {
      final JSAny childElement = _createDomElement(childVNode);
      element.appendChild(childElement);
    }
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

// Removed incorrect comment block left by previous partial diff apply.
/// Patches the DOM to reflect the difference between the new and old VNode trees.
///
/// Patches the DOM to reflect the difference between the new and old VNode trees.
void _patch(JSAny parentElement, VNode? newVNode, VNode? oldVNode) {
  print(
      'Patching: parent=${parentElement.hashCode}, new=[${newVNode?.tag ?? newVNode?.text?.substring(0, 5) ?? 'null'}], old=[${oldVNode?.tag ?? oldVNode?.text?.substring(0, 5) ?? 'null'}]');

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
  newVNode.domNode = domNode; // Carry over the reference

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

  // 4c: Patch Children (Recursive Step)
  final oldChildren = oldVNode.children ?? [];
  final newChildren = newVNode.children ?? [];
  final oldLength = oldChildren.length;
  final newLength = newChildren.length;
  final commonLength = oldLength < newLength ? oldLength : newLength;

  print(
      'Patching children for <${newVNode.tag}>: old=${oldLength}, new=${newLength}');

  // Patch common children
  for (int i = 0; i < commonLength; i++) {
    _patch(domNode, newChildren[i], oldChildren[i]);
  }

  // Add new children if new list is longer
  if (newLength > oldLength) {
    print('Adding ${newLength - oldLength} new children...');
    for (int i = oldLength; i < newLength; i++) {
      // Since there's no corresponding old child, pass null for oldVNode
      _patch(domNode, newChildren[i], null);
    }
  }
  // Remove old children if old list is longer
  else if (oldLength > newLength) {
    print('Removing ${oldLength - newLength} old children...');
    for (int i = newLength; i < oldLength; i++) {
      // Since there's no corresponding new child, pass null for newVNode
      _patch(domNode, null, oldChildren[i]);
    }
  }

  print('Finished patching children for <${newVNode.tag}>.');
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
      final representation = component.build();
      print('Stateless build returned: $representation');
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
