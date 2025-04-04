# Dust Active Context

## Current Focus

# (Focus shifted to renderer/lifecycle/events for now)

- **Refining Renderer & Component Lifecycle:** Further optimize patching logic,
  handle edge cases, address TODOs in component mount/update/unmount.
- **Refining Event Handling:** Test recursive listener removal reliability.
  Consider performance of `DomEvent` wrapper.

## Recent Changes

- **Setup Props Testing:**
  - Converted `HelloWorld` to `StatefulWidget` to manage listener state
    internally.
  - Modified `HelloWorld` to conditionally add/remove a `mouseover` listener
    based on the length of the `name` prop (accessed via
    `widget.props['name']`).
  - Created `PropTester` stateful component (`lib/prop_tester.dart`) which
    cycles through a list of names and passes the current name as a prop to
    `HelloWorld`.
  - Updated `web/main.dart` to use `PropTester` as the root component. This
    setup allows testing the dynamic addition/removal of event listeners when
    props change.
- **(Previous) Implemented Basic Props:**
  - Added `props` map (`Map<String, dynamic>`) to `Component` base class and
    updated constructors for `Component`, `StatelessWidget`, and
    `StatefulWidget` to accept and pass props.
  - Removed `const` from `HelloWorld` constructor as props map is not
    compile-time constant.
  - Updated `HelloWorld` example to accept a `name` parameter via constructor
    and access it through `props['name']` in the `build` method.
  - Updated `web/main.dart` to pass the `name` parameter when creating
    `HelloWorld`.
  - Confirmed that `State.didUpdateWidget` implicitly receives props updates via
    the `widget` property update handled by `frameworkUpdateWidget`.
- **(Previous) Updated StatelessWidget API:**
  - Modified `StatelessWidget.build` method signature in
    `packages/component/lib/stateless_component.dart` to accept a `BuildContext`
    parameter (`VNode? build(BuildContext context)`).
  - Updated `renderer.dart` (`_mountComponent`, `_updateComponent`,
    `_renderInternal`) to pass the `BuildContext` when calling
    `StatelessWidget.build`.
  - Handled the potentially null `VNode?` return type from `build` in the
    renderer.
  - Updated `HelloWorld` example component (`lib/hello_world.dart`) to match the
    new signature and use HTML helpers.
- **Optimized Event Listener Updates:**
  - Added `dartCallbackRefs` map to `VNode` to store original Dart callbacks.
  - Updated `_patch` in `renderer.dart` to use `identical()` to compare old and
    new Dart callbacks. If identical, listener removal/addition is skipped,
    improving performance for stable callback references.
- **Improved Renderer Robustness:**
  - Added stricter type checks and null checks in `_unmountComponent` before
    accessing `domNode.parentNode` to prevent errors if the `domNode` reference
    is invalid.
  - Removed obsolete TODO comment about `createTextNode` in `_createDomElement`.
- **(Previous) Refactored Atomic CSS Aggregation:**
  - Refactored `AtomicCssAggregator` to `Builder`, using `findAssets` for
    correct aggregation.
  - Updated related build configurations and removed unused files.
- **(Previous) Refactored Atomic CSS Rules:**
  - Split the large `atomicRules` map in
    `packages/atomic_styles/lib/src/rules.dart` into multiple category-specific
    files within a new `packages/atomic_styles/lib/src/rules/` directory.
  - Created `packages/atomic_styles/lib/src/constants.dart` for shared values.
  - Updated `packages/atomic_styles/lib/src/rules.dart` to import and merge
    rules.
- **(Previous) Implemented Basic Component Lifecycle Management in Renderer
  (`renderer.dart`):**
  - **Updated `VNode`:** Added `state` and `renderedVNode` properties to store
    associated state object and rendered subtree for component VNodes.
  - **Updated `Component`:** Added optional `key` property. Created `key.dart`.
  - **Updated HTML Helpers (`html.dart`):** Modified `children` parameter to
    accept `List<Object>` and handle `Component`, `VNode`, `String` types
    internally, creating `VNode.component` where appropriate.
  - **Refactored `_patch`:** Added logic to differentiate between component
    VNodes and element/text VNodes. Introduced calls to `_mountComponent`,
    `_updateComponent`, `_unmountComponent`. Moved listener/node removal helpers
    (`_removeListenersFromNode`, `_removeListenersRecursively`, `removeVNode`)
    outside `_patchChildren` and adjusted parameters/calls.
  - **Implemented `_mountComponent`:** Handles creation of `State` for
    `StatefulWidget`, sets `updateRequester` callback (which now contains update
    logic), calls `initState`/`build`, recursively patches the rendered tree,
    and associates state/renderedVNode/domNode.
  - **Implemented `_updateComponent`:** Handles component type/key checks
    (simple unmount/mount for now), reuses `State` for `StatefulWidget`, calls
    `didUpdateWidget`/`build`, recursively patches the new rendered tree against
    the old one.
  - **Implemented `_unmountComponent`:** Calls `dispose` on `State` for
    `StatefulWidget`, recursively unmounts the rendered tree (using
    `removeVNode` for cleanup), and clears references.
  - **Implemented `setState` Update Path:** The `updateRequester` callback set
    in `_mountComponent` now correctly calls `state.build()` and `_patch` to
    update the component's rendered subtree when `setState` is called.
