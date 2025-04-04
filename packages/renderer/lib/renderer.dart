// packages/renderer/lib/renderer.dart

// TODO: Adjust import paths when packages are properly set up
import 'package:dust_component/component.dart';
// TODO: Need a way to access DOM manipulation functions.
// For now, assume access to similar functions as defined in the old DartScriptApi
// or directly use js_interop. Let's define placeholder functions for now.
import 'dart:js_interop'; // Using js_interop directly for now

// Placeholder for DOM manipulation functions (replace with actual JS interop calls)
@JS('document.createElement')
external JSAny _createElement(JSString tagName);

@JS('document.getElementById')
external JSAny? _getElementById(JSString id);

extension on JSAny {
  // Placeholder for setting text content
  external set textContent(JSString text);
  // Placeholder for appending child
  external void appendChild(JSAny child);
}

/// Renders a component into a target DOM element.
///
/// This is a very basic proof-of-concept renderer.
void render(Component component, String targetElementId) {
  print(
    'Starting render process for component $component into #$targetElementId',
  );

  // 1. Get the target DOM element
  final JSAny? targetElement = _getElementById(targetElementId.toJS);
  if (targetElement == null) {
    print('Error: Target element #$targetElementId not found.');
    return;
  }

  // 2. Build the component to get its representation
  // TODO: Handle stateful components later (needs state creation/management)
  final dynamic representation = component.build();
  print('Component build returned: $representation');

  // 3. Interpret the representation and create DOM nodes (very basic)
  if (representation is Map<String, String>) {
    final String? tag = representation['tag'];
    final String? text = representation['text'];

    if (tag != null) {
      final JSAny element = _createElement(tag.toJS);
      if (text != null) {
        element.textContent = text.toJS;
      }
      // Clear the target element first (simple approach)
      targetElement.textContent = ''.toJS; // Clear previous content
      // Append the new element
      targetElement.appendChild(element);
      print('Rendered <$tag> element into #$targetElementId');
    } else {
      print('Error: Representation map missing "tag" key.');
    }
  } else {
    // TODO: Handle other types of representations (e.g., lists of children)
    print(
      'Error: Unsupported component representation type: ${representation.runtimeType}',
    );
    targetElement.textContent = 'Error: Cannot render component.'.toJS;
  }
}
