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
- **`<dart-script>` Code Retrieval:**
  - Dart/WASM can successfully call a predefined JavaScript function
    (`window.dartScriptGetCode`).
  - JavaScript function can find a `<dart-script>` tag in the HTML.
  - The `textContent` of the tag is successfully passed from JavaScript to
    Dart/WASM.
  - Dart correctly receives and identifies the code as a string.

## What's Left to Build (High Level)

- **Core Framework (`<dart-script>` implementation):**
  - **Execute retrieved Dart code:** Implement a mechanism within Dart/WASM to
    run the code string obtained from the tag. (Major challenge)
  - Handle multiple `<dart-script>` tags.
  - Implement `src` attribute support for external files.
  - Refine Dart APIs for DOM manipulation, events, etc. (building on PoC
    findings).
  - Error handling and reporting for user Dart code (retrieval and execution).
- **Further Goals:**
  - Basic package management exploration.
  - Performance analysis and optimization (WASM size, interop overhead).

## Current Status

- Proof of Concept (PoC) successfully completed and verified.
- Core technical challenges (WASM compilation, loading, basic async interop)
  overcome.
- **Mechanism for retrieving code from `<dart-script>` tags via Dart-initiated
  JS call is working.**
- Ready to tackle the challenge of executing the retrieved Dart code string.

## Known Issues

- Direct JS interop within Dart `main` function was unreliable for WASM target
  during PoC; async execution was required then.
- Exporting Dart classes/functions via `@JSExport` for direct JS access
  (instantiation/calling _from_ JS) with WASM compilation target proved
  problematic/unsupported; the current working pattern relies on Dart initiating
  interaction via predefined JS functions.
- **Executing arbitrary Dart code strings within the AOT-compiled WASM
  environment is not straightforward.**