- **Implemented Atomic CSS Generation (Build-Time):**
  - Created `packages/atomic_styles` package.
  - Defined initial atomic rules (margin, padding, text color, font weight) in
    `lib/src/rules.dart`.
  - Implemented `AtomicStyleBuilder` (`lib/src/builder.dart`) to scan Dart files
    using `analyzer`, extract class names from HTML helpers, and output per-file
    `.classes` files to cache.
  - Implemented `AtomicStyleBuilder` (`atomicScanner`) to scan Dart files,
    extract class names, and output per-file `.classes` files to cache.
  - Implemented `AtomicCssAggregator` (`cssAggregatorBuilder`) as a `Builder` to
    read all `.classes` files using `findAssets`, aggregate unique class names,
    generate final CSS using `generateAtomicCss`, and write to
    `web/atomic_styles.css`.
  - Created builder factories in `lib/builder.dart` (updated for aggregator).
  - Configured both builders (`atomicScanner`, `cssAggregatorBuilder`) in
    `packages/atomic_styles/build.yaml` (updated for aggregator) and applied
    them in the root `build.yaml`.
  - Updated `web/index.html` to link `atomic_styles.css`.
  - Tested with basic classes in `TodoListComponent`, confirmed CSS generation.

- **Introduced Basic BuildContext:**
  - Created `packages/component/lib/context.dart` defining a simple
    `BuildContext` class holding a `ProviderContainer`.
  - Added `late BuildContext context;` property to `State` class
    (`packages/component/lib/state.dart`).
  - Modified `renderer.dart` (`runApp`, `_renderInternal`, `_performRender`,
    `_patch`, `_patchChildren`) to create and pass `BuildContext` down the tree
    during initial render and updates.
  - Updated `Consumer` widget to retrieve `ProviderContainer` from `context`
    instead of a global variable.

- **Completed Renderer DOM Abstraction:** Replaced remaining direct JS interop
  calls in `renderer.dart` (`addEventListener`, `removeEventListener`,
  `removeChild`, `replaceChild`, `insertBefore`, `textContent`) with
  corresponding methods from `dust_dom`.

- **Integrated Riverpod (Basic):**
  - Added `riverpod` dependency to `dust_component` and `dust_renderer`.
  - Modified `runApp` in `dust_renderer` to create and store a global
    `ProviderContainer` (temporary solution).
  - Created `Consumer` widget (`packages/component/lib/consumer.dart`) extending
    `StatefulWidget`.
  - Implemented a basic `WidgetRef` that allows `watch`, `read`, `listen` by
    interacting with the global container and triggering `setState` on the
    `_ConsumerState`.
  - Updated `README.md` example to demonstrate basic Provider/Consumer usage.

- **Introduced HTML Helper Functions:**
  - Created `packages/component/lib/html.dart` with functions (`div`, `h1`,
    `li`, `button`, `text`, etc.) for creating `VNode`s with a more declarative
    syntax.
  - Updated `_element` helper to use `VNode.element` and handle `text` parameter
    correctly.
  - Updated `text` helper to use `VNode.text`.
  - Updated `README.md` basic example to use the new helpers.
  - Updated `lib/todo_list.dart` demo to use the new helpers.

- **Refined Application Entry Point:**
  - Added `runApp(Component component, String targetElementId)` function to
    `packages/renderer/lib/renderer.dart` as the public API for starting an
    application.
  - Simplified `web/main.dart` to only import the root component and call
    `runApp`, removing direct JS interop (`consoleLog`) and internal rendering
    logic.

