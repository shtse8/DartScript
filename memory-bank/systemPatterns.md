# Dust System Patterns

## Core Framework Architecture

- **WASM Runtime:** Dart runtime compiled to WebAssembly (WASM) via
  `dart compile wasm`.
- **Component Model:**
  - UI built by composing `Component` instances (`StatelessWidget`,
    `StatefulWidget`), potentially with `Key`s and `props`.
  - `StatefulWidget` uses a `State` object for mutable state and UI building.
  - `State` has lifecycle methods (`initState`, `didUpdateWidget`, `build`,
    `dispose`, etc.), a `setState` method (which calls `_markNeedsBuild`), a
    `context` property (a basic `BuildContext`), and access to the component's
    `props` via the `widget` getter. `_markNeedsBuild` triggers an update via
    the `_updateRequester` callback provided by the renderer.
  - `Component`s are represented in the VNode tree by `VNode` instances created
    with `VNode.component()`. These VNodes store the `Component` instance, its
    `key`, the associated `State` object (for StatefulWidgets, managed by the
    renderer), and the `VNode` tree rendered by the component (`renderedVNode`).
  - `State.build()` returns a `VNode` tree representing the component's internal
    structure.
  - `StatelessWidget.build(BuildContext context)` now accepts context and
    returns a `VNode?` tree.
  - HTML helper functions (`html.dart`) now accept `Component` instances as
    children and create `VNode.component` nodes.
