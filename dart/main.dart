// dart/main.dart
// library main; // Removed

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
  // Add definitions for the new framework API functions
  external JSBoolean dartScriptSetText(JSString selector, JSString text);
  external JSString? dartScriptGetText(JSString selector);
  external JSBoolean dartScriptSetHtml(JSString selector, JSString html);
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

// --- DartScript Framework API Wrappers (Static Class) ---
class DartScriptApi {
  /// Sets the text content of the element matching the selector.
  /// Returns true if successful, false otherwise (element not found or error).
  static bool setText(String selector, String text) {
    try {
      final result = window.dartScriptSetText(selector.toJS, text.toJS);
      return result.toDart;
    } catch (e) {
      print('Dart Error in setText($selector): $e');
      return false;
    }
  }

  /// Gets the text content of the element matching the selector.
  /// Returns the text content, or null if the element is not found or an error occurs.
  static String? getText(String selector) {
    try {
      final result = window.dartScriptGetText(selector.toJS);
      // Check if the JS function returned null (or undefined)
      if (result == null) {
        return null;
      }
      return result.toDart;
    } catch (e) {
      print('Dart Error in getText($selector): $e');
      return null;
    }
  }

  /// Sets the inner HTML of the element matching the selector.
  /// Returns true if successful, false otherwise (element not found or error).
  static bool setHtml(String selector, String html) {
    try {
      final result = window.dartScriptSetHtml(selector.toJS, html.toJS);
      return result.toDart;
    } catch (e) {
      print('Dart Error in setHtml($selector): $e');
      return false;
    }
  }
}

// --- Main Entry Point ---
// Called automatically by WASM loader
void main() {
  print('Dart WASM module main() executed.');

  // Removed code that called window.dartScriptGetCode() as inline execution
  // is no longer supported.
  // This main function will be the entry point for WASM modules loaded via src.
  // Framework-specific initialization or API setup might happen here later.

  // Example: Use the new DartScript framework API wrappers via the static class
  print('Dart: Demonstrating DartScript API wrappers...');

  // 1. Set initial text using DartScriptApi.setText
  bool success = DartScriptApi.setText(
    '#output',
    'Initial text set by Dart setText.',
  );
  print('Dart: DartScriptApi.setText(\'#output\', ...) success: $success');

  // 2. Get the text using DartScriptApi.getText
  String? currentText = DartScriptApi.getText('#output');
  print('Dart: DartScriptApi.getText(\'#output\') result: $currentText');

  // 3. Append to the text
  if (currentText != null) {
    success = DartScriptApi.setText('#output', '$currentText Appended text.');
    print('Dart: DartScriptApi.setText (append) success: $success');
  } else {
    print('Dart: Skipping append because getText failed.');
  }

  // 4. Set HTML using DartScriptApi.setHtml
  success = DartScriptApi.setHtml(
    '#output',
    '<strong>HTML</strong> set by Dart <em>setHtml</em>.',
  );
  print('Dart: DartScriptApi.setHtml(\'#output\', ...) success: $success');

  // 5. Try getting text from a non-existent element
  currentText = DartScriptApi.getText('#non-existent');
  print(
    'Dart: DartScriptApi.getText(\'#non-existent\') result: $currentText',
  ); // Should be null

  // 6. Try setting text on a non-existent element
  success = DartScriptApi.setText('#non-existent', 'This should fail');
  print(
    'Dart: DartScriptApi.setText(\'#non-existent\', ...) success: $success',
  ); // Should be false
}
