// web/main.dart
// User-facing entry point for the Dust application.

// Import components and providers
import 'package:dust_app/hello_world.dart'; // Import HelloWorld and messageProvider
import 'package:dust_app/prop_tester.dart'; // Import PropTester (contains HelloWorld)
import 'package:dust_component/provider_scope.dart'; // Import ProviderScope
import 'package:riverpod/riverpod.dart'; // Import riverpod for Override
// Import the Dust framework's runApp function
import 'package:dust_renderer/renderer.dart';

void main() {
  // Create the root component instance
  // Create the root component instance with a name prop
  // Create the root component instance, passing name via props map
  // Create the PropTester instance (which includes HelloWorld)
  final propTesterApp = PropTester();

  // Create a ProviderScope to override the messageProvider for the PropTester subtree
  final scopedApp = ProviderScope(
    overrides: [
      // Override the messageProvider defined in hello_world.dart
      messageProvider.overrideWithValue('Message from ProviderScope!'),
    ],
    child: propTesterApp, // Wrap the original app
  );

  // Run the application with the ProviderScope as the root
  runApp(scopedApp, 'app');

  // Optional: Add any other application-specific initialization here,
  // but avoid direct DOM manipulation or framework-internal logic.
  print('Dust application started by user code.');
}
