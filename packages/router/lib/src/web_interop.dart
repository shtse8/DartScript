// packages/router/lib/src/web_interop.dart
import 'dart:js_interop';

// JS interop for window.location
@JS('window.location')
external Location location; // Changed to lowercase 'location' for export

@JS()
@staticInterop
class Location {}

extension LocationExtension on Location {
  @JS('hash')
  external String get hash;
  @JS('hash')
  external set hash(String value);

  // Add other location properties/methods if needed (e.g., pathname, search)
}

// JS interop for window object (for event listeners)
@JS('window')
external JSObject window; // Changed to lowercase 'window' for export

// JS interop for addEventListener/removeEventListener on window
extension WindowExtension on JSObject {
  @JS('addEventListener')
  external void addEventListener(String type, JSFunction listener,
      [JSAny? options]);

  @JS('removeEventListener')
  external void removeEventListener(String type, JSFunction listener,
      [JSAny? options]);
}
