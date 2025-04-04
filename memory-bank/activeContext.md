# Dust Active Context

## Current Focus

- **Implementing Basic Diffing/Patching:** Implemented initial diffing logic in
  the renderer's `_patch` function, handling node addition, removal, type
  replacement, text updates, attribute updates, and basic child list diffing.
- **Refining Renderer Structure:** Introduced `_patch` function and associated
  `VNode.domNode` reference for future diffing improvements.

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
  - Introduced `_patch` function to handle DOM updates based on VNode
    comparison.
  - `_performRender` now calls `_patch`.
  - `_createDomElement` now populates `VNode.domNode`.
  - `_patch` implements basic diffing for:
    - Node addition/removal (null checks).
    - Node type replacement (tag/type mismatch).
    - Text node content updates.
    - Element attribute addition/update/removal.
    - Basic indexed child list diffing (add/remove at end, recursive patch).
  - Added necessary JS interop definitions (`removeChild`, `replaceChild`,
    `removeAttribute`, `parentNode`).
- **Updated Clock Demo (`lib/clock.dart`):**
  - Modified `ClockComponent`'s `build` method to return a `VNode` (a `span`
    element containing a text `VNode`) instead of a `Map`.
- **Previous Changes (Still Relevant):**
  - Added Riverpod Dependency & Clock Demo.
  - Improved WASM Loading (`js/app_bootstrap.js`).
  - Enhanced Basic Renderer (Stateful handling, simplified update mechanism).
  - Debugging efforts.

## Next Steps

- **Refine Diffing/Patching:** Improve the child diffing algorithm (e.g., using
  keys for better reconciliation), optimize attribute patching.
- **Refine Component API:** (Partially done by introducing VNode) Continue
  refining props, context handling.
- **Improve Renderer:**
  - (Partially done) Continue refining handling of edge cases in patching.
  - Manage component lifecycle more robustly (e.g., `dispose`).
- **Integrate Riverpod Properly:** Explore providing `ProviderContainer` /
  `WidgetRef` through the framework's context instead of creating a container
  per component instance in the demo.
- **Structure Framework Core:** Continue defining the directory structure and
  modules (`packages/core`, `packages/dom`, etc.).

## Active Decisions & Considerations

- **VNode as Build Output:** Confirmed `VNode` as the standard return type for
  `build()`. The renderer now expects this structure.
- **Renderer Update Strategy:** Moved from full `innerHTML` replacement to a
  basic diffing/patching approach within the `_patch` function. It handles
  common cases but needs further optimization (e.g., keyed children).
- **VNode Location:** Decided to place `VNode` within the `component` package to
  avoid circular dependencies with the `renderer`.
- **WASM Loading:** Confirmed `app_bootstrap.js` approach.
- **JS Interop:** Continue using `dart:js_interop` for now.
- **State Management Integration:** Riverpod integration remains temporary.
- **Build Tooling:** `dhttpd` is still sufficient for current needs.
