import 'package:dust_component/state.dart'; // Import State
import 'package:dust_component/component.dart'; // Correct import path
import 'dart:js_interop'; // Import for JS interop

import 'web_interop.dart'; // Import shared interop definitions

// Placeholder for Route configuration
class Route {
  final String path;
  final ComponentBuilder builder; // Function that returns a Component

  Route({required this.path, required this.builder});
}

typedef ComponentBuilder = VNode? Function(
    BuildContext context); // Return VNode?

// Props for the Router component
class RouterProps implements Props {
  final List<Route> routes;
  final ComponentBuilder? notFoundBuilder; // Optional component for 404

  RouterProps({required this.routes, this.notFoundBuilder});
}

class Router extends StatefulWidget<RouterProps> {
  // Specify RouterProps
  // Constructor takes RouterProps and passes it to super
  const Router({required RouterProps props, super.key}) : super(props: props);

  @override
  State<Router> createState() => _RouterState();
}

// Top-level function to handle hash change, taking state as argument
void _handleHashChange(_RouterState state, JSAny event) {
  state._updatePath();
}

class _RouterState extends State<Router> {
  String _currentPath = ''; // Store the current path

  // Need a field to store the JS function wrapper for removal
  JSFunction? _hashChangeWrapper;

  @override
  void initState() {
    super.initState();
    // Initial path reading using JS interop
    _updatePath();
    // Listen for URL changes using JS interop with the top-level function
    // Pass 'this' (the state instance) to the handler
    // Convert the Dart callback to a JS function using .toJS
    _hashChangeWrapper = ((JSAny event) => _handleHashChange(this, event)).toJS;
    window.addEventListener(
        'hashchange', _hashChangeWrapper!); // Use imported 'window'
    // TODO: Add History API listener if not using hash routing
  }

  // Update path logic using JS interop
  void _updatePath() {
    // Simple hash-based routing for now
    final newPath = location.hash.isNotEmpty // Use imported 'location'
        ? location.hash.substring(1) // Use imported 'location'
        : '/'; // Default path if hash is empty
    if (newPath != _currentPath) {
      setState(() {
        _currentPath = newPath;
      });
    }
  }

  @override
  void dispose() {
    // Remove the event listener
    if (_hashChangeWrapper != null) {
      window.removeEventListener(
          'hashchange', _hashChangeWrapper!); // Use imported 'window'
      _hashChangeWrapper = null;
    }
    super.dispose();
  }

  @override
  VNode build() {
    // Return VNode, remove context parameter
    // Find the matching route
    for (final route in widget.props.routes) {
      // Basic exact path matching for now
      if (route.path == _currentPath) {
        final vnode =
            route.builder(context); // Call builder with state's context
        if (vnode != null) return vnode; // Return if not null
        // Handle null case if necessary, maybe return an empty node or throw
        return VNode.text(''); // Return empty text node if builder returns null
      }
    }

    // No match found, render notFoundBuilder or null
    final notFoundVNode = widget.props.notFoundBuilder?.call(context);
    return notFoundVNode ??
        VNode.text(
            ''); // Return empty text node if not found builder is null or returns null
  }
}
