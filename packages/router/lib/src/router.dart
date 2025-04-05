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

// Top-level function to handle popstate event, taking state as argument
void _handlePopState(_RouterState state, JSAny event) {
  // Note: 'event' might contain state data if pushState was used with data
  state._updatePath();
}

// Top-level function to handle custom dustnavigate event
void _handleDustNavigate(_RouterState state, JSAny event) {
  // The event itself might not have path info, so we read from location
  state._updatePath();
}

class _RouterState extends State<Router> {
  String _currentPath = ''; // Store the current path

  // Need a field to store the JS function wrapper for removal
  JSFunction? _popStateWrapper;
  JSFunction? _dustNavigateWrapper; // Wrapper for custom event

  @override
  void initState() {
    super.initState();
    // Set initial path directly without calling setState
    final initialPath = location.pathname;
    _currentPath = initialPath.isEmpty ? '/' : initialPath;
    // Listen for URL changes using JS interop with the top-level function
    // Pass 'this' (the state instance) to the handler
    // Convert the Dart callback to a JS function using .toJS
    _popStateWrapper = ((JSAny event) => _handlePopState(this, event)).toJS;
    _dustNavigateWrapper = ((JSAny event) => _handleDustNavigate(this, event))
        .toJS; // Create wrapper

    window.addEventListener('popstate', _popStateWrapper!);
    window.addEventListener(
        'dustnavigate', _dustNavigateWrapper!); // Listen for custom event
  }

  // Update path logic using JS interop
  void _updatePath() {
    // Use pathname for History API routing
    final newPath = location.pathname; // Use imported 'location' and pathname
    // Default path is usually handled by the server or initial load,
    // but ensure it's not empty if pathname somehow is.
    final effectivePath = newPath.isEmpty ? '/' : newPath;
    if (newPath != _currentPath) {
      setState(() {
        _currentPath = effectivePath; // Use effectivePath
      });
    } else {
      // Path did not change, do nothing.
    }
  }

  @override
  void dispose() {
    // Remove the popstate event listener
    if (_popStateWrapper != null) {
      window.removeEventListener('popstate', _popStateWrapper!);
      _popStateWrapper = null;
    }
    // Remove the dustnavigate event listener
    if (_dustNavigateWrapper != null) {
      window.removeEventListener('dustnavigate', _dustNavigateWrapper!);
      _dustNavigateWrapper = null;
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
