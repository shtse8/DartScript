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

  @JS('pathname')
  external String get pathname; // Add pathname getter

  // Add other location properties/methods if needed (e.g., search)
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

  @JS('history')
  external History get history; // Add history getter

  @JS('dispatchEvent')
  external bool dispatchEvent(Event event); // Add dispatchEvent
}

// JS interop for window.history
@JS()
@staticInterop
class History {}

extension HistoryExtension on History {
  @JS('pushState')
  external void pushState(JSAny? data, String title, String? url);
}

// --- Custom Event Interop ---

@JS()
@staticInterop
class Event {
  external factory Event(String type, [EventInit? eventInitDict]);
}

@JS()
@anonymous
@staticInterop
class EventInit {
  external factory EventInit({
    bool bubbles = false,
    bool cancelable = false,
    bool composed = false,
  });
}

// If you need CustomEvent specifically (e.g., to pass detail)
@JS('CustomEvent')
@staticInterop
class CustomEvent extends Event {
  external factory CustomEvent(String type, [CustomEventInit? eventInitDict]);
}

extension CustomEventExtension on CustomEvent {
  external JSAny? get detail;
}

@JS()
@anonymous
@staticInterop
class CustomEventInit extends EventInit {
  external factory CustomEventInit({
    JSAny? detail, // Add detail property
    bool bubbles = false,
    bool cancelable = false,
    bool composed = false,
  });
}
