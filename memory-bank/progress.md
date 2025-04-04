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
- **Component Model (VNode + Key + Listeners):**
  - Abstract classes for `Component`, `StatelessWidget`, `StatefulWidget`, and
    `State` defined in `packages/component`.
  - **`VNode` structure defined** with `key`, `listeners`, and `jsFunctionRefs`
    properties added.
  - `State.build()` method returns `VNode`.
  - Basic lifecycle methods defined in `State`.
- **Renderer (Keyed Diffing + Basic Event Handling):**
  - `packages/renderer` provides `render` function.
  - `_patch` function handles node/attribute/listener updates and delegates
    child patching.
  - **`_patchChildren` function implements keyed reconciliation algorithm.**
  - `_createDomElement` helper creates DOM nodes from `VNode`, attaches initial
    listeners (converting callbacks with `.toJS` and storing refs in
    `jsFunctionRefs`), and stores DOM reference in `VNode.domNode`.
  - JS Interop updated for `addEventListener` and `removeEventListener`.
  - **Implemented listener update logic in `_patch`** (adds/updates/removes
    listeners based on stored `jsFunctionRefs`).
- **State Update (Keyed Diffing):**
  - `State.setState` triggers a callback mechanism.
  - Renderer receives the callback, re-runs `State.build()`, and uses `_patch`
    (which calls `_patchChildren`) to apply updates efficiently using keys.
  - **Result:** Stateful components with lists (like `TodoListComponent`) can
    update efficiently, handling additions, removals, and reordering correctly.
- **Demo Application (TodoList - Interactive):**
  - `TodoListComponent` updated to handle user interaction via buttons.
  - Demonstrates using `StatefulWidget`, `setState`, keys in `VNode`, and
    **event listeners** defined in `build()`.
  - **Automatic test timer (`_scheduleTestUpdates`) disabled.**
  - `main.dart` updated to render `TodoListComponent` into `#app` div.
  - `index.html` updated to use `#app` div.

## What's Left to Build (High Level - Framework Focus)

- **Core Framework Implementation:**
  - **Rendering Engine (Diffing):** (Keyed diffing implemented) Further optimize
    patching logic, handle edge cases.
  - **Component Model Refinement:** (`VNode` with `key` defined) Handle props,
    context.
  - **DOM Abstraction:** Create a robust, type-safe Dart layer over DOM
    operations instead of direct JS interop in the renderer.
  - **Event Handling:** (Basic implementation done) Refine listener update
    logic, handle event object wrapping, ensure correct removal.
  - **State Management Integration:** Provide framework-level support for state
    management solutions like Riverpod (e.g., `ProviderScope`, context access).
  - **Routing System:** Implement SPA routing.
- **Developer Experience Tooling:**
  - **Build System:** Integrate with `build_runner` or create custom tools for
    optimized builds.
  - **Development Server:** Implement hot reload/hot restart.
- **Documentation & Examples:** Expand significantly.

## Current Status

- **Basic Event Handling Implemented & Tested:** Added `listeners` to `VNode`,
  updated renderer (`_createDomElement`, `_patch`) to attach/update/remove
  listeners using `.toJS` and stored references. Verified with interactive
  buttons in `TodoListComponent`.
- **JS Interop for Events Resolved:** Confirmed `.toJS` extension method is the
  correct approach for WASM event listeners.
- **(Previous) Keyed Diffing Implemented & Tested.**
- **(Previous) Renderer Refactored for Diffing.**
- **(Previous) Demo Updated for Diffing.**
- **(Previous) VNode Introduced & Integrated.**
- **(Previous) Basic Patching Foundation Laid.**
- **Improved WASM Loading:** Loading mechanism remains clean
  (`app_bootstrap.js`).
- **Core Component Structure Updated:** `Component`/`State`/`VNode` structure is
  in place.
- **Renderer Structure Improved:** Introduced `_patch` function and
  `VNode.domNode` linking, providing a better structure for rendering logic.
- **Keyed Diffing Algorithm Implemented:** Replaced basic indexed approach.

## Known Issues / Challenges

- **Event Handling Refinement:** Current listener update/removal logic in
  `_patch` needs further testing and potential optimization (e.g., more robust
  function comparison). Storing/retrieving `JSFunction` refs seems to work but
  needs care.
- **Renderer Optimization:** Keyed diffing is implemented but can likely be
  further optimized.
- **JS Interop Performance:** Still a consideration for the eventual DOM
  abstraction layer.
- **WASM Debugging:** Remains a factor.
- **Bundle Size:** Needs monitoring as framework grows.
- **Hot Reload Implementation:** Still a significant challenge.
- **Riverpod Integration:** Current demo uses a suboptimal pattern
  (component-level container).
