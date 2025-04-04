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
  external JSFunction get dartScriptGetCode; // Expect this function in JS
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

  try {
    print('Dart: Attempting to call window.dartScriptGetCode()...');
    // Call the JS function defined in loader.js
    final JSAny? codeResult = window.dartScriptGetCode.callAsFunction();

    String? dartCode;
    String receivedType = 'null';

    // Try converting/casting to string directly
    if (codeResult != null) {
      try {
        // Attempt direct cast and conversion
        dartCode = (codeResult as JSString).toDart;
        receivedType = 'string (via cast)';
      } catch (castError) {
        // If cast fails, get type string for logging
        receivedType = _getJsTypeString(codeResult);
        print('Dart: Failed to cast JS result to JSString: $castError');
      }
    }

    // Check if we successfully got a Dart string
    if (dartCode != null) {
      print('--- Dart received code from JS ---');
      print(dartCode);
      print('----------------------------------');

      // Update the DOM to show the received code
      final outputDiv = window.document.querySelector('#output'.toJS);
      if (outputDiv != null) {
        outputDiv.textContent = 'Dart received code:\n${dartCode}'.toJS;
      } else {
        print('Error: Could not find #output div in main.');
        window.console.error('Dart Error: Could not find #output div.'.toJS);
      }
    } else {
      // Log error if conversion failed
      print(
        'Error: window.dartScriptGetCode() did not yield a Dart string. Received type: $receivedType',
      );
      window.console.error(
        'Dart Error: window.dartScriptGetCode() did not yield a Dart string.'
            .toJS,
      );
    }
  } catch (e) {
    print('Error calling window.dartScriptGetCode() or processing result: $e');
    try {
      window.console.error('Dart Error calling JS: ${e.toString()}'.toJS);
    } catch (consoleErr) {
      print('Could not log main error to JS console: $consoleErr');
    }
  }
}
