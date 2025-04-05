# Dust Active Context

## Current Focus

- **Refining Renderer & Component Lifecycle:** Continue optimizing patching
  logic, handling edge cases (e.g., fragments, complex nesting), and ensuring
  lifecycle methods are consistently called.
- **State Management Integration:** Improve Riverpod integration, potentially
  exploring context patterns closer to Flutter's `InheritedWidget` for provider
  access.
- **Routing System:** Begin design and implementation of the client-side SPA
  router.

## Recent Changes

- **Implemented Basic Provider Scoping:**
  - Created `ProviderScope` component
    (`packages/component/lib/provider_scope.dart`) which creates a new
    `ProviderContainer` with optional overrides, inheriting from the parent
    container accessed via `BuildContext`.
  - Added a public `childContext` getter to `_ProviderScopeState` for the
    renderer.
  - Modified renderer (`_mountComponent`, `_updateComponent`) to detect
    `ProviderScope` components and use their `childContext` when patching their
    child VNode, effectively passing the scoped container down.
  - Updated `HelloWorld` demo to use a `Consumer` and define a
    `messageProvider`.
  - Updated `web/main.dart` to wrap the root app in a `ProviderScope` that
    overrides `messageProvider`, successfully demonstrating the scoping
    mechanism.
- **(Previous) Removed Global ProviderContainer:** Modified `renderer.dart` to
  remove the global `_appProviderContainer`. The container is now created
  locally within `runApp` and passed down solely via `BuildContext`. Verified
  that `Consumer` widget correctly accesses the container via
  `context.container`.
- **(Previous) Implemented Anchor Nodes for Components:** Refactored the
  renderer (`_mountComponent`, `_updateComponent`, `_unmountComponent`,
  `_patch`, `_mountNodeAndChildren`) to use comment nodes as start and end
  anchors for components.
- **(Previous) Fixed Anchor Insertion Order:** Corrected `_mountComponent`.
- **(Previous) Cleaned Up Renderer Mounting Logic:** Removed redundant
  `_createDomElement`.
- **(Previous) Fixed Initial Component Mount Bug:** Corrected `_patch` logic for
  initial renders.
- **(Previous) Verified Listener Update/Removal:** Confirmed listener
  management.
- **(Previous) Refined Component Update Logic:** Reuses `State` object.
- **(Previous) Setup Props Testing & Implemented Basic Props.**
- **(Previous) Updated StatelessWidget API.**
- **(Previous) Optimized Event Listener Updates.**
- **(Previous) Improved Renderer Robustness.**
- **(Previous) Refactored Atomic CSS Aggregation & Rules.**
- **(Previous) Implemented Basic Component Lifecycle Management.**
- **(Previous) Implemented Atomic CSS Generation.**
- **(Previous) Introduced Basic BuildContext.**
- **(Previous) Completed Renderer DOM Abstraction.**
- **(Previous) Integrated Riverpod (Basic - now improved with scoping).**
- **(Previous) Introduced HTML Helper Functions.**
- **(Previous) Refined Application Entry Point (`runApp`).**
- **(Previous) Setup `build_runner` Dev Server.**
- **(Previous) Created `dust_dom` Package & Started Renderer Refactoring.**
- **(Previous) Updated VNode Structure & Component API.**
- **(Previous) Created `DomEvent` Wrapper.**
- **(Previous) Updated Renderer for Event Handling.**
- **(Previous) Updated TodoList Demo.**

## Next Steps

- **Start Routing Implementation.**
- **Refine ProviderScope:** Handle dynamic override changes in
  `didUpdateWidget`.
- **Expand Atomic CSS Rules & Features.**
- **Further Renderer Optimizations & Edge Case Handling.**

## Active Decisions & Considerations

- **Provider Scoping:** Implemented via `ProviderScope` component and renderer
  modification. Renderer checks for `ProviderScope` and passes its internally
  created `BuildContext` (with the scoped/overridden container) to its child
  during mount/update. Access to the child context from the state uses a public
  getter (`childContext`) due to dynamic access limitations on private members.
- **Initial Render Logic:** `_patch` correctly uses `_mountComponent` or
  `_mountNodeAndChildren`.
- **Component Update Logic:** `_updateComponent` reuses `State`.
- **Listener Management:** `identical()` check optimizes updates; recursive
  removal.
- **Component DOM Anchoring:** Uses comment nodes.
- **ProviderContainer Scope:** Root container created in `runApp`, passed via
  root `BuildContext`. No global container.
- **(Previous decisions still apply regarding Component Syntax, `runApp`,
  `build_runner`, `dust_dom`, `DomEvent`, etc.)**
