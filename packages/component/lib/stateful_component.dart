// packages/component/lib/stateful_component.dart
import 'component.dart';
import 'state.dart'; // Will be created next

/// A component that has mutable state.
///
/// State is information that (1) can be read synchronously when the component
/// builds and (2) might change during the lifetime of the component. It is the
/// responsibility of the component implementer to ensure that the [State] is
/// promptly notified when such state changes, using [State.setState].
///
/// A stateful component is a component that describes part of the user interface
/// by building a constellation of other components that describe the user
/// interface more concretely. The building process is encapsulated in the
/// [State.build] method.
///
/// Stateful components are useful when the part of the user interface described
/// by the component can change dynamically, e.g. due to having an internal
/// clock-driven state, or depending on some system state.
abstract class StatefulWidget extends Component {
  /// Initializes [key] for subclasses.
  const StatefulWidget(); // Consider adding Key later

  /// Creates the mutable state for this component at a given location in the tree.
  ///
  /// Subclasses should override this method to return a newly created
  /// instance of their associated [State] subclass:
  ///
  /// ```dart
  /// @override
  /// MyState createState() => MyState();
  /// ```
  ///
  /// The framework can call this method multiple times over the lifetime of
  /// a [StatefulWidget]. For example, if the component is inserted into the tree
  /// in multiple locations, the framework will create a separate [State] object
  /// for each location. Similarly, if the component is removed from the tree and
  /// later inserted into the tree again, the framework will call [createState]
  /// again to create a fresh [State] object, simplifying the lifecycle of
  /// [State] objects.
  State createState();

  /// Stateful components themselves don't have a build method.
  /// The UI is built by the associated State object.
  @override
  dynamic build() {
    // This should ideally not be callable directly.
    // The framework interacts with the State object created by createState.
    throw UnimplementedError(
      'StatefulWidget does not build directly. Use its State object.',
    );
  }
}
