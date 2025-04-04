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
- **Renderer (Basic Patching Implemented):**
  - `packages/renderer` provides `render` and internal `_patch` functions.
  - Handles initial rendering and updates via `_patch`.
  - `_createDomElement` helper creates DOM nodes from `VNode` and stores
    reference in `VNode.domNode`.
  - `_patch` function implements basic diffing:
    - Handles node addition/removal/type replacement.
    - Updates text node content.
    - Adds/updates/removes element attributes.
    - Recursively patches children using a basic indexed approach.
- **State Update (Simplified PoC):**
  - `State.setState` triggers a callback mechanism.
  - Renderer receives the callback and re-runs `State.build()`.
  - Renderer now uses the `_patch` function, moving away from full `innerHTML`
    replacement for updates.
  - **Result:** A simple stateful component (like the clock demo) can now
    visually update, albeit inefficiently.
- **Demo Application:**
  - `ClockComponent` demonstrates using `StatefulWidget`, Riverpod
    `StreamProvider`, `setState`, and **building a `VNode`** to display updating
    time (initial state + updates work).

## What's Left to Build (High Level - Framework Focus)

- **Core Framework Implementation:**
  - **Rendering Engine (Diffing):** (Basic implementation done) Refine diffing
    algorithm (e.g., keyed children), optimize patching.
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
- **Basic Diffing/Patching Implemented:** Renderer now performs basic diffing
  for updates instead of full replacement. Handles common cases like
  text/attribute changes and simple child list modifications.
- **Improved WASM Loading:** Loading mechanism remains clean
  (`app_bootstrap.js`).
- **Core Component Structure Updated:** `Component`/`State`/`VNode` structure is
  in place.
- **Renderer Structure Improved:** Introduced `_patch` function and
  `VNode.domNode` linking, providing a better structure for rendering logic.
- **Basic Diffing Algorithm Implemented:** Moved beyond just laying the
  foundation; a simple diffing/patching mechanism is now in place.

## Known Issues / Challenges

- **Renderer Diffing Inefficiency:** The current child diffing algorithm is
  basic (indexed) and can be inefficient for list reordering/insertions. Keyed
  diffing is needed.
- **JS Interop Performance:** Still a consideration for the eventual DOM
  abstraction layer.
- **WASM Debugging:** Remains a factor.
- **Bundle Size:** Needs monitoring as framework grows.
- **Hot Reload Implementation:** Still a significant challenge.
- **Riverpod Integration:** Current demo uses a suboptimal pattern
  (component-level container).
