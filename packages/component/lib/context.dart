import 'package:riverpod/riverpod.dart';

/// Represents the build context for a component within the Dust framework.
///
/// This context provides access to information flowing down the component tree,
/// such as the Riverpod ProviderContainer.
///
/// Note: This is a very basic implementation and will likely evolve to include
/// more features similar to Flutter's BuildContext (e.g., parent context links,
/// element references, inherited data lookup).
class BuildContext {
  /// The Riverpod container associated with this context.
  ///
  /// Components can use this container (typically via a WidgetRef obtained from
  /// this context) to interact with providers.
  final ProviderContainer container;

  // TODO: Add reference to the associated Component/Element/State?
  // TODO: Add reference to the parent BuildContext?

  /// Creates a build context.
  /// This constructor is typically only called by the framework's renderer.
  BuildContext(this.container);

  // Potential future methods:
  // T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>();
  // BuildContext? findAncestorContextOfExactType<T>();
}
