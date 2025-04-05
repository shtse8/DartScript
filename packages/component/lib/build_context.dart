import 'package:riverpod/riverpod.dart';

/// Provides context about the component's location in the tree and access
/// to scoped services like the ProviderContainer.
class BuildContext {
  /// The Riverpod container scoped to this part of the component tree.
  final ProviderContainer container;

  /// Creates a BuildContext.
  /// Typically created by the framework (Renderer or specific components like ProviderScope).
  const BuildContext(this.container);

  // Add methods here later if needed to interact with the tree,
  // similar to Flutter's BuildContext (e.g., findAncestorWidgetOfExactType).
}
