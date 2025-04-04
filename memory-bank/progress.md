# DartScript Progress

## What Works

- Initial Memory Bank documentation structure created and populated
  (`activeContext.md` updated).
- **Proof of Concept (PoC) Completed:**
  - Basic Dart-to-WASM compilation setup (`dart compile wasm`).
  - Minimal HTML loader (`index.html`, `js/loader.js`, `wasm/main.mjs`).
  - Basic JS/WASM communication established (JS loads WASM, invokes `main`).
  - Simple DOM interaction achieved from Dart using `Timer.run` for async
    execution during PoC.
- **(Previous) `<dart-script>` Code Retrieval:** Mechanism removed.
- **`<dart-script src="...">` Loader Implemented:**
  - `js/loader.js` updated to find all `<dart-script src="...">` tags.
  - Loader dynamically imports the specified JS module (`src` attribute).
  - Loader fetches the corresponding WASM file (based on convention).
  - Loader uses the imported JS module's `compileStreaming` to load, compile,
    instantiate, and invoke `main()` for each specified WASM module.
  - Basic error handling for loading/instantiation added.
- **Initial DartScript DOM API Implemented:**
  - JS functions (`dartScriptSetText`, `dartScriptGetText`, `dartScriptSetHtml`)
    added to `js/loader.js`.
  - Dart wrapper functions (`setText`, `getText`, `setHtml`) created in
    `dart/main.dart` within a static class `DartScriptApi` to resolve
    compilation issues.
  - Dart code successfully calls these APIs to interact with the DOM.

## What's Left to Build (High Level)

- **Core Framework (`<dart-script src="...">` implementation):**
  - **Refine/Expand DartScript APIs:** Improve existing APIs (e.g., error
    handling) and add more functionality (event handling, element
    creation/removal).
  - **Configuration Passing:** Design and implement mechanism to pass
    configuration from tag attributes to the loaded WASM module.
  - **Refine Error Handling:** Improve error reporting from within the loaded
    Dart WASM modules back to the main page/console.
- **Further Goals:**
  - Basic package management exploration.
  - Performance analysis and optimization (WASM size, interop overhead).

## Current Status

- Proof of Concept (PoC) successfully completed and verified.
- Core technical challenges (WASM compilation, loading, basic async interop)
  overcome.
- **Decision made to abandon inline code execution.** Project scope adjusted to
  focus solely on loading pre-compiled WASM via `<dart-script src="...">`.
- **JavaScript loader (`js/loader.js`) successfully refactored** to handle
  multiple `<dart-script src="...">` tags.
- **Initial DartScript DOM API (`setText`, `getText`, `setHtml`) successfully
  implemented** and tested.
- Ready to refine error handling, explore configuration passing, and potentially
  expand the API set.

## Known Issues

- Direct JS interop within Dart `main` function was unreliable for WASM target
  during PoC; async execution was required then.
- Exporting Dart classes/functions via `@JSExport` for direct JS access with
  WASM compilation target proved problematic/unsupported; the current working
  pattern relies on Dart initiating interaction via predefined JS functions.
- **Executing arbitrary Dart code strings within the AOT-compiled WASM
  environment is confirmed to be non-trivial.**
