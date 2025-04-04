# DartScript - Proof of Concept

This repository contains the initial Proof of Concept (PoC) and ongoing
development for DartScript, a project aiming to enable writing and executing
Dart code directly within HTML, similar to PyScript.

## Project Goal

Create a framework that allows developers to embed Dart code in HTML using tags
like `<dart-script>` and have it execute in the browser via WebAssembly,
enabling interaction with the DOM.

(See `memory-bank/projectbrief.md` for full details).

## Current Status

The project has moved beyond the initial PoC and now demonstrates:

- Compiling simple Dart code to WASM (`dart compile wasm`).
- Loading and initializing the WASM module in a browser using a JavaScript
  loader (`js/loader.js`).
- **Retrieving Dart code from `<dart-script>` tags:**
  - Dart's `main` function calls a JavaScript function
    (`window.dartScriptGetCode`).
  - The JavaScript function finds the first `<dart-script>` tag in `index.html`.
  - The tag's `textContent` is successfully passed back to Dart/WASM.
  - Dart displays the retrieved code in the output div.

## How to Run

1. **Ensure Dart SDK is installed.**
2. **Compile Dart to WASM:**
   ```bash
   dart compile wasm dart/main.dart -o wasm/main.wasm
   ```
3. **Activate `dhttpd` (if not already done):**
   ```bash
   dart pub global activate dhttpd
   ```
4. **Serve the files:** Navigate to the project root directory in your terminal
   and run:
   ```bash
   dhttpd .
   ```
   (Note: `dart pub global run dhttpd` also works)
5. **Open in browser:** Open the URL provided by `dhttpd` (usually
   `http://localhost:8080`) in your web browser.

You should see the heading "DartScript Proof of Concept" and the box below
should update with the message "Dart received code:" followed by the content of
the `<dart-script>` tag from `index.html`. Check the browser's developer console
for additional logs from both JavaScript and Dart.

## Next Steps

- **Implement execution of retrieved Dart code:** This is the primary next
  challenge.
- Handle multiple `<dart-script>` tags and the `src` attribute.
- Develop more robust Dart APIs for browser interaction.
- Refine error handling.

## Memory Bank

Project context, goals, and progress are documented in the `memory-bank/`
directory according to the Memory Bank workflow.
