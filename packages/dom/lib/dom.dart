/// Base library for the Dust DOM abstraction layer.
library dust_dom;

import 'dart:js_interop'; // Required for JS types

//------------------------------------------------------------------------------
// DomNode Abstraction (Base for Element, Text, etc.)
//------------------------------------------------------------------------------

/// Base class for DOM nodes using static interop.
@JS('Node')
@staticInterop
class DomNode {}

extension DomNodeExtension on DomNode {
  /// Gets or sets the text content of the node and its descendants.
  @JS('textContent')
  external String? get textContent;
  @JS('textContent')
  external set textContent(String? text);

  /// Appends a child node to this node.
  @JS('appendChild')
  external void appendChild(DomNode child);

  /// Removes a child node from this node.
  @JS('removeChild')
  external void removeChild(DomNode child);

  /// Replaces a child node with another one.
  @JS('replaceChild')
  external void replaceChild(DomNode newChild, DomNode oldChild);

  /// Inserts a node before a reference node. If referenceNode is null, inserts at the end.
  @JS('insertBefore')
  external void insertBefore(DomNode newNode, DomNode? referenceNode);

  /// Gets the parent element of this node. Returns null if there's no parent element.
  @JS('parentElement')
  external DomElement? get parentElement;

  /// Gets the parent node of this node. Returns null if there's no parent.
  @JS('parentNode')
  external DomNode? get parentNode;

  /// Gets the next sibling node. Returns null if there is no next sibling.
  @JS('nextSibling')
  external DomNode? get nextNode; // Renamed to nextNode for clarity
}

//------------------------------------------------------------------------------
// DomElement Abstraction
//------------------------------------------------------------------------------

/// Represents a DOM element within the Dust framework using static interop.
/// Extends [DomNode].
@JS('Element')
@staticInterop
class DomElement extends DomNode {}

/// Extension methods for [DomElement] to provide Dart-like APIs.
extension DomElementExtension on DomElement {
  // --- Basic Properties ---

  /// Gets or sets the inner HTML of the element.
  @JS('innerHTML')
  external String get innerHTML;
  @JS('innerHTML')
  external set innerHTML(String html);

  // textContent is inherited from DomNodeExtension

  /// Gets the tag name of the element (e.g., 'DIV', 'SPAN').
  @JS('tagName')
  external String get tagName;

  // --- Attributes ---

  /// Sets an attribute on the element.
  @JS('setAttribute')
  external void setAttribute(String name, String value);

  /// Gets the value of an attribute. Returns null if the attribute doesn't exist.
  @JS('getAttribute')
  external String? getAttribute(String name);

  /// Removes an attribute from the element.
  @JS('removeAttribute')
  external void removeAttribute(String name);

  /// Checks if the element has a specific attribute.
  @JS('hasAttribute')
  external bool hasAttribute(String name);

  // --- Children & Hierarchy ---
  // appendChild, removeChild, replaceChild, insertBefore, parentElement inherited from DomNodeExtension

  // --- Styling (Basic Example) ---
  // TODO: Create a dedicated DomStyle class

  /// Accesses the style object of the element.
  @JS('style')
  external DomStyle get style; // Returns a DomStyle object (defined below)

  // --- Event Handling ---
  /// Adds an event listener to the element.
  @JS('addEventListener')
  external void addEventListener(String type, JSFunction listener,
      [JSAny? options]);

  /// Removes an event listener from the element.
  @JS('removeEventListener')
  external void removeEventListener(String type, JSFunction listener,
      [JSAny? options]);
}

//------------------------------------------------------------------------------
// DomTextNode Abstraction
//------------------------------------------------------------------------------

/// Represents a Text node in the DOM using static interop.
/// Extends [DomNode].
@JS('Text')
@staticInterop
class DomTextNode extends DomNode {}

// Add extensions for DomTextNode if specific properties/methods are needed,
// e.g., 'data' which is often synonymous with textContent for text nodes.
// extension DomTextNodeExtension on DomTextNode {
//   @JS('data')
//   external String get data;
//   @JS('data')
//   external set data(String value);
// }

//------------------------------------------------------------------------------
// DomComment Abstraction
//------------------------------------------------------------------------------

/// Represents a Comment node in the DOM using static interop.
/// Extends [DomNode].
@JS('Comment')
@staticInterop
class DomComment extends DomNode {}

// No specific extensions needed for Comment for now, inherits from DomNodeExtension.

//------------------------------------------------------------------------------
// DomStyle Abstraction (Example)
//------------------------------------------------------------------------------

/// Represents the CSSStyleDeclaration object using static interop.
@JS() // No specific class name needed, inferred by usage context (style property)
@staticInterop
class DomStyle {}

extension DomStyleExtension on DomStyle {
  /// Sets a CSS property.
  @JS('setProperty')
  external void setProperty(String propertyName, String value,
      [String? priority]);

  /// Gets a CSS property value.
  @JS('getPropertyValue')
  external String getPropertyValue(String propertyName);

  /// Removes a CSS property.
  @JS('removeProperty')
  external String removeProperty(String propertyName); // Returns the old value
}

//------------------------------------------------------------------------------
// Document Abstraction & Global Functions
//------------------------------------------------------------------------------

/// Represents the global `document` object using static interop.
@JS('Document')
@staticInterop
class DomDocument {}

extension DomDocumentExtension on DomDocument {
  /// Creates a new DOM element with the specified tag name.
  @JS('createElement')
  external DomElement createElement(String tagName);

  /// Creates a new Text node with the specified data.
  @JS('createTextNode')
  external DomTextNode createTextNode(String data);

  /// Gets an element by its ID. Returns null if not found.
  @JS('getElementById')
  external DomElement? getElementById(String id);

  /// Creates a new Comment node with the specified data.
  @JS('createComment')
  external DomComment createComment(String data);

  // TODO: Add other document methods as needed (querySelector, etc.)
}

/// Access to the global `document` object.
@JS('document')
external DomDocument get document; // Now returns our typed DomDocument

// --- Global Helper Functions ---

/// Creates a new DOM element with the specified tag name.
DomElement createElement(String tagName) {
  return document.createElement(tagName);
}

/// Creates a new Text node with the specified data.
DomTextNode createTextNode(String data) {
  return document.createTextNode(data);
}

/// Gets an element by its ID. Returns null if not found.
DomElement? getElementById(String id) {
  return document.getElementById(id);
}

/// Creates a new Comment node with the specified data.
DomComment createComment(String data) {
  return document.createComment(data);
}
