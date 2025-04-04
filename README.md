# DartScript - WASM Framework PoC

This repository contains the ongoing development for DartScript, a project
aiming to simplify running pre-compiled Dart WebAssembly (WASM) modules in the
browser and provide a streamlined API for DOM interaction.

**Note:** The project initially aimed to support inline Dart code execution
similar to PyScript, but due to technical challenges with AOT WASM
interpretation, the scope has been adjusted to focus solely on loading
pre-compiled WASM modules via a `src` attribute.

## Project Goal

Create a framework that allows developers to easily load and run pre-compiled
Dart WASM modules in HTML using a simple `<dart-script src="..."></dart-script>`
tag. The framework will provide a standardized Dart API for interacting with the
browser's DOM, simplifying common web development tasks within Dart WASM
modules.

(See `memory-bank/projectbrief.md` and `memory-bank/activeContext.md` for full
details and the latest context).

## Current Status

The project currently demonstrates:

- Compiling simple Dart code to WASM (`dart compile wasm`).
- A JavaScript loader (`js/loader.js`) that:
  - Finds all `<dart-script src="..."></dart-script>` tags in the HTML.
  - Dynamically imports the specified JS loader (`.mjs` file) for each tag.
  - Fetches the corresponding `.wasm` file.
  - Loads, compiles, instantiates, and invokes the `main()` function of each
    WASM module.
- A basic DartScript framework API exposed via JavaScript
  (`window.dartScriptSetText`).
- A sample Dart WASM module (`dart/main.dart`) successfully calling the
  framework API (`dartScriptSetText`) to update the DOM after being loaded via
  `<dart-script src="/wasm/main.mjs">`.

## How to Run

1. **Ensure Dart SDK is installed.**
2. **Compile the sample Dart module to WASM:**
   ```bash
   dart compile wasm dart/main.dart -o wasm/main.wasm
   ```
   (This generates `wasm/main.wasm` and `wasm/main.mjs`)
3. **Activate `dhttpd` (if not already done):**
   ```bash
   dart pub global activate dhttpd
   ```
4. **Serve the files:** Navigate to the project root directory in your terminal
   and run:
   ```bash
   dhttpd .
   ```
5. **Open in browser:** Open the URL provided by `dhttpd` (usually
   `http://localhost:8080`) in your web browser.

You should see the heading "DartScript Proof of Concept" and the box below
should update with the message "Hello from Dart WASM (via dartScriptSetText)!".
Check the browser's developer console for additional logs.

## Next Steps

Based on `memory-bank/activeContext.md`:

- **Implement DartScript APIs:** Define and implement more Dart-side APIs for
  DOM manipulation (e.g., getting elements, adding listeners), event handling,
  etc.
- **Configuration Passing:** Design a mechanism to pass configuration from tag
  attributes to the loaded WASM module.
- **Refine Error Handling:** Improve error reporting from within loaded Dart
  WASM modules.

## Memory Bank

Project context, goals, technical details, and progress are documented in the
`memory-bank/` directory according to the Memory Bank workflow.
