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
- **Component Model (VNode + Key + Listeners + DomEvent):**
  - Abstract classes for `Component`, `StatelessWidget`, `StatefulWidget`, and
    `State` defined in `packages/component`.
  - **`VNode` structure defined** with `key`, `listeners` (now using
    `DomEvent`), and `jsFunctionRefs` properties added.
  - Added `dust_renderer` dependency to `component` package.
  - `State.build()` method returns `VNode`.
  - Basic lifecycle methods defined in `State`.
- **Renderer (Keyed Diffing + Refined Event Handling + Initial DOM
  Abstraction):**
  - `packages/renderer` provides `render` function.
  - **Integrated `dust_dom`:** Started replacing direct JS interop calls with
    `dust_dom` abstractions (e.g., `createElement`, `setAttribute`,
    `appendChild`, event listeners).
  - **Created `DomEvent` wrapper** (`dom_event.dart`) for type-safe event
    handling.
  - `_patch` function handles node/attribute/listener updates and delegates
    child patching (partially refactored for `dust_dom`).
  - **`_patchChildren` function implements keyed reconciliation algorithm**
    (partially refactored for `dust_dom`).
  - `_createDomElement` helper creates DOM nodes from `VNode` (using
    `dust_dom`), attaches initial listeners (now wrapping callbacks to pass
    `DomEvent`, converting with `.toJS`, storing refs), and stores DOM reference
    in `VNode.domNode`.
  - **Improved listener update logic in `_patch`:** Always removes/adds
    listeners when present in new VNode, wraps callbacks to pass `DomEvent` (now
    uses `dust_dom` `addEventListener`/`removeEventListener`).
  - (Previous) JS Interop updated for `addEventListener` and
    `removeEventListener` (being replaced).
- **State Update (Keyed Diffing):**
  - `State.setState` triggers a callback mechanism.
  - Renderer receives the callback, re-runs `State.build()`, and uses `_patch`
    (which calls `_patchChildren`) to apply updates efficiently using keys.
  - **Result:** Stateful components with lists (like `TodoListComponent`) can
    update efficiently, handling additions, removals, and reordering correctly.
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
  - **Component Model Refinement:** (`VNode` with `key` defined) Handle props,
    context.
  - **DOM Abstraction:** (`dust_dom` created) Complete the abstraction layer and
    fully replace direct JS interop in the renderer.
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
  - Improved listener update logic in `_patch` for robustness (now using
    `dust_dom`).
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
- **Core Component Structure Updated:** `Component`/`State`/`VNode` structure is
  in place.
- **Renderer Structure Improved:** Introduced `_patch` function and
  `VNode.domNode` linking, providing a better structure for rendering logic (now
  partially using `dust_dom`).
- **Keyed Diffing Algorithm Implemented:** Replaced basic indexed approach.

## Known Issues / Challenges

- **Event Handling Refinement:** Listener update/removal logic improved but
  needs further testing for edge cases and reliability. Performance impact of
  `DomEvent` wrapper needs consideration.
- **Renderer Optimization:** Keyed diffing is implemented but can likely be
  further optimized.
- **JS Interop Performance:** Still a consideration, but `@staticInterop` in
  `dust_dom` aims to mitigate this compared to dynamic calls.
- **WASM Debugging:** Remains a factor.
- **Bundle Size:** Needs monitoring as framework grows.
- **Hot Reload Implementation:** Still a significant challenge.
- **Riverpod Integration:** Current demo uses a suboptimal pattern
  (component-level container).
