// packages/component/lib/provider_scope.dart
import 'package:riverpod/riverpod.dart';

import 'component.dart';
// import 'context.dart'; // Removed, BuildContext is now exported by component.dart
import 'state.dart';

// Props for the ProviderScope component
class ProviderScopeProps implements Props {
  final List<Override> overrides;
  final Component child;

  ProviderScopeProps({this.overrides = const [], required this.child});
}

/// A component that creates a new ProviderContainer scope for its descendants.
///
/// Descendant widgets like [Consumer] will read providers from the container
/// created by the nearest ancestor [ProviderScope].
class ProviderScope extends StatefulWidget<ProviderScopeProps> {
  // Inherit with ProviderScopeProps

  // Constructor now takes ProviderScopeProps and passes it to super
  const ProviderScope({required ProviderScopeProps props, super.key})
      : super(props: props);

  @override
  State<ProviderScope> createState() => _ProviderScopeState();
}

class _ProviderScopeState extends State<ProviderScope> {
  late ProviderContainer _container;
  late BuildContext _childContext;

  // Public getter for the renderer to access the child context
  BuildContext get childContext => _childContext;

  @override
  void initState() {
    super.initState();
    // Create a new container, potentially overriding providers from the parent scope.
    // The parent container is accessed via the context passed by the renderer.
    final parentContainer = context.container;
    _container = ProviderContainer(
      parent: parentContainer,
      overrides: widget.props.overrides, // Access via props
    );
    // Create a new BuildContext for the child, containing the new container.
    _childContext = BuildContext(_container);
    print(
        'ProviderScope initState: Created new container scope. Parent: ${parentContainer.hashCode}, New: ${_container.hashCode}');
  }

  @override
  void didUpdateWidget(ProviderScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If overrides change, we might need to recreate the container.
    // This is complex and involves managing the lifecycle of the old container
    // and potentially migrating state. For now, we'll assume overrides are static.
    // If overrides *do* change, the current implementation won't update the container.
    print(
        'ProviderScope didUpdateWidget: Overrides changed? (Not handled yet)');
    // We also need to update the child context if the container *was* updated.
    // _childContext = BuildContext(_container);
  }

  @override
  void dispose() {
    print(
        'ProviderScope dispose: Disposing container scope: ${_container.hashCode}');
    _container.dispose();
    super.dispose();
  }

  @override
  VNode build() {
    // The ProviderScope itself doesn't render anything directly.
    // It just renders its child. The magic happens in the renderer,
    // which should pass the _childContext down when rendering the child.
    // For now, we just return the child component's VNode.
    // The renderer modification is the next crucial step.
    // We might need to wrap the child in a special VNode type or
    // have the renderer check `widget.runtimeType == ProviderScope`.
    print(
        'ProviderScope build: Rendering child ${widget.props.child.runtimeType}'); // Access via props
    // Directly return the child component. The renderer needs to handle context.
    // We might need a way to signal the renderer to use _childContext for this child.
    // Option 1: Return a special VNode type (e.g., VNode.scopedContext)
    // Option 2: Renderer checks component type during mount/update.
    // Let's assume Option 2 for now. The renderer will check if the component
    // is a ProviderScope and use its state._childContext when patching its child.
    return VNode.component(widget.props.child); // Access via props
  }
}
