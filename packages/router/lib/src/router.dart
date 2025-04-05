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

typedef ComponentBuilder = VNode? Function(BuildContext context,
    Map<String, String>? params); // Return VNode?, Add params

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

  Map<String, String>? _matchRoute(String routePattern, String currentPath) {
    final paramNames = <String>[];
    // Convert route pattern to regex, extracting param names
    // Example: /users/:id -> ^/users/([^/]+)$
    final regexPattern =
        routePattern.replaceAllMapped(RegExp(r':([^/]+)'), (match) {
      paramNames.add(match.group(1)!); // Store param name
      return '([^/]+)'; // Regex for capturing segment
    });

    final regExp = RegExp('^$regexPattern\$'); // Anchor the regex
    final match = regExp.firstMatch(currentPath);

    if (match == null) {
      // Handle exact match case separately if no params were defined
      if (paramNames.isEmpty && routePattern == currentPath) {
        return {}; // Exact match, no params
      }
      return null; // No match
    }

    // Extract parameters if match found
    final params = <String, String>{};
    for (var i = 0; i < match.groupCount; i++) {
      if (i < paramNames.length) {
        // Ensure we have a name for the group
        final value = match.group(i + 1); // Groups are 1-indexed
        if (value != null) {
          params[paramNames[i]] = value;
        }
      }
    }
    return params;
  }

  @override
  VNode build() {
    // Return VNode, remove context parameter
    // Find the matching route
    // Find the matching route using pattern matching
    for (final route in widget.props.routes) {
      final params = _matchRoute(route.path, _currentPath); // Use matching func
      if (params != null) {
        // Check if match found (params map is not null)
        final vnode = route.builder(context, params); // Pass params
        if (vnode != null) return vnode;
        return VNode.text(''); // Return empty text node if builder returns null
      }
    }

    // No match found, render notFoundBuilder or null
    // Pass null for params to notFoundBuilder
    final notFoundVNode = widget.props.notFoundBuilder?.call(context, null);
    return notFoundVNode ?? VNode.text('');
  }
}
