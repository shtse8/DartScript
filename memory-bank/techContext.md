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
  - **Bootstrap Loader:** Previously `js/app_bootstrap.js`. Now, `build_runner`
    generates the necessary JS loader (`web/main.dart.js`) which handles WASM
    loading and initialization based on the compiled output. The original
    `js/app_bootstrap.js` is currently unused in the `build_runner` workflow.
  - **JS/WASM Bridge:** The auto-generated `wasm/main.mjs` provides the
    necessary bridge functions (imports/exports) for communication between Dart
    (WASM) and JS (including DOM APIs). The framework uses `dart:js_interop` to
    interact with this bridge.
  - **DOM Manipulation & Event Handling:** Performed via direct JS interop calls
    (`JSAnyExtension`, including `addEventListener`/`removeEventListener`)
    within the renderer (`_createDomElement`, `_patch`). Dart callbacks
    (accepting `DomEvent`) are wrapped in a JS function and passed to JS using
    the `.toJS` extension method. Introduced `DomEvent` wrapper
    (`packages/renderer/lib/dom_event.dart`). A Dart DOM abstraction layer is
    planned.

## Development Environment

- **Dart SDK:** Required for compiling Dart to WASM.
- **Development Server:** `dart run build_runner serve web` is now used. It
  compiles Dart to WASM, serves the `web` directory, and provides Hot Restart
  functionality. Replaces the need for `dhttpd` during development.
- **Build Tool:** `build_runner` and `build_web_compilers` are used for the
  development build process.
- **Browser Developer Tools:** Essential for debugging (Console, Network,
  Performance tabs).

## Technical Constraints & Considerations (Framework Focus)

- **Browser Compatibility:** Ensure compatibility with modern browsers
  supporting WASM and necessary web APIs.
- **Bundle Size:** WASM bundle size (including Dart runtime) is a key factor.
- **Rendering Performance:** Keyed diffing implemented, but efficiency of the
  algorithm and JS/WASM interop overhead for DOM calls remain important.
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
- **`dart:js_interop`:** Core for JS/WASM communication (including `.toJS` for
  callbacks).
- **`package:riverpod`:** Added for state management demonstration (currently
  used sub-optimally in demo).
- **(Framework Internal):**
  - `dust_component`: Defines core `Component`, `State`, `StatelessWidget`,
    `StatefulWidget`, and `VNode` (now including `key`, `listeners` using
    `DomEvent`, `jsFunctionRefs`). Depends on `dust_renderer`.
  - `dust_renderer`: Depends on `dust_component` (including `VNode`) to render
    component output using keyed diffing (`_patch`, `_patchChildren`) and event
    listener management (including `DomEvent` wrapper). Uses `JSAnyExtension`
    for DOM manipulation.
  - Others like `core`, `dom`, `router` planned.
- **(Development):** `build_runner` and `build_web_compilers` are now the
  primary development dependencies for serving and building the web app.
- **(Bootstrap):** `build_runner` generates the necessary bootstrap JS
  (`web/main.dart.js`). The hand-written `js/app_bootstrap.js` is currently
  unused.
