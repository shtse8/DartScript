# Dust Active Context

## Current Focus

- **Keyed Child Diffing Implemented:** Replaced the basic indexed child diffing
  in `_patch` with a keyed reconciliation algorithm (`_patchChildren`) in the
  renderer.
- **Testing Keyed Diffing:** Created `TodoListComponent` with automatic updates
  (add/remove/shuffle) to verify the keyed diffing logic.
- **Debugging Renderer:** Fixed various issues identified during diffing
  implementation and testing (JS interop, type errors, logic errors).

## Recent Changes

- **Updated VNode Structure:**
  - Added `key` property to `VNode` class in `packages/component/lib/vnode.dart`
    to support keyed diffing.
  - (Previous) Defined `VNode` class.
  - (Previous) Moved `VNode` definition to `component` package.
- **Updated Component API:**
  - Modified `State.build()` method in `packages/component/lib/state.dart` to
    return `VNode` instead of `dynamic`/`Map`.
- **Updated Renderer (`renderer.dart`):**
  - Implemented `_patchChildren` function with a keyed reconciliation algorithm
    (inspired by Vue/Inferno).
  - `_patch` now calls `_patchChildren` for handling child updates.
  - Added `insertBefore` and `tagName` to `JSAnyExtension` for JS interop.
  - Fixed various bugs in `_patch` and `_patchChildren` related to null
    handling, JS interop calls, and list manipulation.
  - Added detailed logging to `_createDomElement` and `_patchChildren` for
    debugging diffing logic.
  - (Previous) Introduced `_patch` function.
  - (Previous) `_performRender` calls `_patch`.
  - (Previous) `_createDomElement` populates `VNode.domNode`.
  - (Previous) Added basic JS interop definitions.
- **Created TodoList Demo (`lib/todo_list.dart`):**
  - Implemented a stateful `TodoListComponent` to test keyed diffing.
  - Uses `item.id` as `key` for list items (`<li>`).
  - Includes automatic timer-based updates (add, remove, shuffle) for testing.
- **Updated Main Entry Point (`lib/main.dart`):**
  - Changed `render` call to use `TodoListComponent` instead of
    `ClockComponent`.
  - Updated target element ID to `'app'`.
- **Updated `index.html`:**
  - Changed the target div ID from `'output'` to `'app'`.
- **(Previous) Updated Clock Demo:** Modified `build` to return `VNode`.
- **Previous Changes (Still Relevant):**
  - Added Riverpod Dependency & Clock Demo.
  - Improved WASM Loading (`js/app_bootstrap.js`).
  - Enhanced Basic Renderer (Stateful handling, simplified update mechanism).
  - Debugging efforts.

## Next Steps

- **Implement Event Handling:** Allow user interaction with components (e.g.,
  button clicks in `TodoListComponent`). This involves:
  - Defining event listener attributes in `VNode`.
  - Attaching/detaching listeners in the renderer (`_patch`).
  - Creating a mechanism to dispatch DOM events back to Dart component
    callbacks.
- **Refine Diffing/Patching:** (Keyed diffing implemented) Further optimize
  patching logic, handle edge cases more robustly.
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
- **Renderer Update Strategy:** Implemented keyed child reconciliation in
  `_patchChildren`, replacing the basic indexed approach. Further optimization
  is possible.
- **VNode Location:** Decided to place `VNode` within the `component` package to
  avoid circular dependencies with the `renderer`.
- **WASM Loading:** Confirmed `app_bootstrap.js` approach.
- **JS Interop:** Continue using `dart:js_interop` for now.
- **State Management Integration:** Riverpod integration remains temporary.
- **Build Tooling:** `dhttpd` is still sufficient for current needs.
