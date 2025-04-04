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
  (`window.dartScriptSetText`, `window.dartScriptGetText`,
  `window.dartScriptSetHtml`).
- A Dart static class `DartScriptApi` providing wrappers for the JS functions.
- A sample Dart WASM module (`dart/main.dart`) successfully calling the
  framework API via `DartScriptApi` to update the DOM after being loaded via
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
should update with the final HTML content set by `DartScriptApi.setHtml`. Check
the browser's developer console for additional logs detailing the API calls.

## Next Steps

Based on `memory-bank/activeContext.md`:

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

## Memory Bank

Project context, goals, technical details, and progress are documented in the
`memory-bank/` directory according to the Memory Bank workflow.
