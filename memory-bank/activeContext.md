# Dust Active Context

## Current Focus

- **Basic Event Handling Implemented:** Added support for attaching and updating
  event listeners (like 'click') to DOM elements via VNodes.
- **Testing Event Handling:** Modified `TodoListComponent` to use click handlers
  on buttons for adding, removing, toggling, and shuffling items.
- **Debugging JS Interop for Events:** Resolved issues with converting Dart
  callbacks to JSFunctions using `.toJS` extension method (instead of the
  initially attempted `allowInterop`).
- **(Previous) Keyed Child Diffing Implemented & Tested.**

## Recent Changes

- **Updated VNode Structure (`packages/component/lib/vnode.dart`):**
  - Added `listeners` property (Map<String, void Function(JSAny event)>) to
    define event callbacks.
  - Added `jsFunctionRefs` property (Map<String, JSFunction>?) to store JS
    references of converted Dart callbacks for potential removal.
  - Imported `dart:js_interop` for `JSAny` and `JSFunction`.
  - (Previous) Added `key` property.
- **Updated Component API:**
  - Modified `State.build()` method in `packages/component/lib/state.dart` to
    return `VNode` instead of `dynamic`/`Map`.
- **Updated Renderer (`packages/renderer/lib/renderer.dart`):**
  - Added `addEventListener` and `removeEventListener` to `JSAnyExtension`.
  - Modified `_createDomElement` to:
    - Iterate over `vnode.listeners`.
    - Convert Dart callbacks to `JSFunction` using `.toJS`.
    - Call `element.addEventListener`.
    - Store the resulting `JSFunction` reference in `vnode.jsFunctionRefs`.
  - Modified `_patch` to:
    - Copy `jsFunctionRefs` from old VNode to new VNode.
    - Implement logic to add/update/remove event listeners:
      - Iterate through `oldListeners` and remove listeners not present in
        `newListeners` (using stored `jsFunctionRefs`).
      - Iterate through `newListeners` and add/update listeners if the callback
        function instance changes or is new, removing the old listener first if
        found.
  - Resolved issues related to finding/using `.toJS` (initially confused with
    `allowInterop` and `dart:js_util`).
  - (Previous) Implemented `_patchChildren` with keyed reconciliation.
  - (Previous) Fixed various diffing bugs.
- **Updated TodoList Demo (`lib/todo_list.dart`):**
  - Added `click` listeners to 'Toggle', 'Remove', 'Add Item', and 'Shuffle
    Items' buttons, calling the corresponding state methods (`_toggleItem`,
    `_removeItem`, `_addItem`, `_shuffleItems`).
  - Removed `disabled` attributes from buttons.
  - Added `dart:js_interop` import for `JSAny` type in listener callbacks.
  - **Commented out the automatic `_scheduleTestUpdates` timer** in `initState`
    now that manual interaction works.
  - (Previous) Implemented component to test keyed diffing.
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

- **Refine Event Handling:**
  - The current listener update logic in `_patch` works but could be more robust
    (e.g., better comparison of function instances).
  - Ensure proper removal of listeners using stored `jsFunctionRefs` (current
    removal logic relies on finding the ref, which seems to work but needs
    verification).
  - Consider wrapping the `JSAny event` object passed to Dart callbacks into a
    more Dart-friendly structure.
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

- **JS Interop for Events:** Confirmed using `.toJS` extension on Dart functions
  is the correct way to get a `JSFunction` for `addEventListener` in WASM, not
  `allowInterop` from `dart:js_util`.
- **Listener Reference Storage:** Storing `JSFunction` references on the `VNode`
  (`jsFunctionRefs`) seems necessary for correct listener removal during
  patching.
- **(Previous) VNode as Build Output:** Confirmed.
- **(Previous) Renderer Update Strategy:** Keyed diffing implemented.
- **(Previous) VNode Location:** Confirmed.
- **(Previous) WASM Loading:** Confirmed.
- **(Previous) JS Interop:** Using `dart:js_interop`.
- **(Previous) State Management Integration:** Riverpod temporary.
- **(Previous) Build Tooling:** `dhttpd` sufficient for now.
