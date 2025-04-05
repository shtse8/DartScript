// web/main.dart
// User-facing entry point for the Dust application.

// Import components and providers
import 'package:dust_app/hello_world.dart'; // Import HelloWorld and messageProvider
import 'package:dust_app/prop_tester.dart'; // Import PropTester
import 'package:dust_app/user_page.dart'; // Import UserPage

import 'package:dust_component/component.dart'; // Correct import path for core components
import 'package:dust_component/html.dart' as html; // Import html helpers
import 'package:dust_router/dust_router.dart'; // Import the router
// Import the Dust framework's runApp function
import 'package:dust_renderer/renderer.dart';

// Simple Home Component
class Home extends StatelessWidget<Props?> {
  // Specify Props type argument
  // Add constructor to call super
  const Home({super.key})
      : super(props: null); // Pass null for props as Home doesn't use them

  @override
  VNode? build(BuildContext context) {
    // Correct return type to VNode?
    return html.div(
      children: [
        html.h1(children: [html.text('Home Page')]), // Use html.text
        Link(
            props: LinkProps(
                to: '/tester',
                child: html.text('Go to Prop Tester'))), // Use html.text
        Link(
            props: LinkProps(
                to: '/users/123', // Link to a sample user page
                child: html.text('Go to User 123 Page'))), // Use html.text
      ],
    );
  }
}

void main() {
  // Create the root component instance
  // Create the root component instance with a name prop
  // Create the root component instance, passing name via props map
  // Create the PropTester instance (which includes HelloWorld)
  // Define the routes
  final routes = [
    Route(
        path: '/',
        builder: (context, params) => // Add params argument
            VNode.component(Home())), // Wrap in VNode.component
    Route(
        path: '/tester',
        builder: (context, params) => // Add params argument
            VNode.component(PropTester())), // Wrap in VNode.component
    // Add more routes here
    Route(
      path: '/users/:id', // Parameterized route
      builder: (context, params) {
        final userId =
            params?['id'] ?? 'unknown'; // Extract ID, provide default
        return VNode.component(UserPage(props: UserPageProps(userId: userId)));
      },
    ),
  ];

  // Create the Router component
  final routerApp = Router(
    props: RouterProps(
      routes: routes,
      // Correctly use html.text and ensure VNode? return type for the builder
      notFoundBuilder: (BuildContext context, Map<String, String>? params) {
        // Add params argument
        return html.div(children: [html.text('404 - Not Found')]);
      },
    ),
  );

  // Create a ProviderScope to wrap the Router, passing props
  final scopedApp = ProviderScope(
    props: ProviderScopeProps(
      // Create ProviderScopeProps
      overrides: [
        // Override the messageProvider defined in hello_world.dart
        // This will now apply to all routes under this scope
        messageProvider.overrideWithValue('Message from ProviderScope!'),
      ],
      child: routerApp, // Pass routerApp as child
    ),
  );

  // Run the application with the scoped router as the root
  runApp(scopedApp, 'app');

  // Optional: Add any other application-specific initialization here,
  // but avoid direct DOM manipulation or framework-internal logic.
  print('Dust application started by user code.');
}
