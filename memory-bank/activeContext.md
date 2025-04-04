# Dust Active Context

## Current Focus

- **Implementing Basic State Updates:** Focusing on enabling `StatefulWidget`
  updates triggered by `setState`. This involves:
  - Modifying the `State` class to request updates via a callback.
  - Enhancing the basic `Renderer` to handle these update requests and re-render
    the component (currently using a simple full replacement).
- **Refining WASM Loading:** Improving the WASM loading process by separating
  the bootstrap logic into a dedicated JS file (`js/app_bootstrap.js`) instead
  of modifying the generated `main.mjs`.
- **Debugging Rendering Issues:** Diagnosing and fixing issues related to WASM
  loading, JS interop, and initial component rendering.

## Recent Changes

- **Added Riverpod Dependency:** Integrated `riverpod` package for state
  management demonstration.
- **Created Clock Demo:**
  - Implemented `lib/clock.dart` with a `ClockComponent` (StatefulWidget) using
    Riverpod's `StreamProvider` to get time updates.
  - Updated `lib/main.dart` to render `ClockComponent`.
- **Improved WASM Loading:**
  - Created `js/app_bootstrap.js` to handle WASM fetching, compilation,
    instantiation, and Dart `main` invocation.
  - Updated `index.html` to load `js/app_bootstrap.js` instead of
    `wasm/main.mjs`.
  - This avoids modifying the auto-generated `main.mjs` after each compilation.
- **Enhanced Basic Renderer (`renderer.dart`):**
  - Added logic to handle `StatefulWidget` initial rendering (creating state,
    calling `initState`, calling `build`).
  - Implemented a **simplified update mechanism**:
    - Added `setUpdateRequester` to `State` class.
    - `State._markNeedsBuild` now calls the requester callback.
    - Renderer sets the callback during initial render.
    - The callback (`_performRender`) re-runs `state.build()` and replaces the
      target element's content (no diffing).
- **Debugging:**
  - Added extensive `console.log` statements in `main.dart` and
    `js/app_bootstrap.js` to trace execution flow.
  - Diagnosed and fixed issues related to CORS errors (by using `dhttpd`),
    incorrect `State` lifecycle invocation, and JS interop errors.
  - Updated `README.md` with explanations of technical choices (WASM vs Dart2JS,
    Dust vs Flutter Web).

## Next Steps

- **Implement Proper Diffing/Patching:** Replace the renderer's crude content
  replacement with a basic diffing algorithm to update only changed parts of the
  DOM for better performance.
- **Refine Component API:** Define the return type of `build()` more concretely
  (e.g., a `VNode` or `Element` representation instead of `dynamic` or `Map`).
- **Improve Renderer:**
  - Handle different `build()` return types (e.g., lists of children, text
    nodes).
  - Manage component lifecycle more robustly (e.g., `dispose`).
- **Integrate Riverpod Properly:** Explore providing `ProviderContainer` /
  `WidgetRef` through the framework's context instead of creating a container
  per component instance in the demo.
- **Structure Framework Core:** Continue defining the directory structure and
  modules (`packages/core`, `packages/dom`, etc.).

## Active Decisions & Considerations

- **Simplified Update Mechanism:** Acknowledged that the current `setState`
  update in the renderer is very basic (full replacement) and needs replacement
  with proper diffing.
- **WASM Loading:** Confirmed that using a separate bootstrap JS file
  (`app_bootstrap.js`) is the preferred approach over modifying `main.mjs`.
- **JS Interop:** Continue using `dart:js_interop` for DOM manipulation within
  the renderer, keeping calls minimal.
- **State Management Integration:** The current Riverpod integration in
  `ClockComponent` (creating its own `ProviderContainer`) is a temporary
  workaround. A proper framework solution is needed.
- **Build Tooling:** `dhttpd` remains sufficient for serving, but more advanced
  tooling is needed for development workflows (hot reload).
