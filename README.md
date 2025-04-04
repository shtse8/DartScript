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

## Design Philosophy & Technical Choices

This section addresses some common questions regarding Dust's technical
direction, based on the project's goals outlined in the Memory Bank.

### Why Dart + WASM for the Frontend? (vs. Dart for SSR)

Dust aims to be a modern frontend framework for building interactive Single Page
Applications (SPAs), similar in scope to React or Vue. The choice of Dart
compiled to WebAssembly (WASM) for the frontend, instead of using Dart for
Server-Side Rendering (SSR), supports this goal in several ways:

- **Rich Client-Side Interactivity:** WASM allows complex application logic and
  UI updates to run directly in the browser, enabling smooth, app-like
  experiences without constant server roundtrips.
- **Potential Performance:** WASM offers near-native execution speed, which can
  be beneficial for computationally intensive frontend tasks.
- **Unified Language & Tooling:** Enables full-stack Dart development, allowing
  code sharing (models, validation logic) and a consistent developer experience
  across frontend and backend.
- **Leveraging Dart's Strengths:** WASM allows running a Dart runtime that fully
  supports the language's features (like true integers and strong typing)
  directly in the browser.

While SSR excels at fast initial loads and SEO, Dust prioritizes the rich
interactivity and potential performance benefits of a client-side WASM approach
for building complex web applications.

### Why WASM? (vs. Dart compile js / Dart2JS)

Dart can be compiled to either JavaScript (Dart2JS) or WASM. Dust specifically
targets WASM based on these considerations:

- **Runtime Performance:** WASM generally offers better and more predictable
  runtime performance for intensive tasks compared to JavaScript.
- **Full Dart Language Experience:** WASM allows running a more complete Dart
  runtime, providing better fidelity with Dart's features compared to compiling
  to JavaScript (which has limitations, e.g., only one number type).
- **Future-Oriented:** WASM is a key part of the modern web platform's
  evolution.

However, there are trade-offs:

- **Dart2JS:** Mature, excellent tree-shaking (potentially smaller bundles),
  potentially faster initial load for smaller apps, potentially simpler JS
  interop.
- **WASM:** Potentially larger initial bundle (includes Dart runtime),
  potentially slower startup (WASM compilation/instantiation), JS interop has
  overhead.

Dust's choice of WASM reflects a focus on maximizing runtime performance and
leveraging the full capabilities of the Dart language in the browser, accepting
the trade-off of potentially larger initial bundles.

### How is Dust Different from Flutter Web?

Both use Dart, but they differ significantly in their rendering approach and
relationship with the web platform:

- **Flutter Web:** Primarily uses its own rendering engine (Skia via
  CanvasKit/WASM) to paint pixels directly onto an HTML canvas, largely
  bypassing the standard DOM. It aims for pixel-perfect UI consistency across
  all platforms. An alternative HTML renderer exists but mainly simulates
  Flutter's layout.
- **Dust (Goal):** Aims to be a **native web framework** that works _with_ the
  standard HTML DOM. It intends to translate Dart components into standard HTML
  elements (`div`, `span`, etc.) and manipulate them directly, similar to
  React/Vue. This allows for potentially better integration with existing CSS,
  JS libraries, and standard web platform features.

In essence, Flutter Web brings the Flutter rendering model _to_ the web, while
Dust aims to provide a Dart-based way to build _native_ web experiences using
the DOM.

---

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
