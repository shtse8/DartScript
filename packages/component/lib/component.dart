// packages/component/lib/component.dart

/// Base class for all Dust components.
///
/// Components are the building blocks of a Dust application's UI.
/// Each component encapsulates its own logic and rendering.
import 'key.dart'; // Import the Key class (will be created)

abstract class Component {
  /// Controls how one component replaces another component in the tree.
  ///
  /// If the [runtimeType] and [key] properties of the two components are
  /// [operator==], respectively, then the new component replaces the old component by
  /// updating the underlying element; otherwise, the old element is removed from
  /// the tree, the new component is inflated into an element, and the new element
  /// is inserted into the tree.
  final Key? key;

  /// Properties passed down from the parent component.
  final Map<String, dynamic> props;

  /// Constructs a [Component].
  const Component({this.key, this.props = const {}});

  /// Describes the part of the user interface represented by this component.
  ///
  /// Framework calls this method when this component is inserted into the tree
  /// and when the dependencies of this component change.
  ///
  /// The framework replaces the subtree below this component with the widget
  /// returned by this method, either by updating the existing subtree or by
  /// removing the subtree and inflating a new subtree, depending on whether the
  /// widget returned by this method can update the root of the existing
  /// subtree, as determined by calling [Widget.canUpdate].
  ///
  /// Typically implementations return a newly created constellation of widgets
  /// that are configured with information from this component's constructor, the
  /// given [BuildContext], and the internal state of this component.
  ///
  /// The given [BuildContext] contains information about the location in the
  /// tree at which this component is being built. For example, the context
  /// provides the ability to obtain data from ancestor components through
  /// `context.dependOnInheritedWidgetOfExactType<T>()`.
  ///
  /// This method must not cause any side effects beyond building a widget. Any
  /// side effects should be limited to this method's execution context. It is
  /// particularly important to avoid side effects that affect the build phase
  /// itself; for example, calling `setState` is not allowed during build.
  // TODO: Define the return type more concretely (e.g., Widget, Element, Node)
  //       once the rendering mechanism is clearer. For now, use dynamic.
  // The build method is typically defined in subclasses like StatelessWidget or State.
  // It's removed from the base class as it's not universally applicable in the same way.
  // dynamic build(); // Placeholder removed
}
