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

- **Fixed Initial Component Mount Bug:** Corrected the `_patch` function's logic
  for initial renders (`oldVNode == null`). It now correctly distinguishes
  between component VNodes (calling `_mountComponent`) and element/text VNodes
  (calling a new `_mountNodeAndChildren` helper which recursively uses `_patch`
  for children). This resolved the issue where state objects were lost during
  the first component update because the component wasn't properly mounted
  initially.
- **Verified Listener Update/Removal:** Confirmed (using a fixed key in
  `PropTester`) that after fixing the initial mount bug, the component update
  logic (`_updateComponent`) is correctly triggered, and event listeners are
  properly added/removed based on VNode changes during updates.
- **(Previous) Added Debug Logging for Listener Removal:** Inserted detailed
  `print` statements in `renderer.dart` (`_patch` and
  `_removeListenersFromNode`) to track listener removal (now removed).
- **(Previous) Refined Component Update Logic:** Modified `_updateComponent` in
  `renderer.dart` to reuse the existing `State` object when component type and
  key match.
- **(Previous) Setup Props Testing:** Created `PropTester` and modified
  `HelloWorld` to test dynamic listener updates based on prop changes.
- **(Previous) Implemented Basic Props:** Added `props` map to `Component` and
  updated examples.
- **(Previous) Updated StatelessWidget API:** Changed `build` signature to
  accept `BuildContext`.
- **(Previous) Optimized Event Listener Updates:** Added `dartCallbackRefs` and
  `identical()` check in `_patch`.
- **(Previous) Improved Renderer Robustness:** Added null checks.
- **(Previous) Refactored Atomic CSS Aggregation & Rules.**
- **(Previous) Implemented Basic Component Lifecycle Management in Renderer.**
- **(Previous) Implemented Atomic CSS Generation (Build-Time).**
- **(Previous) Introduced Basic BuildContext.**
- **(Previous) Completed Renderer DOM Abstraction.**
- **(Previous) Integrated Riverpod (Basic).**
- **(Previous) Introduced HTML Helper Functions.**
- **(Previous) Refined Application Entry Point (`runApp`).**
- **(Previous) Setup `build_runner` Dev Server.**
- **(Previous) Created `dust_dom` Package & Started Renderer Refactoring.**
- **(Previous) Updated VNode Structure & Component API.**
- **(Previous) Created `DomEvent` Wrapper.**
- **(Previous) Updated Renderer for Event Handling.**
- **(Previous) Updated TodoList Demo.**

## Next Steps

- **Refine `_mountNodeAndChildren` / `_createDomElement`:** Ensure
  `_createDomElement` is only used for creating the immediate node and
  `_mountNodeAndChildren` correctly handles recursive mounting via `_patch`.
- **Address Renderer Simplifications:** Review areas marked `// Simplification!`
  (like `componentVNode.domNode = renderedVNode.domNode;` in `_mountComponent`)
  and implement more robust handling (e.g., for fragments).
- **Improve State Management:** Refactor Riverpod integration or implement a
  custom context solution.
- **Start Routing Implementation.**
- **Expand Atomic CSS Rules & Features.**

## Active Decisions & Considerations

- **Initial Render Logic:** `_patch` now correctly uses `_mountComponent` for
  components and `_mountNodeAndChildren` (which internally uses `_patch`) for
  elements/text when `oldVNode` is null.
- **Component Update Logic:** `_updateComponent` reuses `State` when keys match.
  State is correctly passed between VNodes during updates.
- **Listener Management:** `identical()` check optimizes updates. Recursive
  removal in `removeVNode` ensures cleanup.
- **(Previous decisions still apply regarding Riverpod, Component Syntax,
  `runApp`, `build_runner`, `dust_dom`, `DomEvent`, etc.)**
