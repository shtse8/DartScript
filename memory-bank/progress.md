# DartScript Progress

## What Works

- Initial Memory Bank documentation structure created and populated
  (`activeContext.md` updated).
- **Proof of Concept (PoC) Completed:**
  - Basic Dart-to-WASM compilation setup (`dart compile wasm`).
  - Minimal HTML loader (`index.html`, `js/loader.js`, `wasm/main.mjs`).
  - Basic JS/WASM communication established (JS loads WASM, invokes `main`).
  - Simple DOM interaction achieved from Dart using `Timer.run` for async
    execution.

## What's Left to Build (High Level)

- **Core Framework (`<dart-script>` implementation):**
  - JavaScript logic to detect and process `<dart-script>` tags.
  - Mechanism to load/pass Dart code from tags/`src` attributes to the WASM
    runtime.
  - Refined Dart APIs for DOM manipulation, events, etc. (building on PoC
    findings).
  - Error handling and reporting for user Dart code.
- **Further Goals:**
  - Basic package management exploration.
  - Performance analysis and optimization (WASM size, interop overhead).

## Current Status

- Proof of Concept (PoC) successfully completed and verified.
- Core technical challenges (WASM compilation, loading, basic async interop)
  overcome.
- Ready to proceed with designing and implementing the `<dart-script>` tag
  functionality.

## Known Issues

- Direct JS interop within Dart `main` function is unreliable for WASM target.
  Async execution (e.g., `Timer.run`) is required.
- Exporting Dart classes/functions via `@JSExport` for direct JS access
  (instantiation/calling) with WASM compilation target is problematic/unclear;
  current working pattern relies on Dart initiating interaction after `main`.
