/// Represents a node in the Virtual DOM tree.
class VNode {
  /// The HTML tag name for element nodes (e.g., 'div', 'span').
  /// Null for text nodes.
  final String? tag;

  /// The attributes/properties of the element (e.g., {'id': 'my-id', 'class': 'container'}).
  final Map<String, String>? attributes;

  /// The child nodes of this element.
  final List<VNode>? children;

  /// The text content for text nodes.
  /// Null for element nodes.
  final String? text;

  /// A reference to the actual DOM node associated with this VNode.
  /// This is populated by the renderer during the creation/patching process.
  /// Using JSAny? from dart:js_interop (implicitly, as it's used by the renderer).
  Object? domNode; // Use Object? for flexibility, renderer will handle JSAny?

  /// Creates an element VNode.
  VNode.element(this.tag, {this.attributes, this.children})
      : text = null,
        domNode = null; // Initialize domNode

  /// Creates a text VNode.
  VNode.text(this.text)
      : tag = null,
        attributes = null,
        children = null,
        domNode = null; // Initialize domNode

  // Potential future additions:
  // - Key for diffing optimization
  // - Reference to the actual DOM element
  // - Component instance association
}
