# Dust Technical Context

## Core Technologies

- **Dart:** The primary language for defining components, application logic, and
  the framework itself.
- **WebAssembly (WASM):** The compilation target for the Dart framework and
  application code, executed via `dart compile wasm`.
- **HTML:** The host environment; the framework renders into a root element
  within the HTML page.
- **CSS:** Used for styling; the framework needs mechanisms to manage
  component-specific styles.
- **JavaScript:**
  - **Bootstrap Loader (`js/app_bootstrap.js`):** A small, hand-written JS
    module responsible for fetching, compiling, and instantiating the WASM
    module, then invoking the Dart `main` function. This avoids modifying the
    auto-generated `main.mjs`.
  - **JS/WASM Bridge:** The auto-generated `wasm/main.mjs` provides the
    necessary bridge functions (imports/exports) for communication between Dart
    (WASM) and JS (including DOM APIs). The framework uses `dart:js_interop` to
    interact with this bridge.
  - **DOM Manipulation:** Currently performed via direct JS interop calls within
    the basic renderer. A Dart DOM abstraction layer is planned.

## Development Environment

- **Dart SDK:** Required for compiling Dart to WASM.
- **Web Server:** A simple server like `dhttpd` is needed to serve files over
  HTTP, avoiding CORS issues when loading WASM/JS modules.
- **Build Tool / Dev Server (Future):** More sophisticated tooling will be
  required for features like hot reload and optimized production builds.
- **Browser Developer Tools:** Essential for debugging (Console, Network,
  Performance tabs).

## Technical Constraints & Considerations (Framework Focus)

- **Browser Compatibility:** Ensure compatibility with modern browsers
  supporting WASM and necessary web APIs.
- **Bundle Size:** WASM bundle size (including Dart runtime) is a key factor.
- **Rendering Performance:** Diffing/patching efficiency is crucial. JS/WASM
  interop overhead for DOM calls must be minimized.
- **State Management Overhead:** Consider performance implications of state
  management solutions.
- **JS Interop Performance:** Minimize calls across the JS/WASM boundary.
- **WASM Debugging:** Can be challenging.
- **Dart Language Features:** Leverage Dart effectively within WASM constraints.
- **Ecosystem Integration:** Ensure compatibility with `pub.dev` packages.
- **Renderer Complexity:** Implementing an efficient diffing renderer is
  complex.

## Dependencies

- **Dart Standard Libraries:** `dart:core`, `dart:async`, etc.
- **`dart:js_interop`:** Core for JS/WASM communication.
- **`package:riverpod`:** Added for state management demonstration (currently
  used sub-optimally in demo).
- **(Framework Internal):** `dust_component`, `dust_renderer` packages. Others
  like `core`, `dom`, `router` planned.
- **(Development):** `dhttpd` for serving files locally. `build_runner` might be
  used later.
- **(Bootstrap):** `js/app_bootstrap.js` (hand-written).
