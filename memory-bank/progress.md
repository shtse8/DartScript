# Dust Progress

## What Works (Foundational Elements & Basic Update PoC)

- **Memory Bank Established:** Core documentation structure created and updated.
- **Core WASM Capabilities Proven (PoC):**
  - Basic Dart-to-WASM compilation (`dart compile wasm`).
  - WASM module loading via dedicated JS bootstrap (`js/app_bootstrap.js`).
  - Basic JS/WASM communication (JS loads WASM, invokes Dart `main`).
- **Basic DOM Interaction Layer:**
  - JS functions for DOM manipulation available via `dart:js_interop` in the
    basic renderer.
- **WASM Loading Mechanism:**
  - `js/app_bootstrap.js` handles fetching, compiling, instantiating WASM, and
    calling Dart `main`.
  - `index.html` correctly loads the bootstrap script.
- **Component Model (Basic):**
  - Abstract classes for `Component`, `StatelessWidget`, `StatefulWidget`, and
    `State` defined in `packages/component`.
  - Basic lifecycle methods (`initState`, `dispose`, `build`, `setState`,
    `frameworkUpdateWidget`) defined in `State`.
- **Renderer (Very Basic):**
  - `packages/renderer` provides a `render` function.
  - Can handle initial rendering of `StatefulWidget` (creates state, calls
    `initState`, calls `build`).
  - Can render basic `Map<String, String>` representations
    (`{'tag': '...', 'text': '...'}`) to DOM elements.
- **State Update (Simplified PoC):**
  - `State.setState` triggers a callback mechanism.
  - Renderer receives the callback and re-runs `State.build()`.
  - Renderer **replaces the entire content** of the target DOM element with the
    new result (no diffing).
  - **Result:** A simple stateful component (like the clock demo) can now
    visually update, albeit inefficiently.
- **Demo Application:**
  - `ClockComponent` demonstrates using `StatefulWidget`, Riverpod
    `StreamProvider`, and `setState` to display updating time (initial state +
    updates work).

## What's Left to Build (High Level - Framework Focus)

- **Core Framework Implementation:**
  - **Rendering Engine (Diffing):** Replace the simple renderer with one that
    uses a Virtual DOM or similar diffing strategy for efficient DOM updates.
  - **Component Model Refinement:** Define `build()` return types (e.g.,
    `VNode`), handle props, context.
  - **DOM Abstraction:** Create a robust, type-safe Dart layer over DOM
    operations instead of direct JS interop in the renderer.
  - **Event Handling:** Implement DOM event listeners and dispatching to Dart
    components.
  - **State Management Integration:** Provide framework-level support for state
    management solutions like Riverpod (e.g., `ProviderScope`, context access).
  - **Routing System:** Implement SPA routing.
- **Developer Experience Tooling:**
  - **Build System:** Integrate with `build_runner` or create custom tools for
    optimized builds.
  - **Development Server:** Implement hot reload/hot restart.
- **Documentation & Examples:** Expand significantly.

## Current Status

- **Basic Stateful Update PoC Complete:** Successfully demonstrated that a
  `StatefulWidget` can be rendered, receive external updates (via Riverpod
  stream), trigger `setState`, and have the UI update (via simplified renderer).
- **Improved WASM Loading:** Loading mechanism is cleaner using
  `app_bootstrap.js`.
- **Core Component Structure Defined:** Basic `Component`/`State` classes are in
  place.
- **Renderer Needs Major Overhaul:** The current renderer is a placeholder
  proving basic concepts but lacks efficiency (no diffing) and features (event
  handling, complex children).
- **Ready for Renderer Enhancement:** The next major step is to build a more
  sophisticated rendering engine.

## Known Issues / Challenges

- **Renderer Inefficiency:** Current full-content replacement on update is not
  performant.
- **JS Interop Performance:** Still a consideration for the eventual DOM
  abstraction layer.
- **WASM Debugging:** Remains a factor.
- **Bundle Size:** Needs monitoring as framework grows.
- **Hot Reload Implementation:** Still a significant challenge.
- **Riverpod Integration:** Current demo uses a suboptimal pattern
  (component-level container).
