# Dust Active Context

## Current Focus

- **Refine `Router` Component:** Add parameter parsing, nested routes,
  potentially History API support (using JS interop).
- **Refining Renderer & Component Lifecycle:** Continue optimizing patching
  logic, handling edge cases (e.g., fragments, complex nesting), and ensuring
  lifecycle methods are consistently called.
- **State Management Integration:** Improve Riverpod integration, potentially
  exploring context patterns closer to Flutter's `InheritedWidget` for provider
  access.

## Recent Changes

- **Enabled Router JS Interop using `.toJS`:**
  - Identified that `allowInterop` is deprecated/incorrect for current JS
    interop usage.
  - Corrected `Router` component (`router.dart`) to use the `.toJS` extension
    method for converting the Dart event handler callback (`_handleHashChange`)
    into a `JSFunction` suitable for `window.addEventListener`.
  - Created a shared `web_interop.dart` file to define `window` and `location`
    JS interop bindings, resolving name conflicts between `router.dart` and
    `link.dart`.
  - Updated `router.dart` and `link.dart` to use the shared interop definitions.
  - Successfully enabled `hashchange` event listening and hash reading/writing
    using `dart:js_interop`, removing the need for `dart:html` and resolving
    WASM compilation issues.
- **Refactored Props System:**
  - Created `Props` marker interface (`props.dart`).
  - Created `BuildContext` class (`build_context.dart`), replacing old
    `context.dart`.
  - Created `Key` class and `ValueKey` (`key.dart`).
  - Modified `Component` base class to use `Props? props`.
  - Modified `StatelessWidget` and `StatefulWidget` to be generic
    (`<P extends Props?>`) and accept typed `props`.
  - Updated `ClockComponent`, `TodoListComponent`, `Consumer`, `ProviderScope`,
    `Router`, `Link`, `HelloWorld`, `PropTester` to use the new typed props
    system and updated constructors.
  - Corrected numerous import errors related to `BuildContext`, `Props`, `Key`,
    `State`, `DomEvent`.
  - Corrected `build` method signatures and return types in `Router`, `Link`,
    and `Home`.
  - Corrected `html.text` usage in `web/main.dart`.
  - Added `html.a` helper function to `html.dart`.
- **Integrated Router (Basic Structure):**
  - Created `Link` component skeleton (`link.dart`).
  - Exported `Router`, `Route`, `Link` from `dust_router.dart`.
  - Added `dust_router` dependency to main `pubspec.yaml` and ran
    `dart pub get`.
  - Integrated `Router` and defined basic routes in `web/main.dart`.
- **(Previous) Created `dust_router` Package Structure:** (Details omitted)
- **(Previous) Implemented Basic Provider Scoping:** (Details omitted)
- **(Previous) Removed Global ProviderContainer:** (Details omitted)
- **(Previous) Implemented Anchor Nodes for Components:** (Details omitted)
- **(Previous) Various Renderer Fixes & Refinements:** (Details omitted)

## Next Steps

- **Refine `Router` Component:** Add parameter parsing, nested routes,
  potentially History API support (using JS interop).
- **Refine ProviderScope:** Handle dynamic override changes in
  `didUpdateWidget`.
- **Expand Atomic CSS Rules & Features.**
- **Further Renderer Optimizations & Edge Case Handling.**

## Active Decisions & Considerations

- **JS Interop for Events:** Use the `.toJS` extension method (from
  `dart:js_interop`) on Dart callback functions to convert them into
  `JSFunction` suitable for passing to JS APIs like `addEventListener`. The
  older `allowInterop` function is no longer the correct approach for this.
  Share common JS object bindings (like `window`, `location`) in a separate file
  (`web_interop.dart`) to avoid conflicts.
- **Props System:** Moved to a typed props system using a `Props` marker
  interface and generics on `StatelessWidget`/`StatefulWidget`. Base `Component`
  uses `Props?`.
- **BuildContext:** Defined in `build_context.dart`, contains
  `ProviderContainer`. Old `context.dart` removed.
- **Router Implementation Strategy:** Basic hash-based routing implemented using
  JS interop.
- **HTML Helpers:** `a` tag helper added. Text nodes created via `html.text()`.
- **(Previous decisions still apply regarding Component Syntax, `runApp`,
  `build_runner`, `dust_dom`, `DomEvent`, Provider Scoping, Anchoring, etc.)**