- **Declarative Rendering Engine (Keyed Diffing):**
  - Developers declare UI in `build()` methods, ideally using HTML helper
    functions (e.g., `div()`, `h1()`) which return a `VNode` tree.
  - **Initial Render (`_patch` with `oldVNode == null`):**
    - If the root `newVNode` represents a component, calls `_mountComponent`.
    - If the root `newVNode` represents an element/text, calls
      `_mountNodeAndChildren`.
    - `_mountComponent` creates `State` (if StatefulWidget), calls
      `initState`/`build`, and recursively calls `_patch` (with
      `oldVNode == null`) to mount the rendered tree.
    - `_mountNodeAndChildren` creates the element/text node, sets
      attributes/listeners, and recursively calls `_patch` (with
      `oldVNode == null`) to mount children.
  - **Update Mechanism (Keyed Diffing & setState):**
    - **Component Update (Parent Rebuild or `setState`):**
      - `_patch` compares the new component VNode with the old one.
      - If type and key match, calls `_updateComponent`. `_updateComponent`
        reuses the existing `State` (correctly passed via VNode), calls
        `frameworkUpdateWidget` (updating `state.widget` and triggering
        `didUpdateWidget`), then calls `build` and recursively patches the new
        rendered tree against the old one (`oldRenderedVNode` stored on the
        component's VNode).
      - If type or key mismatch, calls `_unmountComponent` on the old and
        `_mountComponent` on the new.
    - **Internal State Update (`setState`):** `State.setState` calls
      `_markNeedsBuild`, invoking the `_updateRequester` callback set during
      `_mountComponent`. This callback calls `build` on the state and then
      `_patch` to diff the new rendered tree against the previously rendered
      tree (`renderedVNode` stored on the component's VNode), using the
      component's parent DOM node as the patching parent.
  - **Patching (`_patch`):**
    - **Handles Initial Render/Removal:** Checks for `newVNode == null` (remove
      old) or `oldVNode == null` (mount new using `_mountComponent` or
      `_mountNodeAndChildren`).
    - **Handles Component Updates:** Differentiates between component VNodes and
      element/text VNodes. If both are components, calls `_updateComponent` (if
      type/key match) or unmount/mount. If one is component and other isn't,
      handles replacement via unmount/mount.
    - **Element/Text Patching:** If both are non-components, compares
      types/tags. If same, updates attributes, listeners (using `jsFunctionRefs`
      for removal, `identical()` check for optimization), and text content.
      Delegates child patching to `_patchChildren`. If different, removes old
      node (calling `removeVNode`) and mounts new node
      (`_mountNodeAndChildren`).
    - `VNode.domNode` links VNodes to their corresponding DOM nodes.
  - **Child Patching (`_patchChildren`):** Implements a keyed reconciliation
    algorithm. Recursively calls `_patch` for matching children. Calls
    `removeVNode` (now a top-level helper) for removed children and `_patch`
    (with `oldVNode = null`) for added children.
- **State Management:**
  - Basic component state managed via `State` and `setState`.
  - **Riverpod Integration (Basic):**
    - `runApp` creates a root `ProviderContainer` and a root `BuildContext`
      containing it.
    - The `BuildContext` is passed down the component tree by the renderer
      during mount/update.
    - `Consumer` widget (`packages/component/lib/consumer.dart`) accesses the
      `ProviderContainer` via `context.container`.
    - `Consumer` uses a `WidgetRef` to interact with the container and trigger
      rebuilds on its own `State` via `setState`.
  - Framework-level context/DI patterns (replacing global container) are future
    goals.
- **Routing:** (Not yet implemented) Goal is a client-side SPA router.
- **JavaScript Bridge:**
  - **WASM Loading:** Handled by the JS loader generated by `build_runner`
    (`web/main.dart.js`), which imports functions from the compiled WASM module
    (`web/main.wasm`) and its JS bridge (`web/main.mjs`).
  - **Dart <-> JS Communication:** Uses `dart:js_interop`. Dart calls JS
    functions (defined via `@JS`) for DOM manipulation and browser APIs (like
    `addEventListener`). JS calls exported Dart functions (e.g., `$invokeMain`).
  - **DOM Access & Event Handling:** Renderer (`_mountNodeAndChildren`,
    `_patch`) now uses the `dust_dom` abstraction layer (`DomNode`, `DomElement`
    extensions) for DOM manipulation (e.g., `appendChild`, `removeChild`,
    `setAttribute`, `addEventListener`). Dart event callbacks are still wrapped
    in a JS function passing `DomEvent` and converted using `.toJS` before being
    passed to `dust_dom`'s `addEventListener`.
- **Application Entry Point:**
  - `web/index.html` loads the `build_runner` generated `web/main.dart.js` as a
    module.
  - `web/main.dart.js` handles WASM loading and calls the exported `$invokeMain`
    function.
  - `$invokeMain` executes the Dart `main()` function in `web/main.dart`.
  - User's Dart `main()` calls the framework's `runApp` function (defined in
    `dust_renderer`) which creates the root component VNode and calls `_patch`
    for the initial render.
- **Sandboxing:** Execution remains within the browser's WASM sandbox.

## Key Technical Decisions (Framework Context)

- **Rendering Strategy:** Implemented a keyed Virtual DOM diffing/patching
  strategy (`_patch` delegating to `_patchChildren`). Initial render logic
  corrected to properly mount components.
- **Component API Design:** Class-based approach similar to Flutter. `Component`
  includes `props`. `State.build()` returns `VNode`. `StatelessWidget.build()`
  accepts `BuildContext`. HTML helper functions
  (`package:dust_component/html.dart`) encouraged. `VNode` includes `key`,
  `listeners`, `jsFunctionRefs`, `dartCallbackRefs`.
- **State Management Approach:** Basic Riverpod integration implemented via
  `BuildContext` passing.
- **JS/WASM Bridge Implementation:** Using `dart:js_interop` and `dust_dom`
  abstraction layer. Event listener callbacks use `.toJS` on a wrapper.
- **Build Tooling Integration:** `build_runner` used for dev server (Hot
  Restart) and WASM compilation.

## Core Patterns

- **Declarative UI Helpers Pattern:** Functions (`div`, `h1`, etc.) for `VNode`
  creation.
- **Component Pattern:** Core UI building block (`Component`, `StatefulWidget`,
  `StatelessWidget`).
- **State Management Pattern:** `State` for local state. Riverpod via `Consumer`
  and `BuildContext`.
- **Context Pattern (Basic):** Simple `BuildContext` carrying
  `ProviderContainer`. No global container.
- **Provider Scope Pattern:** `ProviderScope` component creates a new nested
  `ProviderContainer` (with optional overrides) for its subtree. Renderer
  detects `ProviderScope` and passes its specific `BuildContext` (containing the
  scoped container) to the child component during patching.
- **Observer Pattern:** Implicit via `StreamProvider` and `setState`.
- **Callback Pattern:** Used for `State` (`_updateRequester`) to trigger
  updates.
- **Facade Pattern:** `dust_dom` package over JS DOM APIs.
- **Bootstrap Pattern:** `build_runner` generated JS loader.
- **Application Runner Pattern:** `runApp` function.
- **Virtual DOM Node Pattern:** `VNode` objects (`element`, `text`,
  `component`).
- **Diffing/Patching Pattern:** `_patch` function orchestrates updates.
  - Differentiates initial render (`oldVNode == null`), removal
    (`newVNode == null`), component updates, and element/text updates.
  - Uses helper functions (`_mountComponent`, `_updateComponent`,
    `_unmountComponent`, `_mountNodeAndChildren`) for specific scenarios.
  - Uses keyed reconciliation (`_patchChildren`) for child lists.
- **Event Listener Management Pattern:**
  - **Creation/Update:** Wrapping Dart callbacks, using `.toJS`, storing refs
    (`jsFunctionRefs`, `dartCallbackRefs`).
  - **Optimization:** `identical()` check skips updates for stable callbacks.
  - **Removal:** Explicit recursive removal via `removeVNode` ->
    `_removeListenersRecursively` -> `_removeListenersFromNode` before DOM
    detachment.
- **Atomic CSS Generation Pattern (Two-Phase Build-Time, Refactored):**
  - `AtomicStyleBuilder` scans Dart code for class usage.
  - `AtomicCssAggregator` aggregates classes and generates final CSS.
  - Extensive rule set defined and structured by category.
