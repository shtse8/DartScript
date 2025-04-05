import 'package:dust_component/state.dart'; // Import State
import 'package:dust_component/component.dart'; // Correct import path
import 'dart:js_interop'; // Import for JS interop

import 'web_interop.dart'; // Import shared interop definitions

// Placeholder for Route configuration
class Route {
  final String path;
  final ComponentBuilder builder;
  final List<Route>? children; // Add children for nesting

  Route({
    required this.path,
    required this.builder,
    this.children, // Make children optional
  });
}

typedef ComponentBuilder = VNode? Function(
  BuildContext context,
  Map<String, String>? params,
  VNode? childVNode, // Add childVNode for rendering nested routes
);

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

// Helper class to store results of recursive matching
class _MatchedRouteInfo {
  final Route route;
  final Map<String, String> params;
  final String remainingPath; // Path segment left for children to match

  _MatchedRouteInfo(this.route, this.params, this.remainingPath);
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

  // Matches a single route pattern against the beginning of a path segment.
  // Returns parameters and the length of the matched segment, or null if no match.
  ({Map<String, String> params, int matchedLength})? _matchRouteSegment(
      String routePath, String currentPathSegment) {
    final paramNames = <String>[];
    // Convert route path to regex, extracting param names.
    // Example: /users/:id -> /users/([^/]+)
    // We don't anchor with ^$ here, as we match prefixes for nesting.
    final regexPattern =
        routePath.replaceAllMapped(RegExp(r':([^/]+)'), (match) {
      paramNames.add(match.group(1)!);
      return '([^/]+)';
    })
            // Ensure trailing slash is optional for matching purposes
            .replaceAll(RegExp(r'/$'), ''); // Remove trailing slash if present

    // Match from the beginning of the current path segment
    final regExp = RegExp('^$regexPattern');
    final match = regExp.firstMatch(currentPathSegment);

    if (match == null) {
      // Handle exact match for root '/' separately
      if (routePath == '/' && currentPathSegment.startsWith('/')) {
        // Match root '/' only if currentPathSegment is exactly '/' or starts with '/?'
        if (currentPathSegment == '/' || currentPathSegment.startsWith('/?')) {
          return (params: {}, matchedLength: 1);
        }
      }
      // Handle exact match for non-root paths without params
      if (paramNames.isEmpty && currentPathSegment.startsWith(routePath)) {
        // Ensure it matches the whole segment or ends with a slash or query params
        if (currentPathSegment.length == routePath.length ||
            currentPathSegment.startsWith('$routePath/') ||
            currentPathSegment.startsWith('$routePath?')) {
          return (params: {}, matchedLength: routePath.length);
        }
      }
      return null; // No match
    }

    // Extract parameters
    final params = <String, String>{};
    for (var i = 0; i < match.groupCount; i++) {
      if (i < paramNames.length) {
        final value = match.group(i + 1);
        if (value != null) {
          params[paramNames[i]] = value;
        }
      }
    }
    // Return params and the length of the matched string
    return (params: params, matchedLength: match.end);
  }

  // Recursive function to find the matching route chain.
  // Returns a list representing the chain from root to leaf, or null if no match.
  List<_MatchedRouteInfo>? _findMatchingRouteRecursive(String currentPath,
      List<Route> routes, Map<String, String> parentParams) {
    for (final route in routes) {
      final segmentMatch = _matchRouteSegment(route.path, currentPath);

      if (segmentMatch != null) {
        final currentParams = {...parentParams, ...segmentMatch.params};
        // Ensure trailing slash is handled correctly for remaining path calculation
        final matchedPathEndIndex = segmentMatch.matchedLength;
        String remainingPath = currentPath.length > matchedPathEndIndex
            ? currentPath.substring(matchedPathEndIndex)
            : '';

        // Normalize remaining path: ensure it starts with '/' if not empty or query params
        if (remainingPath.isNotEmpty &&
            !remainingPath.startsWith('/') &&
            !remainingPath.startsWith('?')) {
          // This case should ideally not happen if parent paths end correctly,
          // but handle defensively. Might indicate an issue in path definition or matching.
          continue; // Skip if remaining path is invalid relative segment
        }
        // Remove leading '/' for child matching, unless it's just "/"
        final remainingPathForChildren =
            (remainingPath.length > 1 && remainingPath.startsWith('/'))
                ? remainingPath.substring(1)
                : remainingPath;

        // If this route has children and there's a non-query remaining path
        if (route.children != null &&
            route.children!.isNotEmpty &&
            remainingPath.isNotEmpty &&
            !remainingPath.startsWith('?')) {
          final childMatchChain = _findMatchingRouteRecursive(
              remainingPathForChildren,
              route.children!,
              currentParams); // Pass cleaned path

          if (childMatchChain != null) {
            // Found a deeper match, prepend current route info and return chain
            return [
              _MatchedRouteInfo(route, currentParams, remainingPath),
              ...childMatchChain
            ];
          }
        }

        // If no deeper match needed/found, check if this route is a full match
        if (remainingPath.isEmpty || remainingPath.startsWith('?')) {
          // This is the leaf match
          return [_MatchedRouteInfo(route, currentParams, remainingPath)];
        }
      }
    }
    return null; // No match found at this level
  }

  @override
  VNode build() {
    // Return VNode, remove context parameter
    // Find the matching route
    // Find the matching route chain recursively
    final matchedChain = _findMatchingRouteRecursive(
        _currentPath, widget.props.routes, {}); // Start with empty params

    VNode? finalVNode;

    if (matchedChain != null && matchedChain.isNotEmpty) {
      // Build the VNode tree recursively from child to parent
      VNode? childVNode; // Start with null for the innermost child
      for (var i = matchedChain.length - 1; i >= 0; i--) {
        final currentInfo = matchedChain[i];
        // Call the builder with context, accumulated params, and the VNode from the inner route
        childVNode =
            currentInfo.route.builder(context, currentInfo.params, childVNode);
      }
      finalVNode = childVNode; // The result of the outermost builder call
    }

    // No match found, render notFoundBuilder or null
    // Pass null for params and childVNode to notFoundBuilder
    final notFoundVNode =
        widget.props.notFoundBuilder?.call(context, null, null);
    return notFoundVNode ?? VNode.text('');
  }
}
