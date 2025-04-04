// packages/renderer/lib/renderer.dart

import 'package:dust_component/component.dart';
import 'package:dust_component/stateful_component.dart';
import 'package:dust_component/state.dart';
import 'dart:js_interop';
import 'package:dust_component/stateless_component.dart'; // Import StatelessWidget

// --- JS Interop ---
@JS('document.createElement')
external JSAny _createElement(JSString tagName);

@JS('document.getElementById')
external JSAny? _getElementById(JSString id);

extension JSAnyExtension on JSAny {
  external set textContent(JSString text);
  external void appendChild(JSAny child);
  // Needed to clear content before update
  external set innerHTML(JSString html);
}
// --- End JS Interop ---

// --- Simple Renderer State ---
// Store the state and target element for updates (very basic)
State? _mountedState;
JSAny? _targetElement;
// --- End Simple Renderer State ---

/// Performs the actual rendering or re-rendering of the component state.
void _performRender(State componentState, JSAny targetElement) {
  print('Performing render/update...');
  try {
    // 1. Build the component state
    final representation = componentState.build();
    print('State build returned: $representation');

    // 2. Interpret the representation and update DOM (very basic, replaces all content)
    if (representation is Map<String, String>) {
      final String? tag = representation['tag'];
      final String? text = representation['text'];

      if (tag != null) {
        final JSAny element = _createElement(tag.toJS);
        if (text != null) {
          element.textContent = text.toJS;
        }
        // Clear the target element first (simple approach)
        targetElement.innerHTML =
            ''.toJS; // Clear previous content using innerHTML
        // Append the new element
        targetElement.appendChild(element);
        print('Rendered/Updated <$tag> element.');
      } else {
        print('Error: Representation map missing "tag" key.');
        targetElement.textContent = 'Error: Invalid build result (no tag)'.toJS;
      }
    } else {
      print(
        'Error: Unsupported component representation type: ${representation.runtimeType}',
      );
      targetElement.textContent = 'Error: Cannot render component.'.toJS;
    }
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
      // Directly render the representation (similar logic as _performRender)
      if (representation is Map<String, String>) {
        final String? tag = representation['tag'];
        final String? text = representation['text'];
        if (tag != null) {
          final JSAny element = _createElement(tag.toJS);
          if (text != null) {
            element.textContent = text.toJS;
          }
          _targetElement!.innerHTML = ''.toJS;
          _targetElement!.appendChild(element);
          print('Rendered stateless <$tag> element.');
        } else {/* Error handling */}
      } else {/* Error handling */}
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
