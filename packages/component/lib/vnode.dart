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

  /// Creates an element VNode.
  VNode.element(this.tag, {this.attributes, this.children}) : text = null;

  /// Creates a text VNode.
  VNode.text(this.text)
      : tag = null,
        attributes = null,
        children = null;

  // Potential future additions:
  // - Key for diffing optimization
  // - Reference to the actual DOM element
  // - Component instance association
}
