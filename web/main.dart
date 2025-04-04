// web/main.dart
// User-facing entry point for the Dust application.

// Import the application's root component
import 'package:dust_app/todo_list.dart';
// Import the Dust framework's runApp function
import 'package:dust_renderer/renderer.dart';

void main() {
  // Create the root component instance
  final app = TodoListComponent();

  // Run the application by mounting the root component to the 'app' element
  runApp(app, 'app');

  // Optional: Add any other application-specific initialization here,
  // but avoid direct DOM manipulation or framework-internal logic.
  print('Dust application started by user code.');
}
