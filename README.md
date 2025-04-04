<!-- Optional: Add your project logo here -->
<!-- e.g., <p align="center"><img src="path/to/your/logo.png" alt="Dust Logo" width="200"></p> -->

# Dust ✨: A Modern Dart Web Framework

<!-- Add relevant badges here -->
<!-- Examples:
[![Build Status](https://github.com/your_username/your_repo/actions/workflows/ci.yml/badge.svg)](https://github.com/your_username/your_repo/actions/workflows/ci.yml)
[![Pub Version](https://img.shields.io/pub/v/your_package_name)](https://pub.dev/packages/your_package_name)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Code Coverage](https://img.shields.io/codecov/c/github/your_username/your_repo)](https://codecov.io/gh/your_username/your_repo)
[![Discord](https://img.shields.io/discord/your_discord_invite_code?logo=discord)](https://discord.gg/your_discord_invite_code)
-->

Dust is a high-performance, component-based web framework for Dart, built with
WebAssembly (WASM). Inspired by React and Vue, Dust aims to provide an
exceptional developer experience for building modern, type-safe web
applications.

**Note:** This project is currently under active development (Work in Progress).

## Why Dust?

- 🚀 **Build Fast Web UIs:** Create interactive user interfaces entirely in
  Dart.
- ⚙️ **WASM Performance:** Leverage WebAssembly for near-native execution speed
  in the browser.
- 🛡️ **Type Safety:** Utilize Dart's strong typing and sound null safety to
  build robust applications.
- 🧩 **Familiar Component Model:** Enjoy a component-based architecture inspired
  by React and Vue.
- 💡 **Developer Experience:** Designed with developer productivity and
  happiness in mind.

## Features

Dust aims to provide a comprehensive feature set for modern web development:

- ✨ **Declarative UI:** Define your UI based on state, and let Dust handle the
  DOM updates efficiently.
- 🧩 **Component-Based:** Build reusable UI pieces using Stateless and Stateful
  components.
- ⚙️ **Efficient Diffing:** Smart Virtual DOM reconciliation ensures minimal DOM
  manipulation.
- 🚀 **WASM Powered:** Runs your Dart code directly in the browser via
  WebAssembly.
- 🛡️ **Type Safe:** Leverage Dart's strong type system throughout the framework.
- 🔄 **State Management:** Built-in component state (`setState`) with plans for
  integrating popular solutions.
- 🔗 **JS Interop:** Seamlessly interact with JavaScript libraries and browser
  APIs when needed.
- _Upcoming:_ Routing, Advanced State Management, Build Tools, Hot Reload, and
  more!

## Getting Started

<!-- Optional: Add a GIF or screenshot of the demo app here -->
<!-- e.g., ![Dust Todo List Demo](path/to/demo.gif) -->

Try the current Todo List demo:

1. **Ensure Dart SDK is installed.**
2. **Get dependencies:**
   ```bash
   dart pub get
   ```
3. **Run the development server:** Navigate to the project root directory and
   run:
   ```bash
   dart run build_runner serve web --live-reload
   ```
   _(This will compile the app, start a server (usually on `localhost:8080`),
   and enable Hot Restart. Use a different port if needed, e.g., `web:8081`)_
4. **Open in browser:** Open the URL provided by `build_runner` (e.g.,
   `http://localhost:8080`).

You should see the interactive Todo List application demonstrating basic state
management, event handling, and keyed list diffing.

## Basic Example

Here's a simple example using Riverpod for state management:

**1. Define a Provider (`lib/providers.dart`):**

```dart
import 'package:riverpod/riverpod.dart';

// Simple provider holding a message string
final messageProvider = Provider<String>((ref) => 'Hello from Riverpod!');
```

**2. Create your component using `Consumer` (`lib/hello_consumer.dart`):**

```dart
import 'package:dust_component/component.dart';
import 'package:dust_component/consumer.dart'; // Import Consumer
import 'package:dust_component/vnode.dart';
import 'package:dust_component/html.dart';
import 'package:riverpod/riverpod.dart'; // Import Riverpod
import 'providers.dart'; // Import your provider

class HelloConsumer extends Consumer { // Extend Consumer
  HelloConsumer() : super(builder: (ref) { // Pass builder to super constructor
    // Watch the provider
    final message = ref.watch(messageProvider);

    // Build UI using the message
    return div(children: [
      h1(
        text: message, // Use the message from the provider
        attributes: {'style': 'color: green;'},
      ),
      // You can add buttons here to interact with other providers (e.g., StateProvider)
    ]);
  });
}
```

**3. Create the entry point (`web/main.dart`):**

```dart
import 'package:dust_app/hello_consumer.dart'; // Import the new consumer component
import 'package:dust_renderer/renderer.dart';

void main() {
  // Mount the consumer component
  runApp(HelloConsumer(), 'app');
}
```

**3. Ensure your `web/index.html` has a target element:**

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Dust App</title>
  </head>
  <body>
    <div id="app"></div>
    <!-- Target element -->
    <script type="module" src="main.dart.js"></script>
  </body>
</html>
```

**4. Run the development server:**

```bash
dart run build_runner serve web
```

Then open the provided URL in your browser.

## Roadmap & Status

<details>
<summary>Click to view the detailed development roadmap and current status</summary>

This section outlines the major functional goals and their current
implementation status.

**Core:**

- [x] Dart -> WASM Compilation (`dart compile wasm`)
- [x] WASM Module Loading (`js/app_bootstrap.js`)
- [x] Basic JS/WASM Interop (`dart:js_interop`)

**Component Model:**

- [x] Base Component Classes (`Component`, `StatefulWidget`, `StatelessWidget`,
      `State`)
- [x] Virtual DOM Node (`VNode` Definition)
  - [x] Element Nodes (tag, attributes, children)
  - [x] Text Nodes
  - [x] Keys for Diffing (`key` property)
  - [x] Event Listeners (`listeners` property using `DomEvent`)
  - [x] Internal Listener Reference Storage (`jsFunctionRefs`)
- [ ] Props Handling
- [x] Basic Context API (`BuildContext` carrying `ProviderContainer`)

**Renderer:**

- [x] Initial Rendering (`runApp` function calling internal `render`,
      `_createDomElement`)
- [x] Basic DOM Manipulation via JS Interop (`JSAnyExtension`)
- [x] Patching / Diffing (`_patch` function)
  - [x] Node Addition/Removal/Replacement
  - [x] Text Content Update
  - [x] Attribute Update/Removal
  - [x] Event Listener Update/Removal (Improved logic, wraps callbacks for
        `DomEvent`, **recursive cleanup on node removal**)
- [x] Keyed Child Reconciliation (`_patchChildren` function)
- [ ] Component Lifecycle Method Integration (`initState`, `dispose`, etc.)
- [ ] DOM Abstraction Layer (Type-safe Dart API over DOM)
- [ ] Performance Optimizations

**State Management:**

- [x] Basic Component State (`State`, `setState`)
- [x] Basic Riverpod Integration (`ProviderContainer` via `BuildContext`,
      `Consumer` widget)
- [ ] Improved Framework-Level Integration (e.g., `ProviderScope`, Flutter-like
      `ConsumerWidget`)

**Routing:**

- [ ] SPA Router Implementation

**Tooling:**

- [ ] Build System Optimizations
- [x] Hot Restart (via `build_runner serve`)
- [ ] Hot Reload

**Demo Application (`TodoListComponent`):**

- [x] Demonstrates `StatefulWidget` usage
- [x] Demonstrates Keyed Diffing for lists
- [x] Demonstrates Event Handling (button clicks using `DomEvent`)

</details>

## Design Philosophy & Technical Choices

<details>
<summary>Click to learn more about Dust's technical direction</summary>

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

</details>

## Contributing

Contributions are welcome! If you'd like to help improve Dust, please check out
the [Contribution Guidelines](CONTRIBUTING.md) (You'll need to create this file)
and the open issues.

## Community

<!-- Add links to your community channels -->
<!-- e.g., Join the discussion on [Discord](https://discord.gg/your_invite_code) or [GitHub Discussions](https://github.com/your_username/your_repo/discussions). -->

We are just getting started! Stay tuned for community channels.

## License

Dust is released under the [MIT License](LICENSE). (Ensure you have a LICENSE
file).

---

_Project context, goals, technical details, and progress are documented in the
`memory-bank/` directory._
