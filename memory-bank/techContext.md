# DartScript Technical Context

## Core Technologies

- **Dart:** The primary language for defining components, application logic, and
  the framework itself.
- **WebAssembly (WASM):** The compilation target for the Dart framework and
  application code, executed via `dart compile wasm`.
- **HTML:** The host environment; the framework will render into a root element
  within the HTML page.
- **CSS:** Used for styling; the framework needs mechanisms to manage
  component-specific styles (e.g., scoped CSS, CSS-in-Dart).
- **JavaScript:** Essential for the WASM loader, the JS/WASM bridge (optimized
  for framework operations like batch DOM updates and event handling), and
  potential integration with existing JS libraries.

## Development Environment

- **Dart SDK:** Required for compiling Dart to WASM. Version needs to support
  the latest WASM features and `js_interop`.
- **Build Tool / Development Server:** More sophisticated tooling will be
  required beyond a simple web server. Needs to support:
  - Serving application files.
  - Potentially integrating with the Dart compiler.
  - **(Goal)** Enabling features like Hot Reload for rapid development cycles.
  - Production build optimizations (tree shaking, minification).
- **Browser Developer Tools:** Essential for debugging Dart WASM code, JS bridge
  interactions, performance profiling, and DOM inspection.

## Technical Constraints & Considerations (Framework Focus)

- **Browser Compatibility:** Ensure compatibility with modern browsers
  supporting WASM and necessary web APIs.
- **Bundle Size:** The combined size of the framework runtime and application
  code compiled to WASM is a critical factor for initial load time. Aggressive
  optimization and code splitting might be necessary.
- **Rendering Performance:** The efficiency of the rendering engine (e.g.,
  Virtual DOM diffing and patching) directly impacts UI responsiveness. JS/WASM
  interop overhead for DOM manipulation must be minimized.
- **State Management Overhead:** Complex state management can introduce
  performance bottlenecks if not implemented carefully.
- **JS Interop Performance:** Calls across the JS/WASM boundary have overhead.
  The bridge design must minimize frequent or expensive calls, especially within
  tight loops like rendering.
- **WASM Debugging:** While improving, debugging WASM can still be more
  challenging than debugging JavaScript.
- **Dart Language Features:** Ensure the framework leverages modern Dart
  features effectively while considering WASM compilation limitations.
- **Ecosystem Integration:** How easily can the framework integrate with
  existing Dart packages (`pub.dev`)?

## Dependencies

- **Dart Standard Libraries:** Core libraries (`dart:core`, `dart:html` via
  abstraction, `dart:async`, etc.).
- **`dart:js_interop`:** Crucial for the JS/WASM communication bridge.
- **(Framework Internal):** The framework itself will consist of multiple
  internal packages (e.g., `core`, `renderer`, `router`, `state`).
- **(Potentially) Build Tools:** May rely on or integrate with existing Dart
  build tools (e.g., `build_runner`) or require custom build scripts.
- **(Potentially) JS Helper Libraries:** Minimal JS required for loading the
  WASM module and providing optimized bridge functions.