- **Setup `build_runner` Dev Server (Hot Restart):**
  - Enabled `build_runner` and `build_web_compilers` in root `pubspec.yaml`.
  - Ran `dart pub get`.
  - Created `web/` directory.
  - Moved `lib/main.dart` to `web/main.dart`.
  - Moved `style.css` to `web/style.css`.
  - Created `build.yaml` to configure WASM compilation for `web/main.dart`.
  - Updated `web/index.html` to load `main.dart.js`.
  - Updated `web/main.dart` import paths.
  - Started dev server using `dart run build_runner serve web:8081`.
  - Created `.gitignore` file.
  - Cleaned Git index to remove previously committed ignored files (split into
    two commits: "Add .gitignore" and "Setup build_runner...").

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
- **Updated Renderer (`packages/renderer/lib/renderer.dart`):**
  - Modified `_patchChildren` -> `removeVNode` helper function to
    **recursively** remove event listeners from the node and its children (using
    stored `jsFunctionRefs` and new helpers `_removeListenersRecursively`,
    `_removeListenersFromNode`) _before_ removing the DOM node itself, ensuring
    proper cleanup.
- **Previous Changes (Still Relevant):**
  - Added Riverpod Dependency & Clock Demo.
  - Improved WASM Loading (`js/app_bootstrap.js`).
  - Enhanced Basic Renderer (Stateful handling, simplified update mechanism).
  - Debugging efforts.

## Next Steps

- **(Done) Integrating DOM Abstraction:** All identified direct JS interop calls
  in `renderer.dart` have been replaced with `dust_dom` abstractions.
- **Refine Event Handling:** (Partially addressed)
  - **Recursive listener removal logic added** to `removeVNode` (via
    `_removeListenersRecursively`) in `_patchChildren`. Further testing on
    reliability might be needed.
  - Consider performance implications of the `DomEvent` wrapper creation on
    every event.
- **Refine Diffing/Patching:** (Keyed diffing implemented) Further optimize
  patching logic, handle edge cases more robustly.
- **Refine Component API:** (Props basics implemented) Consider typed props or
  more structured prop handling mechanisms.
- **Improve Renderer:**
  - **(Partially Done)** Manage component lifecycle (`mount`, `update`,
    `dispose`) via `_patch`, `_mountComponent`, `_updateComponent`,
    `_unmountComponent`.
  - **(Partially Done)** Implemented basic `setState` update path via
    `updateRequester` callback. Needs further refinement (e.g., fragment
    handling, performance).
  - Continue refining handling of edge cases in patching.
- **(Future Goal) Refactor Consumer/State Management:** Implement a context
  mechanism (like `BuildContext` + `InheritedWidget`) to replace global
  `ProviderContainer` access and potentially enable a `ConsumerWidget` pattern
  closer to Flutter's `build(context, ref)`.
- **(Future Goal) Refactor Consumer/State Management:** Implement a context
  mechanism (like `BuildContext` + `InheritedWidget`) to replace global
  `ProviderContainer` access and potentially enable a `ConsumerWidget` pattern
  closer to Flutter's `build(context, ref)`.
- **(Future Goal) Refactor Consumer/State Management:** Implement a context
  mechanism (like `BuildContext` + `InheritedWidget`) to replace global
  `ProviderContainer` access and potentially enable a `ConsumerWidget` pattern
  closer to Flutter's `build(context, ref)`.
- **(Future Goal) Refactor Consumer/State Management:** Implement a context
  mechanism (like `BuildContext` + `InheritedWidget`) to replace global
  `ProviderContainer` access and potentially enable a `ConsumerWidget` pattern
  closer to Flutter's `build(context, ref)`.
- **(Future Goal) Refactor Consumer/State Management:** Implement a context
  mechanism (like `BuildContext` + `InheritedWidget`) to replace global
  `ProviderContainer` access and potentially enable a `ConsumerWidget` pattern
  closer to Flutter's `build(context, ref)`.
  - (Partially done) Continue refining handling of edge cases in patching.
- **(Done) Setup Atomic CSS Builder:** Infrastructure created and aggregation
  logic refactored to correctly use `Builder` and `findAssets`.
- **Integrate Riverpod Properly:** (Context passing implemented)
  - Replaced global `ProviderContainer` access with `BuildContext` passing.
  - `Consumer` now uses `context.container`.
  - Next steps: Ensure `WidgetRef` disposal and lifecycle are robust, test more
    complex provider types.
