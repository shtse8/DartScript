# DartScript Active Context

## Current Focus

- **Refining Core Framework:** Focusing on improving error handling, potentially
  adding more DOM APIs, and exploring configuration passing for
  `<dart-script src="...">`.
- **Documentation:** Ensuring Memory Bank files accurately reflect the current
  state and decisions.

## Recent Changes

- Created initial project structure (HTML, JS loader, Dart source).
- Iteratively debugged Dart-JS interop issues for WASM compilation.
- Successfully compiled Dart to WASM (`dart compile wasm`).
- Successfully loaded the WASM module using the generated JS helper
  (`main.mjs`).
- Achieved DOM manipulation from Dart by scheduling the interop call
  asynchronously (`Timer.run`) during PoC.
- **(Previous) Implemented code retrieval from `<dart-script>` tag:** (Removed
  due to scope change).
- **Implemented `<dart-script src="...">` loading:**
  - `js/loader.js` updated to find all `<dart-script src="...">` tags.
  - Loader dynamically imports the specified JS module (`src` attribute).
  - Loader fetches the corresponding WASM file (based on convention).
  - Loader uses the imported JS module's `compileStreaming` to load, compile,
    instantiate, and invoke `main()` for each specified WASM module.
  - Basic error handling for loading/instantiation added.
- **Defined and Implemented Initial DartScript DOM API:**
  - Added JS functions (`window.dartScriptSetText`, `window.dartScriptGetText`,
    `window.dartScriptSetHtml`) to `js/loader.js`.
  - Updated JS interop definitions in `dart/main.dart`.
  - Created Dart wrapper functions (`setText`, `getText`, `setHtml`) within a
    static class `DartScriptApi` in `dart/main.dart` to resolve compilation
    visibility issues.
  - Updated `dart/main.dart`'s `main` function to demonstrate usage of the new
    `DartScriptApi` methods.
  - Successfully recompiled `dart/main.dart` to `wasm/main.wasm`.

## Next Steps

- **Refine error handling:** Implement better error reporting from within the
  loaded Dart WASM modules back to the main page/console.
- **Configuration Passing:** Design and implement a mechanism to pass
  configuration data (e.g., from tag attributes like
  `<dart-script src="..." data-config="value">`) to the loaded WASM module's
  `main` function.
- **Expand DOM API:** Consider adding more essential DOM manipulation functions
  (e.g., adding/removing elements, handling events).
- **Package Management Exploration:** Begin research and planning for how
  external Dart packages could be integrated or used.
- **Update `progress.md`:** Reflect the successful implementation of the initial
  DOM API.

## Active Decisions & Considerations

- **JS Interop Pattern:** Confirmed Dart initiating calls to predefined JS
  functions is the reliable pattern. Exporting Dart functions/classes via
  `@JSExport` for direct JS calls _into_ Dart WASM remains problematic.
- **Code Execution Strategy Decision:** Focus remains exclusively on loading
  pre-compiled WASM modules via `<dart-script src="...">`.
- **API Structure:** Using a static class (`DartScriptApi`) for Dart wrapper
  functions resolved compilation issues and provides a clear namespace.
- Using `dhttpd` as the local development server.
