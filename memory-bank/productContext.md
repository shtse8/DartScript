# DartScript Product Context

## Problem Solved

- The current process for running Dart code in the browser often requires
  complex build steps (compiling to JavaScript) or is limited to frameworks like
  Flutter Web.
- There isn't a straightforward way to embed and execute raw Dart code directly
  within an HTML page for simple scripting, prototyping, or educational
  purposes, similar to how PyScript works for Python.

## How It Should Work

- Developers should be able to include a `<dart-script>` tag in their HTML.
- The Dart code within this tag (or linked via a `src` attribute) should execute
  within the browser context.
- The Dart code should have access to the browser's DOM to manipulate web page
  elements.
- Basic Dart libraries and potentially a simple package system should be
  available.

## User Experience Goals

- **Simplicity:** Easy integration using familiar HTML tags.
- **Accessibility:** No complex installation or build process required for basic
  use cases.
- **Interactivity:** Enable dynamic web experiences powered by Dart.
- **Learning Tool:** Provide an accessible platform for learning Dart in a web
  context.
- **Prototyping:** Allow rapid development and testing of web ideas using Dart,
  especially for Flutter developers exploring web capabilities.
