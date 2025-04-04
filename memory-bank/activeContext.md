# Dust Active Context

## Current Focus

- **Integrating DOM Abstraction:** Continue replacing direct JS interop calls in
  `renderer.dart` with the new `dust_dom` abstractions.
- **Refining Event Handling:** (Partially addressed)
  - Implemented `DomEvent` wrapper (`packages/renderer/lib/dom_event.dart`) for
    type-safe event object access in Dart callbacks.
  - Simplified and improved the listener update logic in the renderer's `_patch`
    function to be more robust, especially for inline function definitions.
  - Updated `VNode`, renderer, and `TodoListComponent` demo to use `DomEvent`.
- **(Previous) Basic Event Handling Implemented & Tested.**
- **(Previous) Debugging JS Interop for Events Resolved.**
- **(Previous) Keyed Child Diffing Implemented & Tested.**

## Recent Changes

- **Created `dust_dom` Package:**
  - Created `packages/dom/lib` directory.
  - Created `packages/dom/pubspec.yaml`.
  - Created initial `packages/dom/lib/dom.dart` with basic `DomNode`,
    `DomElement`, `DomTextNode`, `DomDocument` abstractions using
    `@staticInterop`.
  - Added `dust_dom` as a dependency to the root `pubspec.yaml` and
    `packages/renderer/pubspec.yaml`.
  - Ran `dart pub get` successfully in both directories.
- **Started Renderer Refactoring (`packages/renderer/lib/renderer.dart`):**
  - Imported `package:dust_dom/dom.dart`.
  - Replaced direct JS interop for `getElementById`, `createElement`,
    `createTextNode`, `setAttribute`, `removeAttribute`, `appendChild`,
    `removeChild`, `replaceChild`, `insertBefore`, `textContent`, `tagName`,
    `addEventListener`, `removeEventListener` with calls to `dust_dom`
    abstractions where applicable (ongoing).
  - Successfully compiled WASM after initial refactoring steps.
- **(Previous) Updated VNode Structure (`packages/component/lib/vnode.dart`):**
  - **Updated `listeners` property type to
    `Map<String, void Function(DomEvent event)>?`**.
  - Added `jsFunctionRefs` property (Map<String, JSFunction>?) to store JS
    references of converted Dart callbacks for potential removal.
  - Added `dust_renderer` as a path dependency in `pubspec.yaml`.
  - Imported `package:dust_renderer/dom_event.dart`.
  - (Previous) Added `key` property.
- **Updated Component API:**
  - Modified `State.build()` method in `packages/component/lib/state.dart` to
    return `VNode` instead of `dynamic`/`Map`.
- **Created `packages/renderer/lib/dom_event.dart`:** Defined `DomEvent` wrapper
  class.
- **Updated Renderer (`packages/renderer/lib/renderer.dart`):**
  - Imported `dom_event.dart`.
  - Modified `_createDomElement` to:
    - Wrap the Dart callback in a JS function that creates and passes a
      `DomEvent` object.
    - Convert the wrapper function to `JSFunction` using `.toJS`.
    - Store the resulting `JSFunction` reference.
  - Modified `_patch`'s listener update logic:
    - **Simplified update condition:** Always remove the old listener (if
      reference exists) and add the new one when the event exists in the new
      listeners map. This handles inline functions more robustly.
    - Wrap the new Dart callback similarly to `_createDomElement` before
      converting to `JSFunction`.
  - (Previous) Added `addEventListener` and `removeEventListener` to
    `JSAnyExtension`.
  - (Previous) Resolved issues related to finding/using `.toJS`.
  - (Previous) Implemented `_patchChildren` with keyed reconciliation.
  - (Previous) Fixed various diffing bugs.
- **Updated TodoList Demo (`lib/todo_list.dart`):**
  - **Updated listener callbacks to accept `DomEvent` instead of `JSAny`**.
  - Imported `package:dust_renderer/dom_event.dart`.
  - (Previous) Added `click` listeners.
  - (Previous) Removed `disabled` attributes.
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

- **Refine Event Handling:** (Partially addressed)
  - Listener update logic improved in `_patch`.
  - `DomEvent` wrapper created.
  - Further testing on listener removal reliability might be needed.
  - Consider performance implications of the `DomEvent` wrapper creation on
    every event.
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
- **Structure Framework Core:** (`dust_dom` created) Continue defining the
  directory structure and modules (`packages/core`, etc.).
- **Complete Renderer Refactoring:** Finish replacing all direct DOM JS interop
  in the renderer with `dust_dom`.

## Active Decisions & Considerations

- **DOM Abstraction Strategy:** Using `@staticInterop` in `dust_dom` for type
  safety and potential performance benefits over dynamic JS interop.
- **Renderer Refactoring:** Proceeding incrementally, replacing direct JS calls
  with `dust_dom` methods.
- **Event Object Wrapping:** Using `DomEvent` wrapper.
- **Listener Update Strategy:** Always remove/add in `_patch`.
- **JS Interop for Events:** Using `.toJS` on wrapper.
- **Listener Reference Storage:** Using `jsFunctionRefs` on `VNode`.
- **(Previous) VNode as Build Output:** Confirmed.
- **(Previous) Renderer Update Strategy:** Keyed diffing implemented.
- **(Previous) VNode Location:** Confirmed.
- **(Previous) WASM Loading:** Confirmed.
- **(Previous) JS Interop:** Shifting away from direct JS interop in renderer
  towards `dust_dom`.
- **(Previous) State Management Integration:** Riverpod temporary.
- **(Previous) Build Tooling:** `dhttpd` sufficient for now.
