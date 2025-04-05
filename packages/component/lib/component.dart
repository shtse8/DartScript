// packages/component/lib/component.dart

/// Base class for all Dust components.
///
/// Components are the building blocks of a Dust application's UI.
/// Each component encapsulates its own logic and rendering.
import 'key.dart'; // Import Key directly for the base class
import 'props.dart'; // Import Props directly for the base class
export 'key.dart';
export 'props.dart'; // Assuming Props interface is defined here
export 'build_context.dart'; // Assuming BuildContext is defined here
export 'vnode.dart';
export 'stateless_component.dart';
export 'stateful_component.dart';
export 'provider_scope.dart';
export 'consumer.dart'; // Export Consumer as well
export 'html.dart'; // Export HTML helpers

// Base Component class definition remains the same
abstract class Component {
  final Key? key;
  final Props? props; // Use the Props marker interface, make it nullable

  const Component({this.key, this.props});
}

// Note: BuildContext, Props, Key etc. are now expected to be defined
// in the exported files (build_context.dart, props.dart, key.dart).
