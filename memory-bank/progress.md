# Dust Progress

## What Works (Foundational Elements & Basic Update PoC)

- **Memory Bank Established:** Core documentation structure created and updated.
- **Core WASM Capabilities Proven (PoC):**
  - Basic Dart-to-WASM compilation (`dart compile wasm`).
  - WASM module loading via dedicated JS bootstrap (`js/app_bootstrap.js`).
  - Basic JS/WASM communication (JS loads WASM, invokes Dart `main`).
- **DOM Abstraction Layer (`dust_dom`):**
  - Created `packages/dom` with initial `@staticInterop` abstractions for
    `DomNode`, `DomElement`, `DomTextNode`, `DomDocument`.
  - Added as dependency to root and renderer.
- **Basic DOM Interaction Layer:** (Being replaced by `dust_dom`)
  - JS functions for DOM manipulation available via `dart:js_interop` in the
    basic renderer (partially replaced).
- **WASM Loading Mechanism:**
  - `js/app_bootstrap.js` handles fetching, compiling, instantiating WASM, and
    calling Dart `main`.
  - `index.html` correctly loads the bootstrap script.
- **Component Model (VNode + Key + Component Lifecycle Support):**
  - Abstract classes for `Component` (now with `key`), `StatelessWidget`,
    `StatefulWidget`, and `State` defined. `key.dart` created.
  - **`VNode` structure updated:** Added `VNode.component` constructor,
    `component`, `state`, and `renderedVNode` properties.
  - HTML Helpers (`html.dart`) updated to accept `Component` as children.
  - `State.build()` and `StatelessWidget.build()` return `VNode`.
  - Lifecycle methods (`initState`, `didUpdateWidget`, `dispose`) defined in
    `State`.
- **Renderer (Component Lifecycle + Keyed Diffing + Event Handling):**
  - `packages/renderer` provides `runApp` function.
  - **Implemented Basic Component Lifecycle:**
    - `_patch` function refactored to differentiate component VNodes from
      element/text VNodes.
    - Implemented `_mountComponent` (creates State, calls initState/build,
      patches rendered tree).
    - Implemented `_updateComponent` (reuses State, calls didUpdateWidget/build,
      patches rendered tree).
    - Implemented `_unmountComponent` (calls dispose, recursively unmounts
      rendered tree using `removeVNode`).
  - **Refined Event Handling:** Includes `DomEvent` wrapper and recursive
    listener removal during unmount/node removal via `removeVNode` (now a
    top-level helper). Listener updates in `_patch` use always remove/add
    strategy.
  - **Keyed Diffing:** `_patchChildren` implements keyed reconciliation.
  - **DOM Interaction:** Uses `dust_dom` abstractions and `_createDomElement`
    helper.
- **State Update (Keyed Diffing & setState):**
  - **`setState` triggers update:** `State.setState` now correctly triggers the
    `_updateRequester` callback provided by the renderer during mount.
  - **Renderer handles update:** The callback in `_mountComponent` calls `build`
    on the state and then calls `_patch` to diff the new rendered tree against
    the old one, applying updates to the DOM.
  - **Keyed diffing for children:** `_patchChildren` ensures efficient updates
    for lists.
  - **Result:** Stateful components (like `TodoListComponent`) now correctly
    update their UI in response to `setState` calls, handling additions,
    removals, toggles, and reordering.
- **Demo Application (TodoList - Interactive with DomEvent):**
  - `TodoListComponent` updated to handle user interaction via buttons.
  - Demonstrates using `StatefulWidget`, `setState`, keys in `VNode`, and
    **event listeners** defined in `build()` (now using `DomEvent`).
  - **Automatic test timer (`_scheduleTestUpdates`) disabled.**
  - `main.dart` updated to render `TodoListComponent` into `#app` div.
  - `index.html` updated to use `#app` div.

## What's Left to Build (High Level - Framework Focus)

- **Core Framework Implementation:**
  - **Rendering Engine (Diffing):** (Keyed diffing implemented) Further optimize
    patching logic, handle edge cases.
  - **Component Model Refinement:** (`VNode` structure updated, `key` added)
    Handle props, refine context usage.
  - **DOM Abstraction:** (`dust_dom` created) Integration mostly complete in
    core rendering path.
  - **Event Handling:** (Refined) Listener update logic improved, `DomEvent`
    wrapper implemented. Further testing on removal reliability and wrapper
    performance needed.
  - **State Management Integration:** Provide framework-level support for state
    management solutions like Riverpod (e.g., `ProviderScope`, context access).
  - **Routing System:** Implement SPA routing.
- **Developer Experience Tooling:**
  - **Build System:** Integrate with `build_runner` or create custom tools for
    optimized builds.
  - **Development Server:** Implement hot reload/hot restart.
- **Documentation & Examples:** Expand significantly.

## Current Status

- **DOM Abstraction Started:**
  - Created `dust_dom` package with basic static interop classes.
  - Started integrating `dust_dom` into the renderer, replacing some direct JS
    calls.
  - Successfully compiled WASM after initial integration.
- **Event Handling Refined:**
  - Implemented `DomEvent` wrapper for type safety.
  - Improved listener update logic in `_patch` for robustness.
  - **Implemented recursive listener removal in `removeVNode`** ensuring cleanup
    before DOM node detachment.
  - Updated relevant components/demos (`VNode`, `renderer`,
    `TodoListComponent`).
- **JS Interop for Events Resolved:** Confirmed `.toJS` extension method is the
  correct approach for WASM event listeners (still used for callback
  conversion).
- **(Previous) Keyed Diffing Implemented & Tested.**
- **(Previous) Renderer Refactored for Diffing.**
- **(Previous) Demo Updated for Diffing.**
- **(Previous) VNode Introduced & Integrated.**
- **(Previous) Basic Patching Foundation Laid.**
- **Improved WASM Loading:** Loading mechanism remains clean
  (`app_bootstrap.js`).
- **Core Component Structure Updated:** `Component` (with `key`), `State`,
  `VNode` (with `component`, `state`, `renderedVNode`) structure updated. HTML
  helpers support components.
- **Renderer Structure Improved:** Refactored `_patch` to handle component
  lifecycle via `_mountComponent`, `_updateComponent`, `_unmountComponent`.
  Listener/node removal helpers moved to top level.
- **Keyed Diffing Algorithm Implemented.**

## Known Issues / Challenges

- **Component Lifecycle & `setState`:** Basic mount/update/dispose implemented.
  `setState` now correctly triggers component updates via the renderer's
  patching mechanism. Fragment/multi-root rendering not handled.
- **Event Handling Refinement:** Recursive listener removal implemented. Further
  testing needed. Performance impact of `DomEvent` wrapper needs consideration.
- **Renderer Optimization:** Keyed diffing is implemented but can likely be
  further optimized.
- **JS Interop Performance:** Still a consideration, but `@staticInterop` in
  `dust_dom` aims to mitigate this compared to dynamic calls.
- **WASM Debugging:** Remains a factor.
- **Bundle Size:** Needs monitoring as framework grows.
- **Hot Reload Implementation:** Still a significant challenge.
- **Riverpod Integration:** Current demo uses a suboptimal pattern
  (component-level container).
