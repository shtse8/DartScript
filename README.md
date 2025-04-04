# DartScript - Proof of Concept

This repository contains the initial Proof of Concept (PoC) for DartScript, a
project aiming to enable writing and executing Dart code directly within HTML,
similar to PyScript.

## Project Goal

Create a framework that allows developers to embed Dart code in HTML using tags
like `<dart-script>` and have it execute in the browser via WebAssembly,
enabling interaction with the DOM.

(See `memory-bank/projectbrief.md` for full details).

## Current Status (PoC)

This PoC demonstrates the core technical feasibility:

- Compiling simple Dart code to WASM (`dart compile wasm`).
- Loading and initializing the WASM module in a browser using a JavaScript
  loader (`js/loader.js`).
- Basic DOM manipulation from Dart, executed asynchronously after module
  initialization (`Timer.run`).

## How to Run the PoC

1. **Ensure Dart SDK is installed.**
2. **Activate `dhttpd`:**
   ```bash
   dart pub global activate dhttpd
   ```
3. **Serve the files:** Navigate to the project root directory in your terminal
   and run:
   ```bash
   dart pub global run dhttpd
   ```
4. **Open in browser:** Open the URL provided by `dhttpd` (usually
   `http://localhost:8080`) in your web browser.

You should see the heading "DartScript Proof of Concept" and the box below
should update with the message "Hello from Dart WASM! 👋 (Timer.run)". Check the
browser's developer console for additional logs.

## Next Steps

- Implement the `<dart-script>` tag handling mechanism.
- Develop more robust Dart APIs for browser interaction.
- Refine error handling.

## Memory Bank

Project context, goals, and progress are documented in the `memory-bank/`
directory according to the Memory Bank workflow.
