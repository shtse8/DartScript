# Dust System Patterns

## Core Framework Architecture

- **WASM Runtime:** The foundation remains a Dart runtime compiled to
  WebAssembly (WASM) using `dart compile wasm`, executing within the browser's
  WASM VM.
- **Component Model:**
  - UI is built by composing reusable **Components**.
  - Components encapsulate their own **State** and receive data via **Props**.
  - Components have a defined **Lifecycle** (e.g., creation, update,
    destruction).
- **Declarative Rendering Engine:**
  - Developers declare the desired UI state using components.
  - The framework uses a mechanism (e.g., **Virtual DOM diffing** or similar) to
    efficiently calculate the minimal DOM changes required to match the declared
    state.
  - Updates are batched and applied to the actual DOM.
- **State Management:**
  - Provides patterns for managing application state, potentially including:
    - **Local Component State:** State confined to a single component.
    - **Prop Drilling:** Passing state down the component tree.
    - **Context API / Inherited Widget Pattern:** Making state available to
      subtrees without explicit prop passing.
    - **(Potentially) Integration with dedicated state management libraries.**
- **Routing:**
  - Implements a client-side routing system to enable Single Page Application
    (SPA) navigation based on URL changes.
- **JavaScript Bridge (Framework Focused):**
  - Facilitates communication between the Dart WASM environment and browser
    APIs.
  - Optimized for framework needs: efficient batch DOM updates, event listener
    management, access to browser APIs (fetch, localStorage, etc.).
  - Relies on Dart calling predefined, optimized JS helper functions.
- **Application Entry Point:**
  - Moves away from `<dart-script>` for raw code.
  - A standard JavaScript loader initializes the Dart WASM runtime and starts
    the main Dart application/framework entry point (e.g., mounting the root
    component).
- **Sandboxing:** Execution remains within the browser's secure WASM sandbox.

## Key Technical Decisions (Framework Context)

- **Rendering Strategy:** Virtual DOM vs. other approaches (e.g., incremental
  DOM, fine-grained reactivity)? Performance and complexity trade-offs.
- **Component API Design:** Class-based vs. function-based components? How to
  define state, props, lifecycle methods?
- **State Management Approach:** Provide a built-in solution or recommend
  external libraries? Simplicity vs. flexibility.
- **JS/WASM Bridge Implementation:** Continue using `dart:js_interop`? How to
  optimize calls for rendering performance?
- **Build Tooling Integration:** How will the framework integrate with build
  tools for development (hot reload) and production (tree shaking,
  optimization)?

## Core Patterns

- **Component Pattern:** Building UI via composition.
- **Observer Pattern:** Used extensively for state updates triggering
  re-renders.
- **Facade Pattern:** Creating Dart-friendly wrappers around browser APIs via
  the JS bridge.
- **Virtual DOM / Diffing Algorithm:** (If chosen) For efficient DOM updates.
- **Dependency Injection / Service Locator:** Potentially used for managing
  services or state.
- **Router Pattern:** For managing application views and navigation.
