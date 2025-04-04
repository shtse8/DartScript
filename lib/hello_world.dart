// lib/hello_world.dart

import 'package:dust_component/stateful_component.dart'; // Change to StatefulWidget
import 'package:dust_component/state.dart'; // Import State
import 'package:dust_component/context.dart'; // Import BuildContext
import 'package:dust_component/vnode.dart'; // Import VNode
import 'package:dust_component/html.dart' as html; // Import HTML helpers
import 'package:dust_renderer/dom_event.dart'; // Import DomEvent

class HelloWorld extends StatefulWidget {
  // Constructor now just passes key and props to the base class.
  // Specific props like 'name' will be accessed via widget.props in the State class.
  const HelloWorld({super.key, super.props});

  @override
  State<HelloWorld> createState() => _HelloWorldState();
}

class _HelloWorldState extends State<HelloWorld> {
  bool _hasMouseOverListener = false;

  // Helper to get the name prop safely
  String get _displayName => widget.props['name'] as String? ?? 'World';

  // Helper to determine if the listener should be active
  bool get _shouldHaveListener => _displayName.length > 5;

  @override
  void initState() {
    super.initState();
    _updateListenerState(); // Set initial state based on initial props
    print(
        'HelloWorld initState: Listener should be $_hasMouseOverListener (name: "$_displayName")');
  }

  @override
  void didUpdateWidget(HelloWorld oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the listener state needs to change based on props update
    final shouldHaveListenerNow = _shouldHaveListener;
    if (shouldHaveListenerNow != _hasMouseOverListener) {
      print(
          'HelloWorld didUpdateWidget: Listener state changing from $_hasMouseOverListener to $shouldHaveListenerNow (name: "$_displayName")');
      // Update the internal state. Build will be called automatically after this.
      _updateListenerState();
    } else {
      print(
          'HelloWorld didUpdateWidget: Listener state remains $_hasMouseOverListener (name: "$_displayName")');
    }
  }

  // Updates the internal boolean flag based on current props
  void _updateListenerState() {
    _hasMouseOverListener = _shouldHaveListener;
  }

  // The actual event handler
  void _handleMouseOver(DomEvent event) {
    print('Mouse over HelloWorld! Name: $_displayName');
    // You could potentially setState here if mouseover should change internal state
  }

  @override
  VNode build() {
    // Access name via the helper getter
    final currentDisplayName = _displayName;
    print(
        'Building HelloWorld component (name: $currentDisplayName, listener: $_hasMouseOverListener)...');

    // Conditionally create the listeners map
    Map<String, void Function(DomEvent)>? listeners;
    if (_hasMouseOverListener) {
      listeners = {'mouseover': _handleMouseOver};
      print(' -> Attaching mouseover listener.');
    } else {
      print(' -> NOT attaching mouseover listener.');
    }

    // Return VNode, using the potentially null listeners map
    return html.h1(
      key: widget.key, // Pass the key down if needed
      text: 'Hello $currentDisplayName!',
      listeners: listeners,
      // Pass class attribute via attributes map
      attributes: {'class': 'hello-world-heading'},
    );
  }
}
