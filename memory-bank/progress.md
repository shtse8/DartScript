# Dust Progress

## What Works (Foundational Elements & Basic Update PoC)

- **Memory Bank Established:** Core documentation structure created and updated.
- **Core WASM Capabilities Proven (PoC).**
- **DOM Abstraction Layer (`dust_dom`).**
- **WASM Loading Mechanism (`build_runner` generated).**
- **Component Model (VNode + Key + Component Lifecycle Support + Typed Props):**
  - Base `Component` with `Key?` and `Props?`.
  - `StatelessWidget<P extends Props?>` and `StatefulWidget<P extends Props?>`
    with typed `props`.
  - `State<T extends StatefulWidget>` with access to `widget.props`.
  - `BuildContext` defined and passed down.
  - `Key`, `ValueKey`, `Props` interfaces defined.
  - `VNode` structure updated. HTML helpers available (`html.text`, `html.a`
    added).
- **Renderer (Component Lifecycle + Keyed Diffing + Event Handling +
  Anchoring):** (Largely functional, see previous state)
- **State Update (Keyed Diffing & setState):** `setState` correctly triggers
  component updates.
- **Demo Application (Props Tester - Conditional Listener):** Successfully
  demonstrates component updates with typed props.
- **Atomic CSS Generation (Build-Time, Refactored & Expanded):** Two-phase
  builder generates comprehensive atomic CSS.
- **Basic Riverpod Integration & Scoping:** `ProviderScope` and `Consumer`
  updated for typed props. Container passed via `BuildContext`. `ProviderScope`
  now handles dynamic override changes in `didUpdateWidget`.
- **Router Package Setup & Basic Functionality:**
  - Created `dust_router` package.
  - Created `Router` and `Link` components (updated for typed props).
  - Implemented **functional History API-based routing** using `dart:js_interop`
    (`.toJS`, `popstate`, `pathname`, `pushState`, `CustomEvent`,
    `dispatchEvent`). `Link` clicks trigger updates via a custom event, while
    back/forward uses `popstate`. Hash-based routing removed. Shared interop
    definitions updated.
  - Exported router components.
  - Integrated `Router` into `web/main.dart` with basic routes.
  - Added `dust_router` dependency to main project.
- **Successful WASM Compilation:** Application now compiles successfully with JS
  interop based routing.
- **Router Parameter Parsing (Basic):**
  - Router can match paths with parameters (e.g., `/users/:id`).
  - Parameters are extracted using RegExp and passed to the route builder.
  - `ComponentBuilder` signature updated to accept
    `Map<String, String>? params`.
  - `UserPage` demo component created to display parameters.
- **Basic Nested Routing Implemented:**
  - `Route` class supports `children`.
  - `ComponentBuilder` accepts `childVNode`.
  - Router matches and builds nested routes recursively.
  - Parent components (`UserPage`) can render child route VNodes.
  - Example nested route (`/users/:id/profile`) added.

## What's Left to Build (High Level - Framework Focus)

- **Core Framework Implementation:**
  - **Routing System:** Refine `Router` (nested routes). History API support
    (client-side) is now implemented.
  - **Rendering Engine (Diffing):** Further optimize patching logic, handle edge
    cases (fragments, SVG nuances).
  - **Component Model Refinement:** Review typed props implementation.
  - **DOM Abstraction:** Review and potentially expand `dust_dom`.
  - **Event Handling:** Test edge cases for listener removal. Evaluate
    `DomEvent` performance.
  - **State Management Integration:** Refine `ProviderScope` (dynamic override
    updates).
- **Developer Experience Tooling:**
  - **Build System:** Optimize production builds.
  - **Development Server:** Implement hot reload (currently Hot Restart).
  - **Atomic CSS:** Add features like theming, responsive prefixes.
- **Documentation & Examples:** Expand significantly.

## Current Status

- **History API Routing Functional (Client-Side):** History API routing works
  using JS interop. `Link` component uses `pushState` and dispatches a custom
  event. `Router` listens for `popstate` and the custom event, reads `pathname`,
  parses parameters (e.g., `/users/:id`), and renders the corresponding
  component, passing extracted parameters.
- **Typed Props System Implemented:** Core component classes refactored for
  type-safe props. Demos updated.
- **WASM Build Successful:** Core framework and demo app compile to WASM without
  critical errors. (Recent JS interop warnings in `web_interop.dart` resolved).
- **Renderer Core Stable:** Anchoring, lifecycle, keyed diffing, event handling
  basics are functional.
- **Atomic CSS Builder Functional:** Generates CSS based on code analysis.
- **Basic Riverpod Integration & Scoping Functional:** Works with the new typed
  props system.
- **Development Workflow:** `build_runner serve` provides Hot Restart and
  successful builds.

## Known Issues / Challenges

- **Router Implementation:** Basic nested routing implemented. Further
  refinement (e.g., relative links, more complex scenarios) might be needed.
  History API support (client-side) is implemented.
- **Renderer Optimization:** Patching logic can likely be further optimized.
- **Renderer Edge Cases:** Handling fragments, SVG, specific attribute/property
  types needs more testing.
- **State Management Integration:** Dynamic override changes in
  `ProviderScope.didUpdateWidget` are now handled (basic implementation).
  Further testing or refinement might be needed for complex override scenarios
  or state migration.
- **JS Interop Performance:** Ongoing consideration.
- **WASM Debugging:** Remains a factor.
- **Bundle Size:** Needs monitoring.
- **Hot Reload Implementation:** Significant challenge remains.
- **Server-Side Routing Fallback:** Refreshing on non-root paths currently
  results in a 404. Requires server configuration (e.g., in `build.yaml` for dev
  server, or production server config) to redirect all paths to `index.html`.
