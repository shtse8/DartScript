import 'dart:js_interop';

/// A Dart wrapper around a JavaScript event object (`JSAny`).
/// Provides type-safe access to common event properties and methods.
@JS()
@staticInterop // Mark for static interop
class _JSEventTarget {} // Keep the class empty for static interop

// Define instance members in an extension
extension _JSEventTargetExtension on _JSEventTarget {
  external JSAny? get value; // For input elements, etc.
  external JSString? get id;
  // Add other target properties as needed here
}

extension JSEventExtension on JSAny {
  // Access properties of the JS event object
  external JSString get type; // e.g., 'click', 'input'
  // Return JSAny? from the extension, cast later in DomEvent
  external JSAny? get target;
  external JSAny?
      get currentTarget; // Usually the element the listener is attached to
  external JSBoolean get bubbles;
  external JSBoolean get cancelable;
  external JSNumber get timeStamp;
  // Add other common event properties as needed (e.g., key, keyCode for keyboard events)

  // Call methods on the JS event object
  external void preventDefault();
  external void stopPropagation();
  external void stopImmediatePropagation();
}

class DomEvent {
  final JSAny _jsEvent;

  DomEvent(this._jsEvent);

  /// The underlying JavaScript event object. Use this for accessing
  /// properties not explicitly exposed by the wrapper.
  JSAny get nativeEvent => _jsEvent;

  /// The type of the event (e.g., 'click').
  String get type => _jsEvent.type.toDart;

  /// The element that triggered the event.
  /// Note: Accessing properties like `value` or `id` requires casting
  /// the returned `JSAny?` or using JS interop extensions on it.
  /// Example: `(event.target as JSObject?)?.getProperty('value'.toJS)`
  /// Consider adding specific getters for common target properties if needed.
  // Cast the JSAny? returned by the extension to the static interop type
  _JSEventTarget? get target => _jsEvent.target as _JSEventTarget?;

  /// The element to which the event listener is attached.
  JSAny? get currentTarget => _jsEvent.currentTarget;

  /// Indicates whether the event bubbles up through the DOM.
  bool get bubbles => _jsEvent.bubbles.toDart;

  /// Indicates whether the event is cancelable.
  bool get cancelable => _jsEvent.cancelable.toDart;

  /// The time (in milliseconds) at which the event was created.
  /// Using toDartDouble for potentially fractional milliseconds.
  double get timeStamp => _jsEvent.timeStamp.toDartDouble;

  /// Prevents the default action associated with the event.
  void preventDefault() => _jsEvent.preventDefault();

  /// Stops the event from bubbling up the DOM tree.
  void stopPropagation() => _jsEvent.stopPropagation();

  /// Stops the event from propagating further, including to other listeners
  /// on the same element.
  void stopImmediatePropagation() => _jsEvent.stopImmediatePropagation();

  // Helper to get target's value directly (common use case)
  String? get targetValue {
    final jsValue = target?.value;
    // Corrected: Use && instead of &amp;&amp;
    if (jsValue != null && jsValue.isA<JSString>()) {
      return (jsValue as JSString).toDart;
    }
    // Handle other types like JSNumber if necessary
    return null;
  }

  // Helper to get target's id directly
  String? get targetId {
    final jsId = target?.id;
    if (jsId != null) {
      return jsId.toDart;
    }
    return null;
  }
}
