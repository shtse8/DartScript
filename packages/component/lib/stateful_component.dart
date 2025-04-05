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
// Add generic type P for Props, extending Props? to allow null
abstract class StatefulWidget<P extends Props?> extends Component {
  /// The properties for this component.
  final P props;

  /// Initializes [key] and [props] for subclasses.
  // Pass props to the Component superclass constructor
  const StatefulWidget({super.key, required this.props}) : super(props: props);

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
  // State should be generic over the StatefulWidget type itself
  State<StatefulWidget<P>>
      createState(); // Keep P here as StatefulWidget is generic

  // StatefulWidget itself doesn't build. The State object does.
  // The base Component class no longer defines an abstract build method.
}
