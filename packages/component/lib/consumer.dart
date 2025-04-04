import 'package:riverpod/riverpod.dart';
import 'package:dust_renderer/renderer.dart'; // To access appProviderContainer (temporary)

import 'component.dart';
import 'state.dart';
import 'stateful_component.dart';
import 'vnode.dart';

// Type definition for the builder function
typedef ConsumerBuilder = VNode Function(WidgetRef ref);

/// A widget that obtains a [WidgetRef] from the nearest [ProviderScope]
/// and rebuilds when subscribed providers change.
class Consumer extends StatefulWidget {
  final ConsumerBuilder builder;

  // Removed key parameter as StatefulWidget base class doesn't have it yet.
  const Consumer({required this.builder});

  @override
  State<Consumer> createState() => _ConsumerState();
}

class _ConsumerState extends State<Consumer> {
  late WidgetRef _ref;
  late VNode _cachedVNode;
  // Store subscriptions to dispose them later
  final List<ProviderSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    // Get the container (using the temporary global getter)
    final container = appProviderContainer;
    // Create a WidgetRef associated with this state
    _ref = WidgetRef(container, this);
    // Initial build
    _buildAndCache();
  }

  @override
  void dispose() {
    // Dispose all subscriptions
    for (final sub in _subscriptions) {
      sub.close();
    }
    _subscriptions.clear();
    // Dispose the WidgetRef (important to prevent memory leaks)
    _ref.dispose();
    super.dispose();
  }

  // Helper method to build the VNode and cache it
  void _buildAndCache() {
    // Reset subscriptions before building, as build might add new ones
    for (final sub in _subscriptions) {
      sub.close();
    }
    _subscriptions.clear();
    // Execute the user's builder function with the ref
    _cachedVNode = widget.builder(_ref);
  }

  // This method will be called by WidgetRef when a listened provider changes
  void _onDependencyChanged() {
    // Rebuild the VNode and trigger a UI update
    setState(() {
      _buildAndCache();
    });
  }

  @override
  VNode build() {
    // Return the cached VNode. The actual build logic happens in _buildAndCache
    // triggered by initState and _onDependencyChanged (via setState).
    return _cachedVNode;
  }
}

// --- Minimal WidgetRef Implementation ---
// This needs to be implemented to allow `ref.watch` and `ref.listen`
// It needs access to the ProviderContainer and the State (_ConsumerState)

class WidgetRef implements Ref {
  final ProviderContainer _container;
  final _ConsumerState _state; // Reference to the state for triggering rebuilds
  bool _disposed = false;

  WidgetRef(this._container, this._state);

  @override
  T watch<T>(ProviderListenable<T> provider) {
    if (_disposed) {
      throw StateError('WidgetRef accessed after dispose.');
    }
    // Subscribe to the provider and trigger rebuild on change
    final sub = _container.listen<T>(
      provider,
      (_, __) => _state._onDependencyChanged(), // Call state's method on change
      fireImmediately: false, // Don't fire immediately for watch
    );
    // Keep track of the subscription to dispose it later
    _state._subscriptions.add(sub);
    // Return the current value
    return _container.read(provider);
  }

  @override
  T read<T>(ProviderListenable<T> provider) {
    if (_disposed) {
      throw StateError('WidgetRef accessed after dispose.');
    }
    return _container.read(provider);
  }

  @override
  ProviderSubscription<T> listen<T>(
    // Add type argument
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener, {
    // Make listener non-nullable
    bool fireImmediately = false,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    if (_disposed) {
      throw StateError('WidgetRef accessed after dispose.');
    }
    // Ensure listener is not null before passing
    final sub = _container.listen<T>(
      provider,
      listener, // Now non-nullable
      fireImmediately: fireImmediately,
      onError: onError,
    );
    // Also track listener subscriptions for disposal
    _state._subscriptions.add(sub);
    return sub; // Return the subscription
  }

  @override
  bool exists(ProviderBase<Object?> provider) {
    if (_disposed) {
      throw StateError('WidgetRef accessed after dispose.');
    }
    return _container.exists(provider);
  }

  @override
  T refresh<T>(Refreshable<T> provider) {
    if (_disposed) {
      throw StateError('WidgetRef accessed after dispose.');
    }
    return _container.refresh(provider);
  }

  @override
  Future<T> future<T>(FutureProvider<T> provider) {
    if (_disposed) {
      throw StateError('WidgetRef accessed after dispose.');
    }
    return _container.read(provider.future);
  }

  // --- Methods from Ref not typically used by WidgetRef ---
  // Implement them by throwing UnimplementedError for now.

  @override
  T notifier<T extends dynamic>(
      // Use dynamic as base type if NotifierBase is unavailable
      ProviderBase<T> provider) {
    // Use ProviderBase if NotifierProviderBase is unavailable
    // Reading notifier directly is complex and depends on provider type.
    // Mark as unimplemented for simplicity in this basic WidgetRef.
    // Users should typically call methods on the notifier instance obtained via `read` or `watch`.
    throw UnimplementedError(
        'WidgetRef.notifier is not fully implemented. Obtain the notifier instance via read/watch and call methods.');
  }

  @override
  void invalidate(ProviderOrFamily provider) {
    if (_disposed) {
      throw StateError('WidgetRef accessed after dispose.');
    }
    _container.invalidate(provider);
  }

  @override
  void invalidateSelf() {
    throw UnimplementedError('invalidateSelf cannot be called on a WidgetRef');
  }

  @override
  void listenSelf(void Function(Object? previous, Object? next) listener,
      {void Function(Object error, StackTrace stackTrace)? onError}) {
    throw UnimplementedError('listenSelf cannot be called on a WidgetRef');
  }

  @override
  bool get mounted => !_disposed;

  // Implement the missing 'container' getter
  @override
  ProviderContainer get container => _container;

  @override
  KeepAliveLink keepAlive() {
    throw UnimplementedError('keepAlive cannot be called on a WidgetRef');
  }

  @override
  void notifyListeners() {
    throw UnimplementedError('notifyListeners cannot be called on a WidgetRef');
  }

  // --- Existing unimplemented methods ---
  @override
  void onAddListener(void Function() cb) {
    throw UnimplementedError('onAddListener not implemented for WidgetRef');
  }

  @override
  void onCancel(void Function() cb) {
    throw UnimplementedError('onCancel not implemented for WidgetRef');
  }

  @override
  void onDispose(void Function() cb) {
    throw UnimplementedError('onDispose not implemented for WidgetRef');
  }

  @override
  void onRemoveListener(void Function() cb) {
    throw UnimplementedError('onRemoveListener not implemented for WidgetRef');
  }

  @override
  void onResume(void Function() cb) {
    throw UnimplementedError('onResume not implemented for WidgetRef');
  }

  // Custom dispose method for our WidgetRef
  void dispose() {
    _disposed = true;
    // Container disposal is handled elsewhere (in runApp or app lifecycle)
  }
}
