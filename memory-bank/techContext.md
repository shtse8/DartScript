# DartScript Technical Context

## Core Technologies

- **Dart:** The primary programming language to be executed in the browser.
- **WebAssembly (WASM):** The compilation target for the Dart runtime, enabling
  near-native performance in the browser.
- **HTML:** Used for structuring the web page and embedding Dart code via custom
  tags (`<dart-script>`).
- **CSS:** Used for styling the web page elements potentially manipulated by
  Dart.
- **JavaScript:** Required for the bridging layer between WASM and the browser
  APIs (DOM, events, etc.) and for the initial script that loads and manages the
  Dart WASM runtime.

## Development Environment

- **Dart SDK:** Essential for compiling Dart to WASM (`dart compile wasm` or
  similar). Specific version requirements TBD.
- **Web Server:** A simple local web server will be needed for development to
  serve HTML files and WASM modules (due to browser security restrictions on
  `file://` URLs).
- **Browser Developer Tools:** Crucial for debugging both the JavaScript bridge
  and the Dart code (browser support for WASM debugging varies).

## Technical Constraints

- **Browser Compatibility:** WASM support is widespread, but specific features
  or performance characteristics might vary. Need to define target browsers.
- **WASM Module Size:** The compiled Dart runtime could be large, impacting
  initial load times. Optimization will be critical.
- **Performance:** While WASM is fast, the overhead of the JS/WASM bridge and
  DOM manipulation needs careful management.
- **Security:** Code runs in the browser's sandbox, but care must be taken with
  DOM access and potential interactions with external resources.
- **Dart Language Subset:** Initial versions might only support a subset of the
  Dart language or standard libraries due to WASM compilation limitations or the
  complexity of browser integration.

## Dependencies

- **Dart Standard Libraries:** Core libraries needed for basic functionality.
- **`dart:js_interop` (or similar):** Likely needed for communication between
  Dart and JavaScript.
- **(Potentially) JavaScript libraries:** May need small JS helper libraries for
  the custom element or runtime loading.
