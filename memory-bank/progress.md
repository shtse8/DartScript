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
- **Component Model (VNode + Key):**
  - Abstract classes for `Component`, `StatelessWidget`, `StatefulWidget`, and
    `State` defined in `packages/component`.
  - **`VNode` structure defined** with `key` property added.
  - `State.build()` method returns `VNode`.
  - Basic lifecycle methods defined in `State`.
- **Renderer (Keyed Diffing Implemented):**
  - `packages/renderer` provides `render` function.
  - `_patch` function handles node/attribute updates and delegates child
    patching.
  - **`_patchChildren` function implements keyed reconciliation algorithm.**
  - `_createDomElement` helper creates DOM nodes from `VNode` and stores
    reference in `VNode.domNode`.
  - JS Interop updated for `insertBefore` and `tagName`.
  - Detailed logging added for debugging diffing.
- **State Update (Keyed Diffing):**
  - `State.setState` triggers a callback mechanism.
  - Renderer receives the callback, re-runs `State.build()`, and uses `_patch`
    (which calls `_patchChildren`) to apply updates efficiently using keys.
  - **Result:** Stateful components with lists (like `TodoListComponent`) can
    update efficiently, handling additions, removals, and reordering correctly.
- **Demo Application (TodoList):**
  - `TodoListComponent` created to specifically test keyed diffing.
  - Demonstrates using `StatefulWidget`, `setState`, keys in `VNode`, and
    automatic updates via `Timer`.
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

- **Keyed Diffing Implemented & Tested:** Successfully added `key` to `VNode`,
  implemented keyed reconciliation in `_patchChildren`, and verified with
  `TodoListComponent`.
- **Renderer Refactored:** `_patch` now delegates child patching to
  `_patchChildren`. JS Interop and logging improved.
- **Demo Updated:** Switched from `ClockComponent` to `TodoListComponent` to
  test list diffing. Target element ID standardized to `app`.
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

- **Event Handling:** Not yet implemented, preventing user interaction with
  demos.
- **Renderer Optimization:** Keyed diffing is implemented but can likely be
  further optimized.
- **JS Interop Performance:** Still a consideration for the eventual DOM
  abstraction layer.
- **WASM Debugging:** Remains a factor.
- **Bundle Size:** Needs monitoring as framework grows.
- **Hot Reload Implementation:** Still a significant challenge.
- **Riverpod Integration:** Current demo uses a suboptimal pattern
  (component-level container).
