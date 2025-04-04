// packages/component/lib/state.dart
import 'stateful_component.dart';
import 'vnode.dart'; // Import the VNode definition
import 'context.dart'; // Import BuildContext

/// Callback signature for requesting a component update.
typedef UpdateRequester = void Function();

/// The logic and internal state for a [StatefulWidget].
///
/// Frameworks calls the [build] method of the [State] object whenever
/// it needs to update the interface.
///
/// [State] objects are created by the framework by calling the
/// [StatefulWidget.createState] method.
///
/// The [State] object associated with a component is stored in the component's
/// element and persists between frames. A [State] object can be recreated
/// (by calling [StatefulWidget.createState]) if the component is moved to a
/// different part of the tree; because [State] objects have their own lifecycle,
/// they are responsible for ensuring that any auxiliary state associated with
/// them is relevant to the component configuration that is currently visible
/// in the tree.
///
/// It is imperative that subclasses of [State] override the [build] method.
///
/// It is also imperative that all configuration details used by the [build]
/// method be obtained from the [State] object's associated [widget] object
/// (or ancestors thereof). Subclasses will typically store other state locally
/// on the [State] object itself.
abstract class State<T extends StatefulWidget> {
  /// The component configuration corresponding to this state.
  ///
  /// The [widget] property is updated by the framework before calling [build].
  /// If the parent component rebuilds and request that this location in the tree
  /// update to display a new component of the same type, the framework will
  /// update the [widget] property of this [State] object to refer to the new
  /// component and then call [build].
  T get widget => _widget!;
  T? _widget; // Set by the framework via frameworkUpdateWidget

  /// The location in the tree where this state object resides.
  ///
  /// This property is set by the framework before calling [initState].
  /// It provides access to inherited data (like the ProviderContainer).
  late BuildContext context;

  /// Callback provided by the framework (renderer) to request an update.
  UpdateRequester? _updateRequester;

  /// Sets the callback function that the State object should call when it needs
  /// to be rebuilt (typically called by the framework/renderer during mounting).
  void setUpdateRequester(UpdateRequester requester) {
    _updateRequester = requester;
  }

  /// Describes the part of the user interface represented by this state.
  ///
  /// The framework calls this method whenever it needs to update the interface
  /// (e.g., after calling [initState], [didUpdateWidget], or [setState]).
  ///
  /// This method should not have side effects beyond building the UI.
  /// Describes the part of the user interface represented by this state,
  /// returning a [VNode] tree.
  VNode build();

  /// Called when this object is inserted into the tree.
  ///
  /// The framework will call this method exactly once for each [State] object
  /// it creates.
  ///
  /// Override this method to perform initialization that depends on the location
  /// at which this object was inserted into the tree or on the component's
  /// configuration ([widget]).
  ///
  /// If you override this, make sure your method starts with a call to
  /// super.initState().
  void initState() {
    // Default implementation is empty.
  }

  /// Called whenever the component configuration changes.
  ///
  /// If the parent component rebuilds and requests that this location in the
  /// tree update to display a new component of the same type, the framework
  /// will update the [widget] property of this [State] object to refer to the
  /// new component and then call this method with the previous component as
  /// an argument.
  ///
  /// Override this method to respond when the [widget] changes (e.g., to start
  /// implicit animations).
  ///
  /// The framework always calls [build] after calling [didUpdateWidget], which
  /// means any calls to [setState] in [didUpdateWidget] are redundant.
  ///
  /// If you override this, make sure your method starts with a call to
  /// super.didUpdateWidget(oldWidget).
  void didUpdateWidget(covariant T oldWidget) {
    // Default implementation is empty.
  }

  /// Notify the framework that the internal state of this object has changed.
  ///
  /// Whenever you change the internal state of a [State] object, make the
  /// change in a function that you pass to [setState]:
  ///
  /// ```dart
  /// setState(() {
  ///   _myState = newValue;
  /// });
  /// ```
  ///
  /// The provided callback is immediately called synchronously. It must not
  /// return a future (the callback cannot be `async`).
  ///
  /// Calling [setState] notifies the framework that the internal state of this
  /// object has changed in a way that might impact the user interface in this
  /// subtree, which causes the framework to schedule a [build] for this [State]
  /// object.
  ///
  /// If you just change the state directly without calling [setState], the
  /// framework might not schedule a [build] and the user interface for this
  /// subtree might not be updated to reflect the new state.
  void setState(void Function() fn) {
    fn();
    // In a real implementation, this would mark the element as dirty
    // and schedule a rebuild.
    _markNeedsBuild();
  }

  /// Called when this object is removed from the tree permanently.
  ///
  /// The framework calls this method when this [State] object will never
  /// build again. After the framework calls [dispose], the [State] object is
  /// considered unmounted and the [mounted] property is false. It is an error
  /// to call [setState] at this point. This stage of the lifecycle is terminal:
  /// there is no way to remount a [State] object that has been disposed.
  ///
  /// Subclasses should override this method to release any resources retained
  /// by this object (e.g., stop listening to notifications).
  ///
  /// If you override this, make sure to end your method with a call to
  /// super.dispose().
  void dispose() {
    // Default implementation is empty.
    _widget = null; // Help with garbage collection
    _updateRequester = null; // Clear requester on dispose
  }

  /// Whether this [State] object is currently in a tree.
  ///
  /// After creating a [State] object and before calling [initState], the
  /// framework "mounts" the [State] object and sets this property to true. The
  /// [State] object remains mounted until the framework calls [dispose], after
  /// which the framework "unmounts" the [State] object and sets this property
  /// to false.
  bool get mounted => _widget != null;

  // Internal method called by setState.
  void _markNeedsBuild() {
    // If an update requester is set, call it.
    if (_updateRequester != null) {
      print('State for $widget requesting update via callback.');
      _updateRequester!();
    } else {
      // Fallback if no requester is set (shouldn't happen in a proper setup)
      print('State for $widget marked as needing build, but no requester set.');
    }
  }

  // Called by the framework (e.g., renderer) to set the initial widget
  // and trigger initial lifecycle methods or updates.
  // Renamed from _updateWidget to make it accessible.
  void frameworkUpdateWidget(T newWidget) {
    T? oldWidget = _widget;
    _widget = newWidget;
    if (oldWidget == null) {
      // This is the initial mounting
      initState();
    } else if (oldWidget != newWidget) {
      // This is an update
      didUpdateWidget(oldWidget);
    }
    // Note: build() is typically called *after* initState or didUpdateWidget
    // by the framework's rendering loop, triggered by _markNeedsBuild or
    // initial render schedule.
  }
}
