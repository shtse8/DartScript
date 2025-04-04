// lib/main.dart
// Main entry point for the Dust application.

import 'dart:js_interop';

import 'package:dust_app/todo_list.dart'; // Import the new TodoListComponent
import 'package:dust_renderer/renderer.dart'; // Import the render function via package URI

// --- JS Interop for console.log ---
@JS('console.log')
external void consoleLog(JSAny? message);
// --- End JS Interop ---

// --- Main Entry Point ---
// Called automatically by WASM loader
void main() {
  // Use console.log for more direct browser output
  consoleLog('>>> Dust Application main() started via JS Interop'.toJS);

  print(
      'Dust Application main() executed (Dart print).'); // Keep Dart print too

  // 1. Create an instance of the root component
  final app = TodoListComponent(); // Use TodoListComponent
  consoleLog('>>> TodoListComponent instance created.'.toJS);

  // 2. Render the component into the target element
  //    The target element ID comes from index.html
  consoleLog('>>> Calling render function...'.toJS);
  try {
    render(app, 'app'); // Render into the 'app' div
    consoleLog('>>> render function finished.'.toJS);
  } catch (e, s) {
    consoleLog('>>> ERROR during render:'.toJS);
    consoleLog(e.toString().toJS); // Log error message
    consoleLog(s.toString().toJS); // Log stack trace
  }

  print('Dust application rendering initiated (Dart print).');
  consoleLog('>>> Dust Application main() finished.'.toJS);
}

// Removed old DartScriptApi and related JS interop definitions
// as rendering logic is now handled by the renderer package.
// The renderer package itself uses js_interop for DOM manipulation.
