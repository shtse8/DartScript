# Dust System Patterns

## Core Framework Architecture

- **WASM Runtime:** Dart runtime compiled to WebAssembly (WASM) via
  `dart compile wasm`.
- **Component Model:**
  - UI built by composing `Component` instances (`StatelessWidget`,
    `StatefulWidget`).
  - `StatefulWidget` uses a `State` object for mutable state and UI building.
  - `State` has lifecycle methods (`initState`, `build`, `dispose`, etc.) and
    `setState` for triggering updates.
  - `State.build()` returns a `VNode` tree (potentially with keys) representing
    the desired UI structure.
- **Declarative Rendering Engine (Keyed Diffing):**
  - Developers declare UI in `build()` methods, returning a `VNode` tree.
  - **Initial Render:** Handles `StatefulWidget` creation and initial `build`
    via `_patch` (with `oldVNode` as null).
  - **Update Mechanism (Keyed Diffing):** `setState` calls a callback provided
    by the renderer (`_performRender`). `_performRender` re-runs `build` to get
    the new `VNode` tree and calls `_patch`.
  - **Patching (`_patch`):** Compares the new and old `VNode` trees at the root
    level. Handles node addition/removal/replacement, text updates, attribute
    updates. Delegates child patching to `_patchChildren`. `VNode.domNode` links
    VNodes to their corresponding DOM nodes.
  - **Child Patching (`_patchChildren`):** Implements a keyed reconciliation
    algorithm to efficiently update child lists (handling additions, removals,
    reordering, and updates based on `VNode.key`).
- **State Management:**
  - Basic component state managed via `State` and `setState`.
  - External libraries like Riverpod can be used (demonstrated in clock example,
    though integration needs refinement).
  - Framework-level context/DI patterns are future goals.
- **Routing:** (Not yet implemented) Goal is a client-side SPA router.
- **JavaScript Bridge:**
  - **WASM Loading:** Handled by a dedicated JS bootstrap module
    (`js/app_bootstrap.js`) which imports functions from the auto-generated
    `wasm/main.mjs`.
  - **Dart <-> JS Communication:** Uses `dart:js_interop`. Dart calls JS
    functions (defined via `@JS`) for DOM manipulation and browser APIs. JS
    calls exported Dart functions (e.g., `$invokeMain`).
  - **DOM Access:** Currently direct JS interop calls within the renderer; a
    Dart DOM abstraction layer is planned.
- **Application Entry Point:**
  - `index.html` loads `js/app_bootstrap.js` as a module.
  - `app_bootstrap.js` fetches, compiles, and instantiates `wasm/main.wasm`.
  - `app_bootstrap.js` calls the exported `$invokeMain` function in the WASM
    module, which executes the Dart `main()` function in `lib/main.dart`.
  - Dart `main()` typically calls the framework's `render` function to mount the
    root component.
- **Sandboxing:** Execution remains within the browser's WASM sandbox.

## Key Technical Decisions (Framework Context)

- **Rendering Strategy:** Implemented a keyed Virtual DOM diffing/patching
  strategy (`_patch` delegating to `_patchChildren`). Further optimization is
  possible.
- **Component API Design:** Current class-based approach is similar to Flutter.
  `build()` return type is `VNode`. `VNode` now includes an optional `key`.
  Further refinement needed for props and context.
- **State Management Approach:** Provide built-in context or focus on
  integrating external libraries like Riverpod?
- **JS/WASM Bridge Implementation:** Continue with `dart:js_interop`. How to
  create an efficient Dart DOM abstraction layer?
- **Build Tooling Integration:** How to integrate for hot reload and production
  builds?

## Core Patterns

- **Component Pattern:** Core UI building block.
- **State Management Pattern:** Using `State` for local state; external
  libraries (Riverpod) for app state.
- **Observer Pattern:** Implicitly used via `StreamProvider` and `setState`
  triggering updates.
- **Callback Pattern:** Used for `State` to request updates from the renderer.
- **Facade Pattern:** (Goal) For the Dart DOM abstraction layer.
- **Bootstrap Pattern:** Using a dedicated JS module (`app_bootstrap.js`) to
  load and initialize the WASM application.
- **Virtual DOM Node Pattern:** Using `VNode` objects to represent the desired
  DOM structure in memory, linked to actual DOM nodes via `domNode` property.
- **Diffing/Patching Pattern:** Comparing VNode trees (`_patch`) and applying
  targeted updates to the DOM. Uses keyed reconciliation (`_patchChildren`) for
  efficient list updates.
