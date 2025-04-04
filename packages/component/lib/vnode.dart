import 'dart:js_interop'; // Needed for JSAny in listener type

/// Represents a node in the Virtual DOM tree.
class VNode {
  /// The HTML tag name for element nodes (e.g., 'div', 'span').
  /// Null for text nodes.
  final String? tag;

  /// The attributes/properties of the element (e.g., {'id': 'my-id', 'class': 'container'}).
  final Map<String, String>? attributes;

  /// Event listeners attached to the element (e.g., {'click': (JSAny event) => print('Clicked!')}).
  /// The callback function will receive the DOM event object (likely JSAny?).
  final Map<String, void Function(JSAny event)>?
      listeners; // Use specific function type

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
  Map<String, JSFunction>?
      jsFunctionRefs; // Public map to store JSFunction references for listeners

  /// Creates an element VNode.
  VNode.element(this.tag,
      {this.key, this.attributes, this.listeners, this.children})
      : text = null,
        domNode = null,
        jsFunctionRefs = null; // Initialize map

  /// Creates a text VNode. Text nodes typically don't need keys.
  VNode.text(this.text)
      : tag = null,
        key = null, // Text nodes usually don't have keys
        attributes = null,
        listeners = null, // Text nodes don't have listeners
        children = null,
        domNode = null,
        jsFunctionRefs = null; // Initialize map

  // Potential future additions:
  // - Reference to the actual DOM element (domNode exists)
  // - Component instance association
}
