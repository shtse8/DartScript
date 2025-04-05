// packages/component/lib/stateless_component.dart
import 'component.dart';
// import 'context.dart'; // Removed, BuildContext is now exported by component.dart
import 'vnode.dart'; // Import VNode for return type

/// A component that does not have mutable state.
///
/// Stateless components are useful when the part of the user interface you are
/// describing does not depend on anything other than the configuration
/// information in the object itself and the context in which the
/// component is inflated.
///
/// For compositions that can change dynamically, e.g. due to having an internal
/// clock-driven state, or depending on some system state, consider using
/// a stateful component.
abstract class StatelessWidget<P extends Props?> extends Component {
  /// The properties for this component.
  final P props;

  /// Initializes [key] and [props] for subclasses.
  const StatelessWidget({super.key, required this.props});

  /// Describes the part of the user interface represented by this component.
  ///
  /// The framework calls this method when this component is inserted into the tree
  /// in a given context and when the dependencies of this component change.
  ///
  /// This method should not have any side effects beyond building its UI representation.
  @override
  VNode? build(
      BuildContext
          context); // The implementation will be provided by subclasses.
}
