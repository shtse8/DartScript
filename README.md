# Dust - A Modern Dart Web Framework (Work in Progress)

This repository contains the ongoing development for **Dust**, a project aiming
to create a modern, performant, and developer-friendly web framework for Dart,
inspired by frameworks like React and Vue.

**Note:** This project evolved from an earlier concept ("DartScript") focused on
simple WASM loading. The ambition is now significantly broader: to build a
comprehensive framework for constructing web applications with Dart and
WebAssembly.

## Project Goal

Build a next-generation Dart web framework that leverages Dart's strengths (type
safety, performance via WASM) and provides a component-based, declarative UI
paradigm similar to popular JavaScript frameworks. The goal is to offer an
exceptional developer experience for building modern web applications entirely
in Dart.

(See `memory-bank/projectbrief.md` and other Memory Bank files for full details
and the latest context).

## Current Status (Transitioning)

The project is currently transitioning from its initial proof-of-concept phase
("DartScript") towards the new framework ("Dust") goals.

Foundational elements that work:

- Compiling Dart to WASM (`dart compile wasm`).
- Basic WASM module loading via JavaScript.
- Rudimentary JS/WASM communication bridge for DOM manipulation (e.g.,
  `setText`, `setHtml` via JS functions called from Dart).

## How to Run (Previous PoC - Will Change)

_The instructions below relate to the previous "DartScript" PoC and will be
updated as the "Dust" framework takes shape._

1. **Ensure Dart SDK is installed.**
2. **Compile the sample Dart module to WASM:**
   ```bash
   dart compile wasm dart/main.dart -o wasm/main.wasm
   ```
   (Generates `wasm/main.wasm` and `wasm/main.mjs`)
3. **Activate `dhttpd` (if not already done):**
   ```bash
   dart pub global activate dhttpd
   ```
4. **Serve the files:** Navigate to the project root directory and run:
   ```bash
   dhttpd .
   ```
5. **Open in browser:** Open `http://localhost:8080`.

You would see the output of the old PoC.

## Next Steps (Framework Development)

Based on `memory-bank/activeContext.md`:

- **Design Core Framework Architecture:** Define the Component Model, Rendering
  Pipeline, and State Management approach.
- **Implement Component API:** Define how developers will create UI components
  in Dart.
- **Build Basic Renderer:** Create a PoC renderer to translate simple components
  to DOM nodes.
- **Prototype State Management:** Explore basic state management patterns.
- **Structure Framework Core:** Set up the initial directory structure
  (`packages/core`, etc.).
- **Update Documentation:** Keep Memory Bank aligned with design decisions.

## Memory Bank

Project context, goals, technical details, and progress are documented in the
`memory-bank/` directory according to the Memory Bank workflow. This is the
source of truth for the **Dust** framework development.
