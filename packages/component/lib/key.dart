/// A Key is an identifier for Components.
///
/// Keys must be unique amongst the Components with the same parent.
/// Keys help the framework determine how to update the UI when the order or
/// identity of components changes.
abstract class Key {
  /// Private constructor to prevent external extension.
  const Key._();

  /// Creates a key based on a string value.
  factory Key(String value) => ValueKey(value);
}

/// A key that uses a value of a particular type to identify itself.
///
/// A [ValueKey<T>] is equal to another [ValueKey<T>] if, and only if, their
/// values are [operator==].
class ValueKey<T> extends Key {
  /// Creates a key that delegates its identity to the given value.
  const ValueKey(this.value) : super._();

  /// The value to which this key delegates its identity.
  final T value;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ValueKey<T> && other.value == value;
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() => '[ValueKey<$T> $value]';
}
