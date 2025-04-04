# DartScript Active Context

## Current Focus

- Implementing the core `<dart-script>` tag functionality.
- Establishing the mechanism for Dart/WASM to retrieve code from HTML tags.

## Recent Changes

- Created initial project structure (HTML, JS loader, Dart source).
- Iteratively debugged Dart-JS interop issues for WASM compilation.
- Successfully compiled Dart to WASM (`dart compile wasm`).
- Successfully loaded the WASM module using the generated JS helper
  (`main.mjs`).
- Achieved DOM manipulation from Dart by scheduling the interop call
  asynchronously (`Timer.run`) during PoC.
- **Implemented code retrieval from `<dart-script>` tag:**
  - Added `<dart-script>` tag to `index.html`.
  - Modified `js/loader.js` to define `window.dartScriptGetCode`.
  - Modified `dart/main.dart` to call `window.dartScriptGetCode` from Dart's
    `main` function.
  - Successfully passed the tag's `textContent` from JS to Dart/WASM.
  - Confirmed Dart receives the code string correctly.
  - Resolved issues with JS interop type checking (`instanceOfString`).

## Next Steps

- **Implement Dart code execution:** Find a way to execute the retrieved Dart
  code string within the WASM environment. This might involve:
  - Investigating Dart interpreter packages compilable to WASM.
  - Exploring dynamic compilation or loading mechanisms (if feasible with WASM).
  - Potentially sending the code to a server for execution (less ideal for
    client-side focus).
- **Handle multiple `<dart-script>` tags:** Extend the JS/Dart logic to find and
  process all tags on the page.
- **Implement `src` attribute:** Allow loading Dart code from external files
  specified in `<dart-script src="...">`.
- **Refine error handling:** Improve reporting for errors during code retrieval
  and (future) execution.
- Update `progress.md` to reflect the successful code retrieval step.

## Active Decisions & Considerations

- **JS Interop Pattern:** Confirmed that Dart initiating calls to predefined JS
  functions (like `window.dartScriptGetCode`) is the reliable pattern for this
  WASM interop scenario. Exporting Dart functions/classes/statics via
  `@JSExport` proved unreliable/unsupported by the `dart compile wasm` toolchain
  for direct JS calls _into_ Dart.
- **Code Execution Strategy:** The method for executing the retrieved Dart code
  string is the next major technical challenge to address. The AOT nature of
  `dart compile wasm` makes direct interpretation non-trivial.
- Using `dhttpd` as the local development server.
