// dart/main.dart
library main;

import 'dart:js_interop';
import 'dart:async'; // Keep for potential future async operations

// --- JS Interop Definitions ---

@JS('window')
external JSWindow get window;

@JS()
@staticInterop
class JSWindow {}

// Add the definition for the function we expect on the JS window object
extension JSWindowExtension on JSWindow {
  external JSDocument get document;
  external JSConsole get console;
  // dartScriptGetCode removed - no longer calling this JS function
  // Add definition for the new framework API function
  external void dartScriptSetText(JSString selector, JSString text);
}

@JS()
@staticInterop
class JSDocument {}

extension JSDocumentExtension on JSDocument {
  external JSElement? querySelector(JSString selector);
}

@JS()
@staticInterop
class JSElement {}

extension JSElementExtension on JSElement {
  external set textContent(JSString text);
}

@JS()
@staticInterop
class JSConsole {}

extension JSConsoleExtension on JSConsole {
  external void error(JSAny? message);
}

// Helper function (less critical now, but keep for potential future use)
String _getJsTypeString(JSAny? obj) {
  if (obj == null) return 'null';
  // This check might not be reliable for JS strings via interop
  return obj.instanceOfString == true ? 'string' : 'other';
}

// --- Main Entry Point ---
// Called automatically by WASM loader
void main() {
  print('Dart WASM module main() executed.');

  // Removed code that called window.dartScriptGetCode() as inline execution
  // is no longer supported.
  // This main function will be the entry point for WASM modules loaded via src.
  // Framework-specific initialization or API setup might happen here later.

  // Example: Use the new DartScript framework API to update the output div
  try {
    print('Dart: Calling window.dartScriptSetText to update #output...');
    window.dartScriptSetText(
      '#output'.toJS, // Selector
      'Hello from Dart WASM (via dartScriptSetText)!'.toJS, // Text
    );
    print('Dart: window.dartScriptSetText called successfully.');
  } catch (e) {
    print('Dart: Error calling window.dartScriptSetText: $e');
    try {
      // Attempt to log the error to the JS console as a fallback
      window.console.error(
        'Dart Error calling dartScriptSetText: ${e.toString()}'.toJS,
      );
    } catch (consoleErr) {
      print(
        'Dart: Could not log dartScriptSetText error to JS console: $consoleErr',
      );
    }
  }
}