- **Structure Framework Core:** (`dust_dom` created) Continue defining the
  directory structure and modules (`packages/core`, etc.).
- **(Done) Complete Renderer Refactoring:** All identified direct DOM JS interop
  calls in the renderer have been replaced with `dust_dom`.
- **(Done) Setup Dev Server:** `build_runner` now provides Hot Restart.
- **(Done) Refine Entry Point:** `runApp` function created for user convenience.

## Active Decisions & Considerations

- **Riverpod Integration:** `ProviderContainer` is now passed down via a basic
  `BuildContext` object created by the renderer. `Consumer` accesses the
  container through `context.container`. This removes the need for a global
  container variable. The `Consumer` still extends `StatefulWidget` and uses a
  custom `WidgetRef` due to framework limitations (lack of Flutter's
  `InheritedWidget` equivalent). Aligning closer to Flutter's pattern remains a
  future goal.
- **Component Syntax:** Providing HTML helper functions (`div`, `h1`, etc.) in
  `package:dust_component/html.dart` for a more declarative UI definition
  experience.
- **Application Entry Point:** Use `runApp` function in renderer as the public
  API. User's `main.dart` should be simple and call `runApp`.
- **Development Server:** Using `build_runner serve web` for development,
  providing Hot Restart.
- **DOM Abstraction Strategy:** Using `@staticInterop` in `dust_dom` for type
  safety and potential performance benefits over dynamic JS interop.
- **Renderer Refactoring:** Completed replacement of direct JS calls with
  `dust_dom` methods in `renderer.dart`.
- **Event Object Wrapping:** Using `DomEvent` wrapper.
- **Listener Update Strategy:** Always remove/add in `_patch`. Listeners are
  recursively and explicitly removed in `removeVNode` (now a top-level helper)
  before DOM node removal.
- **Component Lifecycle:** Basic mount, update, unmount logic implemented in
  `_patch` using helper functions. `State.dispose` is called during unmount.
  `State.initState` and `State.didUpdateWidget` are triggered via
  `frameworkUpdateWidget`. `setState` now triggers updates via the
  `updateRequester` callback which calls `build` and `_patch`.
- **JS Interop for Events:** Using `.toJS` on wrapper.
- **Atomic CSS Strategy:** Using a two-phase build-time approach:
  1. `AtomicStyleBuilder` (`atomicScanner`) scans Dart code, extracts classes,
     outputs `.classes` files to cache.
  2. `AtomicCssAggregator` (`cssAggregatorBuilder`) reads all `.classes` files
     using `findAssets`, aggregates classes, generates final CSS
     (`web/atomic_styles.css`).
- **Listener Reference Storage:** Using `jsFunctionRefs` on `VNode` (used for
  removal).
- **(Previous) VNode as Build Output:** Confirmed.
- **(Previous) Renderer Update Strategy:** Keyed diffing implemented.
- **(Previous) VNode Location:** Confirmed.
- **(Previous) WASM Loading:** Confirmed (`build_runner` generates loader JS).
- **(Previous) JS Interop:** Direct JS interop calls in the renderer have been
  replaced by the `dust_dom` abstraction layer.
- **(Removed) State Management Integration:** Riverpod basic integration
  started.
- **(Removed) Build Tooling:** `dhttpd` replaced by `build_runner`.

- **Application Entry Point:** Use `runApp` function in renderer as the public
  API. User's `main.dart` should be simple and call `runApp`.
- **Development Server:** Using `build_runner serve web` for development,
  providing Hot Restart.
- **DOM Abstraction Strategy:** Using `@staticInterop` in `dust_dom` for type
  safety and potential performance benefits over dynamic JS interop.
- **Renderer Refactoring:** Completed replacement of direct JS calls with
  `dust_dom` methods in `renderer.dart`.
- **Event Object Wrapping:** Using `DomEvent` wrapper.
- **Listener Update Strategy:** Always remove/add in `_patch`.
- **JS Interop for Events:** Using `.toJS` on wrapper.
- **Listener Reference Storage:** Using `jsFunctionRefs` on `VNode`.
- **(Previous) VNode as Build Output:** Confirmed.
- **(Previous) Renderer Update Strategy:** Keyed diffing implemented.
- **(Previous) VNode Location:** Confirmed.
- **(Previous) WASM Loading:** Confirmed (`build_runner` generates loader JS).
- **(Previous) JS Interop:** Direct JS interop calls in the renderer have been
  replaced by the `dust_dom` abstraction layer.
