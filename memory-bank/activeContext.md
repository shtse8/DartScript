# DartScript Active Context

## Current Focus

- **Designing Core Framework Architecture:** Shifting focus from the basic
  loader to designing the foundational elements of the new React/Vue-inspired
  framework. This includes:
  - Defining the **Component Model** (state, props, lifecycle).
  - Sketching out the initial **Declarative Rendering Pipeline** (how components
    translate to DOM).
  - Exploring basic **State Management** strategies.
- **Updating Documentation:** Ensuring all Memory Bank files (`projectbrief.md`,
  `productContext.md`, `systemPatterns.md`, `techContext.md`, `progress.md`) are
  aligned with the new framework vision.

## Recent Changes

- **Major Scope Shift:** Project direction pivoted from a simple PyScript-like
  WASM loader to building a full-fledged, modern Dart web framework.
- **Updated Core Documentation:** `projectbrief.md` and `productContext.md`
  updated to reflect the new framework goals.
- (Historical Context) Created initial project structure (HTML, JS loader, Dart
  source).
- (Historical Context) Debugged Dart-JS interop for WASM compilation.
- (Historical Context) Successfully compiled Dart to WASM (`dart compile wasm`).
- (Historical Context) Successfully loaded WASM module via JS helper
  (`main.mjs`).
- **(Foundational) Implemented Basic DOM API:**
  - Added JS functions (`window.dartScriptSetText`, etc.) to `js/loader.js`.
  - Created Dart wrappers (`DartScriptApi`) in `dart/main.dart`.
  - _This work serves as a foundation for the framework's future DOM abstraction
    layer._
- **(Foundational) Implemented WASM Loading:**
  - `js/loader.js` handles loading pre-compiled WASM via
    `<dart-script src="...">` (or similar mechanism TBD for the final
    framework).
  - _This loading mechanism will likely be adapted for the framework runtime._

## Next Steps

- **Design Component API:** Define the structure for Dart classes/functions
  representing UI components (e.g., how state and props are handled, basic
  lifecycle methods).
- **Implement Basic Renderer:** Create a proof-of-concept renderer that takes a
  simple component definition and generates corresponding DOM nodes using the
  existing `DartScriptApi` or an evolution of it.
- **Prototype State Management:** Research and potentially prototype simple
  state management patterns (e.g., inherited widgets concept, simple
  streams/listeners).
- **Structure Framework Core:** Define the initial directory structure and
  modules for the framework itself (e.g., `core`, `renderer`, `state`).
- **Update `systemPatterns.md`:** Document the high-level architectural
  decisions for the new framework (Component model, rendering approach).
- **Update `techContext.md`:** Add any new dependencies or constraints
  identified during initial design.
- **Update `progress.md`:** Reflect the scope change and the new focus on
  framework design.

## Active Decisions & Considerations

- **Framework Scope:** Confirmed shift to a full, modern web framework inspired
  by React/Vue.
- **JS Interop Pattern:** Continue with the pattern of Dart initiating calls to
  predefined JS functions for DOM manipulation and browser API access, as direct
  JS calls into Dart WASM remain challenging.
- **Loading Mechanism:** While `<dart-script src="...">` was the previous focus,
  the final framework will likely use a standard JS entry point to load the
  compiled Dart application and framework runtime. The exact mechanism needs
  refinement.
- **DOM Abstraction:** The initial `DartScriptApi` needs to evolve into a more
  comprehensive, type-safe, and potentially framework-aware DOM abstraction
  layer.
- **Build Tooling:** Recognize the need for more sophisticated build tooling in
  the future (dev server, hot reload, optimization). `dhttpd` is sufficient for
  now.
- **WASM Foundation:** Continue leveraging `dart compile wasm` as the core
  compilation strategy.
