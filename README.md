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
- 🔄 **State Management:** Built-in component state (`setState`) with basic
  Riverpod integration via `BuildContext`.
- 🎁 **Props:** Pass data down the component tree using standard Dart
  constructors and a `props` map.
- 🔗 **JS Interop:** Seamlessly interact with JavaScript libraries and browser
  APIs when needed.
- 🎨 **Atomic CSS (Build-Time):** Includes a powerful, build-time Atomic CSS
  generator (`dust_atomic_styles` package) inspired by Tailwind CSS.
  - **Utility-First:** Define styles directly in your Dart component code using
    utility classes (e.g., `m-4`, `p-2`, `text-blue-500`, `flex`,
    `items-center`).
  - **Automatic Generation:** The build system scans your Dart code, identifies
    used atomic classes, and generates only the necessary CSS rules into
    `web/atomic_styles.css`.
  - **Extensive Rule Set:** Covers a wide range of CSS properties (Spacing,
    Layout, Flexbox, Grid, Sizing, Typography, Backgrounds, Borders, Effects,
    Filters, Interactivity, Transforms, Transitions, Animations, SVG,
    Accessibility).
  - **Maintainable & Organized:** Rules are now split into logical files within
    the `packages/atomic_styles/lib/src/rules/` directory.
  - **(Resolved):** Aggregation logic now correctly processes classes from all
    source files using a standard `Builder`.
- **Routing:** Basic client-side routing using the History API (parameter
  parsing and basic nesting supported).
- _Upcoming:_ Advanced State Management, Build Tools, Hot Reload, and more!

## Framework Comparison

This table provides a high-level comparison between Dust and other popular
web/UI frameworks.

| Feature          | Flutter                     | Vue                         | React                         | Angular                         | Dust (Current)                           |
| :--------------- | :-------------------------- | :-------------------------- | :---------------------------- | :------------------------------ | :--------------------------------------- |
| **Language**     | Dart                        | JS/TS                       | JS/TS                         | TS                              | Dart                                     |
| **Paradigm**     | Component-based             | Component-based (MVVM-like) | Component-based               | Component-based (Opinionated)   | Component-based                          |
| **Rendering**    | Skia Canvas / HTML Renderer | Virtual DOM                 | Virtual DOM                   | Incremental DOM (?)             | Virtual DOM (Keyed Diffing)              |
| **Build Target** | Mobile, Web, Desktop        | Web                         | Web (Native via RN)           | Web                             | Web (WASM)                               |
| **State Mgmt**   | Built-in + Libraries        | Built-in (Pinia) + Libs     | Libraries (Context API)       | Built-in (Services/RxJS) + Libs | Built-in (`setState`) + Riverpod (Basic) |
| **Routing**      | Built-in                    | Built-in                    | Libraries (React Router)      | Built-in                        | Basic History API (Built-in)             |
| **Styling**      | Widget Styling              | Scoped CSS, Modules, Util   | CSS, CSS-in-JS, Modules, Util | Scoped CSS, Modules             | CSS + Atomic CSS (Build)                 |
| **JS Interop**   | Good (Web)                  | Excellent                   | Excellent                     | Excellent                       | Good (`dart:js_interop`)                 |
| **Tooling**      | Excellent (Hot Reload)      | Excellent (Hot Reload)      | Excellent (Hot Reload)        | Excellent (Hot Reload)          | Basic (`build_runner`, Hot Restart)      |
| **Ecosystem**    | Mature                      | Mature                      | Very Mature                   | Mature                          | Nascent                                  |

### Current Gaps (Compared to Mature Frameworks)

While Dust is progressing rapidly, it currently lacks several features common in
mature frameworks:

- **Advanced Routing:** Route guards, lazy loading, complex nested layouts,
  advanced programmatic navigation APIs.
- **Mature State Management:** Deeper framework integration, dedicated DevTools
  support.
- **Forms Handling:** Robust libraries/utilities for validation, complex data
  binding, and submission management.
- **Animation System:** Dedicated tools or libraries for creating complex UI
  animations and transitions.
- **Server-Side Rendering (SSR) / Static Site Generation (SSG):** Capabilities
  for improved initial load performance and SEO.
- **Testing Utilities:** Comprehensive framework-specific libraries for unit,
  integration, and end-to-end testing.
- **Internationalization (i18n):** Standardized libraries or patterns for
  supporting multiple languages.
- **Accessibility (a11y):** Built-in helpers, components, or strong patterns to
  ensure accessible applications.
- **True Hot Reload:** Currently offers Hot Restart via `build_runner`.
- **Dedicated DevTools:** Browser extensions for inspecting the component tree,
  state, and performance profiling specific to the framework.
- **Ecosystem & Community:** Extensive third-party libraries, established best
  practices, tutorials, and a large community for support.
- **Comprehensive Documentation:** Needs significant expansion covering all
  features, APIs, and best practices with more examples.

## Getting Started

<!-- Optional: Add a GIF or screenshot of the demo app here -->
<!-- e.g., ![Dust Todo List Demo](path/to/demo.gif) -->

Try the current Props Tester demo (demonstrates props and conditional event
listeners):

1. **Ensure Dart SDK is installed.**
2. **Get dependencies:**
   ```bash
   dart pub get
   ```
3. **Run the development server:** Navigate to the project root directory and
   run:
   ```bash
   dart run build_runner serve web:8081 --live-reload
   ```
   _(This will compile the app, start a server on `localhost:8081`, and enable
   Hot Restart.)_
4. **Open in browser:** Open `http://localhost:8081`.

You should see a button and a "Hello..." message. Clicking the button cycles
through different names, demonstrating props updates. When the name is longer
than 5 characters, hovering over the "Hello..." message will log to the console,
demonstrating conditional event listener addition/removal.

## Basic Example

Here's a simple "Hello World" example demonstrating passing props:

**1. Create your component (`lib/hello_world.dart`):**

```dart
import 'package:dust_component/stateful_component.dart';
import 'package:dust_component/state.dart';
import 'package:dust_component/context.dart';
import 'package:dust_component/vnode.dart';
import 'package:dust_component/html.dart' as html;
import 'package:dust_renderer/dom_event.dart';
import 'package:dust_component/key.dart';

class HelloWorld extends StatefulWidget {
  // Constructor accepts key and props
  const HelloWorld({super.key, super.props});

  @override
  State<HelloWorld> createState() => _HelloWorldState();
}

class _HelloWorldState extends State<HelloWorld> {
  // Helper to get the name prop safely
  String get _displayName => widget.props['name'] as String? ?? 'World';

  @override
  VNode build() {
    final currentDisplayName = _displayName;
    print('Building HelloWorld component (name: $currentDisplayName)...');

    return html.h1(
      key: widget.key,
      text: 'Hello $currentDisplayName!',
      attributes: {'class': 'hello-world-heading'},
    );
  }
}
```

**2. Create the entry point (`web/main.dart`):**

```dart
import 'package:dust_app/hello_world.dart'; // Import the component
import 'package:dust_renderer/renderer.dart';

void main() {
  // Create the component instance, passing name via props map
  final app = HelloWorld(props: {'name': 'Developer'});

  // Mount the component
  runApp(app, 'app');
}
```

**3. Ensure your `web/index.html` has a target element:**

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Dust App</title>
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="atomic_styles.css">
    <!-- Link generated CSS -->
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
dart run build_runner serve web:8081
```

Then open `http://localhost:8081` in your browser.

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
- [x] Props Handling (Basic Map-based)
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

**Styling:**

- [x] Basic Atomic CSS Generation (Build-Time via `dust_atomic_styles` package)

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
