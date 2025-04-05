import 'dart:js_interop'; // Needed for JSFunction and potentially JSAny
import 'package:dust_renderer/dom_event.dart'; // Import using package dependency
import 'component.dart'; // Import Component base class
import 'state.dart'; // Import State base class

/// Represents a node in the Virtual DOM tree.
class VNode {
  /// The HTML tag name for element nodes (e.g., 'div', 'span').
  /// Null for text nodes.
  final String? tag;

  /// The attributes/properties of the element (e.g., {'id': 'my-id', 'class': 'container'}).
  final Map<String, String>? attributes;

  /// Event listeners attached to the element (e.g., {'click': (JSAny event) => print('Clicked!')}).
  /// The callback function will receive the DOM event object (likely JSAny?).
  final Map<String, void Function(DomEvent event)>?
      listeners; // Use DomEvent wrapper

  /// The child nodes of this element.
  final List<VNode>? children;

  /// The text content for text nodes.
  /// Null for element nodes.
  final String? text;

  /// An optional key used by the diffing algorithm to identify nodes across updates.
  /// Crucial for efficient list reconciliation.
  final Object? key;

  /// A reference to the actual DOM node associated with this VNode.
  /// This is populated by the renderer during the creation/patching process.
  /// Using JSAny? from dart:js_interop (implicitly, as it's used by the renderer).
  Object? domNode; // Use Object? for flexibility, renderer will handle JSAny?
  /// For component VNodes using anchor nodes, this stores the end anchor.
  Object? endNode; // Use Object? for flexibility, renderer will handle JSAny?
  Map<String, JSFunction>?
      jsFunctionRefs; // Stores JSFunction references for removal
  Map<String, Function>?
      dartCallbackRefs; // Stores original Dart callbacks for comparison

  /// For VNodes representing a Component, this holds the component instance.
  /// Null for element and text nodes.
  final Component? component;

  /// For VNodes representing a StatefulWidget, this holds the associated State instance.
  /// Null otherwise. Managed by the renderer.
  State? state;

  /// For VNodes representing a Component, this holds the VNode tree rendered by that component.
  /// Null otherwise. Managed by the renderer.
  VNode? renderedVNode;

  /// Creates an element VNode.
  VNode.element(this.tag,
      {this.key, this.attributes, this.listeners, this.children})
      : text = null,
        component = null, // Not a component node
        domNode = null,
        endNode = null, // Initialize endNode
        jsFunctionRefs = null,
        dartCallbackRefs = null, // Initialize new field
        state = null, // Not a stateful component node
        renderedVNode = null; // Not a component node

  /// Creates a text VNode. Text nodes typically don't need keys.
  VNode.text(this.text)
      : tag = null,
        key = null, // Text nodes usually don't have keys
        attributes = null,
        listeners = null, // Text nodes don't have listeners
        children = null,
        component = null, // Not a component node
        domNode = null,
        endNode = null, // Initialize endNode
        jsFunctionRefs = null,
        dartCallbackRefs = null, // Initialize new field
        state = null, // Not a stateful component node
        renderedVNode = null; // Not a component node

  /// Creates a VNode representing a Component.
  /// The key is typically taken from the component itself.
  VNode.component(this.component)
      : tag = null, // Not a direct element or text node
        key = component?.key, // Use component's key
        attributes = null,
        listeners = null,
        children = null,
        text = null,
        domNode =
            null, // Will be managed by the component's rendered output (or start anchor)
        endNode =
            null, // Initialize endNode (will be end anchor for components)
        jsFunctionRefs = null,
        dartCallbackRefs = null, // Initialize new field
        state =
            null, // Will be set by the renderer during mount if StatefulWidget
        renderedVNode = null; // Will be set by the renderer during mount/update

  // Potential future additions:
  // - Reference to the actual DOM element (domNode exists)
  // - Component instance association (component exists)
  // - Associated State instance (state exists)
  // - Rendered VNode tree from component (renderedVNode exists)
}
