// lib/main.dart
// Main entry point for the Dust application.

import 'dart:js_interop';

import 'package:dust_app/hello_world.dart'; // Import from our own package
import 'package:dust_renderer/renderer.dart'; // Import the render function via package URI

// --- Main Entry Point ---
// Called automatically by WASM loader
void main() {
  print('Dust Application main() executed.');

  // 1. Create an instance of the root component
  final app = HelloWorld();

  // 2. Render the component into the target element
  //    The target element ID comes from index.html
  render(app, 'output'); // Use the render function from the renderer package

  print('Dust application rendering initiated.');
}

// Removed old DartScriptApi and related JS interop definitions
// as rendering logic is now handled by the renderer package.
// The renderer package itself uses js_interop for DOM manipulation.
