<!-- Version: 1.0 | Last Updated: 2025-05-04 | Updated By: Cline -->

# Dust Active Context

## Current Focus

- **Refine `Router` Component:** Implement nested routes. **History API support
  is now fully functional**, replacing hash-based routing. Basic parameter
  parsing remains functional. Client-side navigation via links and browser
  back/forward buttons works correctly using a combination of `popstate` and a
  custom `dustnavigate` event dispatched by the `Link` component.
- **Refining Renderer & Component Lifecycle:** Continue optimizing patching
  logic, handling edge cases (e.g., fragments, complex nesting), and ensuring
  lifecycle methods are consistently called.
- **State Management Integration:** Improve Riverpod integration, potentially
  exploring context patterns closer to Flutter's `InheritedWidget` for provider
  access.

## Recent Changes

- **Updated README:** Added a framework comparison table (Flutter, Vue, React,
  Angular, Dust) and a list of current gaps compared to mature frameworks.

- **Optimized Renderer Attribute Patching:** Added an `identical` check in the
  `_patch` function to skip attribute updates if the old and new attribute maps
  are the same instance, potentially improving performance when attributes
  haven't changed.

- **Improved ProviderScope Override Handling:** Implemented `didUpdateWidget` in
  `_ProviderScopeState` to detect changes in `overrides`. If overrides differ,
  the old `ProviderContainer` is disposed, and a new one is created with the
  updated overrides, ensuring dynamic changes propagate correctly. Added a basic
  `_listEquals` helper for comparison.

- **Implemented Basic Nested Routing:**
  - Modified `Route` class to include optional `children`.
  - Updated `ComponentBuilder` typedef to accept an optional `childVNode`.
  - Refactored router matching logic (`_findMatchingRouteRecursive`) to handle
    nested paths and return a route chain.
  - Updated router `build` method to recursively build the VNode tree based on
    the matched chain, passing child VNodes to parent builders.
  - Added `hr` helper to `html.dart`.
  - Updated `web/main.dart` with a nested route example (`/users/:id/profile`)
    and a placeholder `UserProfilePage` component.
  - Modified `UserPage` component (`lib/user_page.dart`) to accept and render
    `childVNode` and added a link to the nested profile route.

- **Fixed JS Interop Warnings:** Removed default parameter values from
  `EventInit` and `CustomEventInit` external factory constructors in
  `web_interop.dart` to resolve build warnings.

- **Implemented History API Routing:**
  - Updated `web_interop.dart` with bindings for `history.pushState`,
    `popstate`, `location.pathname`, `CustomEvent`, and `window.dispatchEvent`.
  - Modified `Link` component (`link.dart`) to use `history.pushState` and
    dispatch a custom `dustnavigate` event on click.
  - Modified `Router` component (`router.dart`) to listen for both `popstate`
    (for back/forward) and `dustnavigate` (for link clicks) events, triggering
    path updates accordingly.
  - Removed hash-based routing logic.
  - Cleaned up debug print statements.
- **Implemented Basic Router Parameter Parsing:** (Previous change)
  - Updated `ComponentBuilder` typedef in `router.dart` to accept
    `Map<String, String>? params`.
  - Implemented `_matchRoute` method in `_RouterState` using `RegExp` to extract
    parameters from the path (e.g., `/users/:id`).
  - Updated route builders in `web/main.dart` to match the new
    `ComponentBuilder` signature.
  - Created `UserPage` component (`lib/user_page.dart`) to display extracted
    parameters.
  - Added a parameterized route (`/users/:id`) and a test link (`/users/123`) in
    `web/main.dart`.
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

- **Refine `Router` Component:** Implement nested routes.
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
- **Router Implementation Strategy:** History API routing is used via JS interop
  (`pushState`, `popstate`, `pathname`, custom `dustnavigate` event). Basic
  parameter parsing remains functional. Hash-based routing removed. **Note:**
  Direct page refresh on non-root paths requires server-side configuration to
  redirect to `index.html`.
- **HTML Helpers:** `a` tag helper added. Text nodes created via `html.text()`.
- **(Previous decisions still apply regarding Component Syntax, `runApp`,
  `build_runner`, `dust_dom`, `DomEvent`, Provider Scoping, Anchoring, etc.)**
