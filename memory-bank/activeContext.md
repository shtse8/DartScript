# DartScript Active Context

## Current Focus

- Completing the initial Proof of Concept (PoC).
- Verifying basic Dart-to-WASM compilation and DOM interaction.

## Recent Changes

- Created initial project structure (HTML, JS loader, Dart source).
- Iteratively debugged Dart-JS interop issues for WASM compilation.
- Successfully compiled Dart to WASM (`dart compile wasm`).
- Successfully loaded the WASM module using the generated JS helper
  (`main.mjs`).
- Achieved DOM manipulation from Dart by scheduling the interop call
  asynchronously (`Timer.run`).

## Next Steps

- Update `progress.md` to reflect PoC completion.
- Plan the implementation of the `<dart-script>` tag functionality:
  - JavaScript code to find `<dart-script>` tags.
  - Mechanism to pass Dart code from the tag (or `src` attribute) to the WASM
    runtime.
  - Refining the Dart API for DOM access and other browser features.
  - Error handling for Dart code executed via tags.

## Active Decisions & Considerations

- **JS Interop Timing:** Confirmed that JS interop (especially DOM manipulation)
  should be performed asynchronously after the Dart `main` function completes,
  not directly within it. `Timer.run` is a viable approach for the PoC.
- **Export Mechanism:** Standard `@JSExport` on classes/functions seems
  problematic for direct JS access with WASM. The current working pattern
  involves Dart initiating the interaction after `main`. Future work might
  explore alternative export/communication methods if needed (e.g., passing JS
  functions _into_ Dart).
- Using `dhttpd` as the local development server.
