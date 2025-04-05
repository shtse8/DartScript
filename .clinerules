# Dust Project - Cline Rules & Learnings

## JS Interop

- **Callback Conversion:** To pass a Dart function to a JavaScript API expecting
  a function (e.g., `addEventListener`), use the `.toJS` extension method from
  `dart:js_interop` on the Dart function. Do **not** use the older
  `allowInterop` function, as it may cause issues or is deprecated for this use
  case, especially when targeting WASM.
  ```dart
  // Correct: Using .toJS
  import 'dart:js_interop';
  JSFunction jsCallback = ((JSAny event) => dartHandler(event)).toJS;
  jsObject.addEventListener('click', jsCallback);

  // Incorrect/Deprecated: Using allowInterop
  // JSFunction jsCallback = allowInterop((JSAny event) => dartHandler(event));
  // jsObject.addEventListener('click', jsCallback);
  ```
- **Shared Interop Bindings:** For common JS objects accessed across multiple
  Dart files (e.g., `window`, `location`), define the `@JS` bindings and
  extensions in a dedicated shared file (e.g., `web_interop.dart`) and import
  that file where needed. This avoids duplicate definitions and potential name
  conflicts during export.

## Component Model

- **Typed Props:** Use generic `StatelessWidget<P extends Props?>` and
  `StatefulWidget<P extends Props?>` with a specific class `P` implementing the
  `Props` marker interface for type-safe properties. Access props within the
  `State` class via `widget.props`. Pass props to components using the defined
  `Props` class instance (e.g., `MyComponent(props: MyProps(value: x))`).
- **HTML Helpers:** Use functions defined in `packages/component/lib/html.dart`
  (e.g., `html.div`, `html.span`, `html.text`) for creating `VNode`s in `build`
  methods. Pass components or strings directly to the `children` list; the
  helper functions handle wrapping them in appropriate `VNode`s.

## Build System

- **WASM Target:** Always compile with `dart compile wasm` (usually handled by
  `build_runner` with `build_web_compilers`).
- **`dart:html`:** Avoid direct use of `dart:html` when targeting WASM, as it's
  deprecated and can cause compilation warnings or failures. Use
  `dart:js_interop` and potentially `package:web` for browser API access.
- **Dependency Resolution:** Run `dart pub get` in the package directory _and_
  the root project directory after modifying `pubspec.yaml` files, especially
  when dealing with local path dependencies.
- **Build Cache:** If encountering persistent or strange build errors after code
  changes, try running `dart run build_runner clean` before rebuilding.

## Memory Bank

- **Mandatory Updates:** Update `activeContext.md` and `progress.md`
  **immediately** after every significant action or change to maintain accurate
  project state awareness.
