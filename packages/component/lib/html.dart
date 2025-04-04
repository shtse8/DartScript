// packages/component/lib/html.dart
// Provides helper functions for creating VNodes with an HTML-like syntax.

import 'vnode.dart';
import 'package:dust_renderer/dom_event.dart'; // For listener type

// Common type alias for attributes and listeners
typedef Attributes = Map<String, String>;
typedef Listeners = Map<String, void Function(DomEvent event)>;

// Helper function to create element VNodes
VNode _element(
  String tag, {
  Object? key,
  Attributes? attributes,
  List<VNode>? children,
  String? text, // Allow direct text content for simple elements
  Listeners? listeners,
}) {
  // Basic validation: Cannot have both children and text
  assert(children == null || text == null,
      'Cannot provide both children and text for VNode with tag "$tag".');

  // If text is provided, create children list with a single text node
  final effectiveChildren = text != null ? [VNode.text(text)] : children;

  return VNode.element(
    tag, // tag is the first positional argument for VNode.element
    key: key,
    attributes: attributes,
    children: effectiveChildren, // Use effectiveChildren
    listeners: listeners,
  );
}

// --- HTML Tag Functions ---

// Structure Elements
VNode div({
  Object? key,
  Attributes? attributes,
  List<VNode>? children,
  Listeners? listeners,
}) =>
    _element('div',
        key: key,
        attributes: attributes,
        children: children,
        listeners: listeners);

VNode span({
  Object? key,
  Attributes? attributes,
  List<VNode>? children,
  String? text,
  Listeners? listeners,
}) =>
    _element('span',
        key: key,
        attributes: attributes,
        children: children,
        text: text,
        listeners: listeners);

VNode p({
  Object? key,
  Attributes? attributes,
  List<VNode>? children,
  String? text,
  Listeners? listeners,
}) =>
    _element('p',
        key: key,
        attributes: attributes,
        children: children,
        text: text,
        listeners: listeners);

// Heading Elements
VNode h1({
  Object? key,
  Attributes? attributes,
  List<VNode>? children,
  String? text,
  Listeners? listeners,
}) =>
    _element('h1',
        key: key,
        attributes: attributes,
        children: children,
        text: text,
        listeners: listeners);

VNode h2({
  Object? key,
  Attributes? attributes,
  List<VNode>? children,
  String? text,
  Listeners? listeners,
}) =>
    _element('h2',
        key: key,
        attributes: attributes,
        children: children,
        text: text,
        listeners: listeners);

VNode h3({
  Object? key,
  Attributes? attributes,
  List<VNode>? children,
  String? text,
  Listeners? listeners,
}) =>
    _element('h3',
        key: key,
        attributes: attributes,
        children: children,
        text: text,
        listeners: listeners);

// List Elements
VNode ul({
  Object? key,
  Attributes? attributes,
  required List<VNode> children, // Typically requires children
  Listeners? listeners,
}) =>
    _element('ul',
        key: key,
        attributes: attributes,
        children: children,
        listeners: listeners);

VNode li({
  Object? key,
  Attributes? attributes,
  List<VNode>? children,
  String? text,
  Listeners? listeners,
}) =>
    _element('li',
        key: key,
        attributes: attributes,
        children: children,
        text: text,
        listeners: listeners);

// Form Elements
VNode button({
  Object? key,
  Attributes? attributes,
  List<VNode>? children,
  String? text,
  required Listeners? listeners, // Buttons usually need listeners
}) =>
    _element('button',
        key: key,
        attributes: attributes,
        children: children,
        text: text,
        listeners: listeners);

VNode input({
  Object? key,
  required Attributes?
      attributes, // Inputs usually need attributes (type, value etc.)
  Listeners? listeners,
}) =>
    _element('input', key: key, attributes: attributes, listeners: listeners);

// Text Node Helper (optional, but can be explicit)
VNode text(String value) => VNode.text(value);

// Add more tag functions as needed (e.g., img, a, form, label, etc.)
