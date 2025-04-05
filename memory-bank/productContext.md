<!-- Version: 1.0 | Last Updated: 2025-05-04 | Updated By: Cline -->

# Dust Product Context

## Problem Solved

- **Lack of Modern Dart Web Framework:** While Flutter Web exists, there's a gap
  for a dedicated Dart web framework that offers a developer experience and
  component model similar to modern JavaScript frameworks like React or Vue,
  focusing specifically on traditional web application development paradigms.
- **Suboptimal Developer Experience:** Existing methods for using Dart in the
  web (outside of Flutter) can involve complex build setups or lack the
  streamlined tooling (like hot reload, state management integration) expected
  by modern web developers.
- **Desire for Type-Safe Web Development:** Developers want to leverage Dart's
  strong typing and language features to build more robust and maintainable web
  applications compared to traditional JavaScript development.

## How It Should Work

- **Component-Based Architecture:** Developers build UIs by composing reusable,
  stateful, or stateless components defined in Dart.
- **Declarative UI:** Developers declare what the UI should look like based on
  the application state, and the framework efficiently updates the DOM to match
  that state.
- **State Management:** The framework provides clear patterns or integrates
  solutions for managing application state effectively.
- **Routing:** Includes a routing system for building single-page applications
  (SPAs).
- **Build System & Tooling:** Offers a development server with features like hot
  reload (ideally) and an optimized production build process.
- **Seamless Integration:** While the core is Dart, it should allow
  straightforward interoperability with existing JavaScript libraries and
  browser APIs when needed.
- **(Initial Integration):** While the goal is a full framework, the initial
  entry point might still involve a script tag
  (`<script type="application/dart" src="main.dart.js">` or similar) to load the
  compiled application and framework runtime, moving away from the
  `<dart-script>` concept for raw code.

## User Experience Goals (Developer Focused)

- **Exceptional Developer Experience (DX):** Prioritize intuitive APIs, clear
  documentation, helpful error messages, and efficient tooling (build times, hot
  reload).
- **Productivity:** Enable developers to build complex web applications quickly
  and efficiently.
- **Performance:** Facilitate the creation of fast-loading and responsive web
  applications by leveraging Dart's performance and WASM.
- **Maintainability & Scalability:** Promote code organization and patterns that
  lead to maintainable and scalable applications.
- **Learning Curve:** Aim for a familiar feel for developers coming from
  React/Vue, while being accessible to Dart developers new to web frameworks.
