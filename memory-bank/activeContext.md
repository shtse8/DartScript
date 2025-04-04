# Dust Active Context

## Current Focus

- **Implementing Proper Diffing/Patching:** Starting the process of replacing
  the renderer's crude content replacement with a basic diffing algorithm.
- **Refining Component API:** Defining the `build()` return type as `VNode`.
- **Updating Renderer:** Modifying the basic renderer to work with the new
  `VNode` structure returned by `build()`.

## Recent Changes

- **Introduced VNode Structure:**
  - Defined a `VNode` class in `packages/component/lib/vnode.dart` to represent
    virtual DOM nodes (elements and text).
  - Moved `VNode` definition from `renderer` to `component` package to avoid
    circular dependencies.
- **Updated Component API:**
  - Modified `State.build()` method in `packages/component/lib/state.dart` to
    return `VNode` instead of `dynamic`/`Map`.
- **Updated Renderer (`renderer.dart`):**
  - Modified the basic renderer (`_performRender` and stateless handling in
    `render`) to consume `VNode` objects instead of `Map`. It now accesses
    `vnode.tag` and `vnode.text` (or children for text).
- **Updated Clock Demo (`lib/clock.dart`):**
  - Modified `ClockComponent`'s `build` method to return a `VNode` (a `span`
    element containing a text `VNode`) instead of a `Map`.
- **Previous Changes (Still Relevant):**
  - Added Riverpod Dependency & Clock Demo.
  - Improved WASM Loading (`js/app_bootstrap.js`).
  - Enhanced Basic Renderer (Stateful handling, simplified update mechanism).
  - Debugging efforts.

## Next Steps

- **Implement Proper Diffing/Patching:** Replace the renderer's crude content
  replacement with a basic diffing algorithm to update only changed parts of the
  DOM for better performance.
- **Refine Component API:** (Partially done by introducing VNode) Continue
  refining props, context handling.
- **Improve Renderer:**
  - Handle `VNode` children, attributes, and different node types (text vs.
    element) correctly during rendering/patching.
  - Manage component lifecycle more robustly (e.g., `dispose`).
- **Integrate Riverpod Properly:** Explore providing `ProviderContainer` /
  `WidgetRef` through the framework's context instead of creating a container
  per component instance in the demo.
- **Structure Framework Core:** Continue defining the directory structure and
  modules (`packages/core`, `packages/dom`, etc.).

## Active Decisions & Considerations

- **VNode as Build Output:** Confirmed `VNode` as the standard return type for
  `build()`. The renderer now expects this structure.
- **Renderer Update Strategy:** The renderer still uses full content replacement
  but now operates on the `VNode` structure. Diffing is the next major step.
- **VNode Location:** Decided to place `VNode` within the `component` package to
  avoid circular dependencies with the `renderer`.
- **WASM Loading:** Confirmed `app_bootstrap.js` approach.
- **JS Interop:** Continue using `dart:js_interop` for now.
- **State Management Integration:** Riverpod integration remains temporary.
- **Build Tooling:** `dhttpd` is still sufficient for current needs.
