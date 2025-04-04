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
  - Abstract classes for `Component` (now with `key` and `props`),
    `StatelessWidget` (build takes `BuildContext`, constructor takes props),
    `StatefulWidget` (constructor takes props), and `State` defined. `key.dart`
    created.
  - **`VNode` structure updated:** Added `VNode.component` constructor,
    `component`, `state`, `renderedVNode`, and `dartCallbackRefs` properties.
  - HTML Helpers (`html.dart`) updated to accept `Component` as children.
  - `State.build()` returns `VNode`. `StatelessWidget.build()` now accepts
    `BuildContext` and returns `VNode?`.
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
    listener removal during unmount/node removal via `removeVNode`. Listener
    updates in `_patch` are now optimized using `identical()` checks on Dart
    callbacks to avoid unnecessary remove/add operations. `VNode` now stores
    original Dart callbacks (`dartCallbackRefs`). `_unmountComponent` logic
    improved for robustness.
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
- **Demo Application (Props Tester - Conditional Listener):**
  - Created `PropTester` component (`lib/prop_tester.dart`) to cycle through
    names.
  - Converted `HelloWorld` (`lib/hello_world.dart`) to `StatefulWidget`.
  - `HelloWorld` now conditionally adds/removes a `mouseover` listener based on
    the length of the `name` prop received from `PropTester`.
  - `main.dart` updated to render `PropTester` into `#app` div.
  - This setup allows testing dynamic listener updates triggered by prop
    changes.
- **Atomic CSS Generation (Build-Time, Refactored & Expanded):**
  - Created `dust_atomic_styles` package.
  - **Significantly expanded rule set:** Defined a comprehensive set of atomic
    rules covering spacing, layout, flexbox, grid, sizing, typography,
    backgrounds, borders, effects (shadows, opacity), filters, interactivity
    (cursor, user-select), transforms, transitions, animations, SVG styling, and
    accessibility utilities.
  - **Refactored rule structure:** Split rules into category-specific files
    within `packages/atomic_styles/lib/src/rules/` for better maintainability.
    Shared constants (`spacingScale`, `colors`) moved to
    `packages/atomic_styles/lib/src/constants.dart`.
    `packages/atomic_styles/lib/src/rules.dart` now imports and merges these
    rule maps using the spread operator (`...`).
  - Implemented `AtomicStyleBuilder` (`atomicScanner`) to scan Dart files
    (`lib/**`, `web/**`) using `analyzer` and extract class names from HTML
    helper functions, outputting per-file `.classes` files to cache.
  - Implemented `AtomicCssAggregator` (`cssAggregatorBuilder`) as a `Builder` to
    read all `.classes` files using `findAssets`, aggregate unique class names,
    generate final CSS using `generateAtomicCss`, and write to
    `web/atomic_styles.css`. (Refactored from `PostProcessBuilder`).
  - Configured builders (`atomicScanner`, `cssAggregatorBuilder`) in
    `packages/atomic_styles/build.yaml` (updated for aggregator) and applied
    them in the root `build.yaml`.
  - Tested successfully with classes added to `TodoListComponent`.

## What's Left to Build (High Level - Framework Focus)

- **Core Framework Implementation:**
  - **Rendering Engine (Diffing):** (Keyed diffing implemented) Further optimize
    patching logic, handle edge cases.
  - **Component Model Refinement:** (Props basics implemented, `VNode` structure
    updated, `key` added, `StatelessWidget` context handled) Consider typed
    props.
  - **DOM Abstraction:** (`dust_dom` created) Integration mostly complete in
    core rendering path.
  - **Event Handling:** (Optimized) Listener update logic now uses `identical()`
    check. `DomEvent` wrapper implemented. Recursive removal logic in place.
    Further testing on removal reliability needed.
  - **State Management Integration:** Provide framework-level support for state
    management solutions like Riverpod (e.g., `ProviderScope`, context access).
  - **Routing System:** Implement SPA routing.
- **Developer Experience Tooling:**
  - **Build System:** Integrate with `build_runner` or create custom tools for
    optimized builds.
  - **Development Server:** Implement hot reload/hot restart.
  - **Atomic CSS:** (Aggregation refactored) Rule set is extensive. Builder now
    correctly aggregates classes using `Builder` and `findAssets`.
- **Documentation & Examples:** Expand significantly.

## Current Status

- **DOM Abstraction Started:**
  - Created `dust_dom` package with basic static interop classes.
  - Started integrating `dust_dom` into the renderer, replacing some direct JS
    calls.
  - Successfully compiled WASM after initial integration.
- **Event Handling Optimized & Refined:**
  - Implemented `DomEvent` wrapper for type safety.
  - Optimized listener update logic in `_patch` using `identical()` checks on
    Dart callbacks stored in `VNode.dartCallbackRefs`.
  - Implemented recursive listener removal in `removeVNode` ensuring cleanup
    before DOM node detachment.
  - Improved robustness of `_unmountComponent` DOM node checks.
  - Updated relevant components/demos (`VNode`, `renderer`).
- **JS Interop for Events Resolved:** Confirmed `.toJS` extension method is the
  correct approach for WASM event listeners (still used for callback
  conversion).
- **Props Implemented:** Component hierarchy now supports passing data down via
  `props` map.
- **(Previous) Keyed Diffing Implemented & Tested.**
- **(Previous) Renderer Refactored for Diffing.**
- **(Previous) Demo Updated for Diffing.**
- **(Previous) VNode Introduced & Integrated.**
- **(Previous) Basic Patching Foundation Laid.**
- **Improved WASM Loading:** Loading mechanism remains clean
  (`app_bootstrap.js`).
- **Core Component Structure Updated:** `Component` (with `key`, `props`),
  `State`, `StatelessWidget` (build takes `BuildContext`, constructor takes
  props), `StatefulWidget` (constructor takes props), `VNode` (with `component`,
  `state`, `renderedVNode`, `dartCallbackRefs`) structure updated. HTML helpers
  support components.
- **Renderer Structure Improved:** Refactored `_patch` to handle component
  lifecycle via `_mountComponent`, `_updateComponent`, `_unmountComponent`.
  Listener/node removal helpers moved to top level.
- **Keyed Diffing Algorithm Implemented.**
- **Atomic CSS Generation Refactored:** Two-phase builder (`atomicScanner` +
  `cssAggregatorBuilder`) successfully generates `web/atomic_styles.css` based
  on used classes, with the aggregator now correctly reading all inputs.

## Known Issues / Challenges

- **Component Lifecycle & `setState`:** Basic mount/update/dispose implemented.
  `setState` now correctly triggers component updates via the renderer's
  patching mechanism. Fragment/multi-root rendering not handled.
- **Event Handling Refinement:** Recursive listener removal implemented.
  `identical()` optimization added for listener updates. Further testing needed.
  Performance impact of `DomEvent` wrapper needs consideration.
- **Renderer Optimization:** Keyed diffing is implemented but can likely be
  further optimized.
- **JS Interop Performance:** Still a consideration, but `@staticInterop` in
  `dust_dom` aims to mitigate this compared to dynamic calls.
- **WASM Debugging:** Remains a factor.
- **Bundle Size:** Needs monitoring as framework grows.
- **Hot Reload Implementation:** Still a significant challenge.
- **(Resolved) Atomic CSS Builder Aggregation:** The `AtomicCssAggregator` has
  been refactored from `PostProcessBuilder` to `Builder` and now correctly uses
  `buildStep.findAssets` to aggregate classes from all `.classes` files.
- **Riverpod Integration:** Current demo uses a suboptimal pattern
  (component-level container).
