// packages/component/lib/stateless_component.dart
import 'component.dart';

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
abstract class StatelessWidget extends Component {
  /// Initializes properties for subclasses.
  const StatelessWidget(); // Consider adding Key later

  /// Describes the part of the user interface represented by this component.
  ///
  /// The framework calls this method when this component is inserted into the tree
  /// in a given context and when the dependencies of this component change.
  ///
  /// This method should not have any side effects beyond building its UI representation.
  @override
  dynamic build(); // The implementation will be provided by subclasses.
}
