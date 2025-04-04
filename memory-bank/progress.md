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
- **Component Model (Basic + VNode):**
  - Abstract classes for `Component`, `StatelessWidget`, `StatefulWidget`, and
    `State` defined in `packages/component`.
  - **`VNode` structure defined** in `packages/component/lib/vnode.dart` to
    represent the output of `build`.
  - `State.build()` method now **returns `VNode`**.
  - Basic lifecycle methods (`initState`, `dispose`, `setState`, etc.) defined
    in `State`.
- **Renderer (Very Basic):**
  - `packages/renderer` provides a `render` function.
  - Can handle initial rendering of `StatefulWidget` (creates state, calls
    `initState`, calls `build`).
  - Can render basic **`VNode` representations** (element nodes with direct
    text, ignoring children/attributes for now) to DOM elements.
- **State Update (Simplified PoC):**
  - `State.setState` triggers a callback mechanism.
  - Renderer receives the callback and re-runs `State.build()`.
  - Renderer **replaces the entire content** of the target DOM element with the
    new `VNode` result (no diffing).
  - **Result:** A simple stateful component (like the clock demo) can now
    visually update, albeit inefficiently.
- **Demo Application:**
  - `ClockComponent` demonstrates using `StatefulWidget`, Riverpod
    `StreamProvider`, `setState`, and **building a `VNode`** to display updating
    time (initial state + updates work).

## What's Left to Build (High Level - Framework Focus)

- **Core Framework Implementation:**
  - **Rendering Engine (Diffing):** Replace the simple renderer with one that
    uses a Virtual DOM or similar diffing strategy for efficient DOM updates.
  - **Component Model Refinement:** (`VNode` defined) Handle props, context,
    keys.
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

- **VNode Introduced & Integrated:** Successfully defined `VNode` and updated
  the component model (`State.build`), renderer, and demo (`ClockComponent`) to
  use it.
- **Basic Stateful Update PoC Works with VNode:** Confirmed that the existing
  update mechanism functions correctly with `VNode` as the build output (still
  using full content replacement).
- **Improved WASM Loading:** Loading mechanism remains clean
  (`app_bootstrap.js`).
- **Core Component Structure Updated:** `Component`/`State`/`VNode` structure is
  in place.
- **Renderer Adapted (Still Basic):** The renderer now consumes `VNode` but
  still needs a major overhaul for diffing, attribute/child handling, and event
  handling.
- **Foundation Laid for Diffing:** Introducing `VNode` is the necessary first
  step towards implementing a proper diffing algorithm in the renderer.

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
