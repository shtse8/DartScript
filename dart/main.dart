// dart/main.dart
@JS()
library main;

import 'dart:js_interop';
import 'dart:async'; // Import for Timer

// --- JS Interop Definitions ---

@JS('window')
external JSWindow get window;

@JS()
@staticInterop
class JSWindow {}

extension JSWindowExtension on JSWindow {
  external JSDocument get document;
  external JSConsole get console;
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

// --- Target Dart Function ---

// Function to update the DOM
void runDomUpdate() {
  print('Dart runDomUpdate() called via Timer.run.');
  try {
    final document = window.document;
    final outputDiv = document.querySelector('#output'.toJS);

    if (outputDiv != null) {
      outputDiv.textContent = 'Hello from Dart WASM! 👋 (Timer.run)'.toJS;
      print('Updated output div.');
    } else {
      print('Error: Could not find element with ID #output in runDomUpdate()');
      window.console.error(
        'Dart Error: Could not find #output div in runDomUpdate()'.toJS,
      );
    }
  } catch (e) {
    print('Error during runDomUpdate: $e');
    try {
      window.console.error(
        'Dart Error during runDomUpdate: ${e.toString()}'.toJS,
      );
    } catch (consoleErr) {
      print('Could not log runDomUpdate error to JS console: $consoleErr');
    }
  }
}

// --- Main Entry Point ---
void main() {
  print('Dart WASM module initialized (scheduling update).');
  // Schedule the DOM update to run asynchronously after main completes
  Timer.run(() {
    runDomUpdate();
  });
  print('DOM update scheduled.');
}
