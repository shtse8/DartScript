# Dust Progress

## What Works (Foundational Elements & Basic Update PoC)

- **Memory Bank Established:** Core documentation structure created and updated.
- **Core WASM Capabilities Proven (PoC).**
- **DOM Abstraction Layer (`dust_dom`).**
- **WASM Loading Mechanism (`build_runner` generated).**
- **Component Model (VNode + Key + Component Lifecycle Support):** Includes
  `props`, `key`, `State`, `StatelessWidget` (with `BuildContext`),
  `StatefulWidget`. `VNode` structure updated. HTML helpers available.
- **Renderer (Component Lifecycle + Keyed Diffing + Event Handling +
  Anchoring):**
  - `runApp` entry point.
  - **Component Anchoring:** Uses comment nodes as start/end anchors for robust
    DOM management (`_mountComponent`, `_updateComponent`, `_unmountComponent`).
  - **Cleaned Up Mounting Logic:** Removed redundant `_createDomElement`
    function.
  - **Corrected Initial Component Mount:** `_patch` now correctly uses
    `_mountComponent` or `_mountNodeAndChildren` during initial render
    (`oldVNode == null`), respecting anchors.
  - **Component Lifecycle Management:** `_mountComponent`, `_updateComponent`,
    `_unmountComponent` handle state creation/reuse, `initState`,
    `didUpdateWidget`, `dispose`.
  - **Event Handling:** `DomEvent` wrapper used. Listener updates optimized with
    `identical()` check. Recursive listener removal implemented in `removeVNode`
    and `_unmountComponent` for cleanup.
  - **Keyed Diffing:** `_patchChildren` implements keyed reconciliation,
    respecting insertion points (`referenceNode`).
  - **DOM Interaction:** Uses `dust_dom` abstractions (including
    `createComment`, `nextNode`).
- **State Update (Keyed Diffing & setState):** `setState` correctly triggers
  component updates via the renderer's patching mechanism, handling keyed
  children efficiently.
- **Demo Application (Props Tester - Conditional Listener):** Successfully
  demonstrates component updates (using fixed key) and dynamic listener
  addition/removal based on prop changes.
- **Atomic CSS Generation (Build-Time, Refactored & Expanded):** Two-phase
  builder generates comprehensive atomic CSS based on usage in Dart code.

## What's Left to Build (High Level - Framework Focus)

- **Core Framework Implementation:**
  - **Rendering Engine (Diffing):** Further optimize patching logic, handle edge
    cases (fragments, SVG nuances).
  - **Component Model Refinement:** Consider typed props, context API
    improvements.
  - **DOM Abstraction:** Review and potentially expand `dust_dom`.
  - **Event Handling:** Test edge cases for listener removal. Evaluate
    `DomEvent` performance.
  - **State Management Integration:** Improve Riverpod integration or implement
    custom context solution.
  - **Routing System:** Implement SPA routing.
- **Developer Experience Tooling:**
  - **Build System:** Optimize production builds.
  - **Development Server:** Implement hot reload (currently Hot Restart).
  - **Atomic CSS:** Add features like theming, responsive prefixes.
- **Documentation & Examples:** Expand significantly.

## Current Status

- **Renderer Core Improved:** Implemented component anchoring using comment
  nodes, resolving the previous `domNode` association simplification. Fixed
  initial component mount bug. Component updates and listener management are
  functioning correctly with the new anchoring system.
- **DOM Abstraction Integrated:** `dust_dom` is used for core DOM operations in
  the renderer.
- **Component Lifecycle Basics Working:** `initState`, `didUpdateWidget`,
  `dispose`, and `setState`-triggered updates are functional.
- **Keyed Diffing Working:** `_patchChildren` handles keyed lists.
- **Atomic CSS Builder Functional:** Generates CSS based on code analysis.
- **Basic Riverpod Integration Present:** Needs refinement.
- **Development Workflow:** `build_runner serve` provides Hot Restart.

## Known Issues / Challenges

- **Renderer Optimization:** Patching logic can likely be further optimized.
- **Renderer Edge Cases:** Handling fragments, SVG, specific attribute/property
  types needs more testing and potentially specific logic.
- **State Management Integration:** Current Riverpod usage is basic; needs a
  more robust framework-level solution (e.g., improved context passing).
- **JS Interop Performance:** Ongoing consideration, though `dust_dom` helps.
- **WASM Debugging:** Remains a factor.
- **Bundle Size:** Needs monitoring.
- **Hot Reload Implementation:** Significant challenge remains.
- **Renderer Edge Cases:** Handling fragments (components returning lists) still
  needs implementation, although the anchor system provides the foundation. SVG
  nuances and specific attribute/property types need more testing.
