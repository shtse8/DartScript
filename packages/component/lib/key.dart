// packages/component/lib/key.dart

/// A [Key] is an identifier for [Component]s.
///
/// Keys must be unique amongst the [Component]s with the same parent.
///
/// Subclasses of [Key] should either subclass [LocalKey] or [GlobalKey].
///
/// See also:
///
///  * [Component.key], the property that holds the key for components.
abstract class Key {
  /// Default constructor, used by subclasses.
  /// The [value] is used by keys that have a value that is used by
  /// [operator==].
  const Key(this.value);

  /// The value to which this key compares.
  ///
  /// This is used by [operator==]. It must be unique for each distinct key.
  final String value;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Key && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '[${objectRuntimeType(this, 'Key')} $value]';
}

/// A key that is unique only among the siblings of a component.
///
/// See also:
///
///  * [GlobalKey], a key that must be unique across the entire application.
abstract class LocalKey extends Key {
  /// Default constructor, used by subclasses.
  const LocalKey(super.value);
}

/// A key that uses a value of a particular type to identify itself.
///
/// A [ValueKey<T>] is equal to another [ValueKey<T>] if, and only if, their
/// values are [operator==].
///
/// This class can be useful when you need to associate a key with a particular
/// data object.
class ValueKey<T> extends LocalKey {
  /// Creates a key that delegates its [operator==] comparison to the String
  /// representation generated from the given [value].
  const ValueKey(T value)
      : originalValue = value,
        super('$T($value)');

  /// The original value used to create this key.
  final T originalValue;

  // Note: We keep the superclass's == and hashCode which compare the String representation.
  // This is simpler for now than handling potential hash collisions of T.
}

// Helper function similar to Flutter's foundation objectRuntimeType
String objectRuntimeType(Object? object, String optimizedValue) {
  // In a real implementation, this might have optimizations for web/release mode.
  return object.runtimeType.toString();
}
