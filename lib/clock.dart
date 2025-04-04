// lib/clock.dart
import 'dart:async';
import 'package:riverpod/riverpod.dart';
import 'package:dust_component/stateful_component.dart'; // Use StatefulWidget
import 'package:dust_component/state.dart'; // Use State
import 'package:dust_component/vnode.dart'; // Import VNode

// 1. Define the time provider using StreamProvider
final clockProvider = StreamProvider<DateTime>((ref) {
  // Create a stream that emits the current time every second
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

// 2. Create the Clock Component using Dust's StatefulWidget
class ClockComponent extends StatefulWidget {
  const ClockComponent(); // Add const constructor

  @override
  State<ClockComponent> createState() => _ClockComponentState();
}

class _ClockComponentState extends State<ClockComponent> {
  // Riverpod container and subscription management
  late final ProviderContainer _container;
  StreamSubscription? _subscription;
  DateTime? _currentTime;
  Object? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState(); // Call super.initState()
    // Create a container specific to this component instance.
    // Ideally, this container would be provided by the framework (ProviderScope).
    _container = ProviderContainer();
    _subscribeToClock();
  }

  void _subscribeToClock() {
    _subscription?.cancel(); // Cancel previous subscription if any

    // Listen to the stream provided by Riverpod
    _subscription = _container.read(clockProvider.stream).listen((time) {
      // Use Dust's setState to trigger a rebuild
      setState(() {
        _currentTime = time;
        _isLoading = false;
        _error = null;
      });
    }, onError: (err, stack) {
      setState(() {
        _error = err;
        _isLoading = false;
      });
    }, onDone: () {
      setState(() {
        _isLoading = false; // Stream finished (unexpected for clock)
      });
    });

    // Handle initial state synchronously if available
    final initialValue = _container.read(clockProvider);
    if (initialValue is AsyncData<DateTime>) {
      // No need for setState here as initState hasn't finished
      _currentTime = initialValue.value;
      _isLoading = false;
    } else if (initialValue is AsyncError) {
      _error = initialValue.error;
      _isLoading = false;
    } else {
      _isLoading = true; // Still loading initially
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _container.dispose(); // Dispose the container when the widget is removed
    super.dispose(); // Call super.dispose()
  }

  // build method returns the Map representation the basic renderer understands
  @override
  // build method now returns a VNode
  @override
  VNode build() {
    String displayText;
    if (_isLoading) {
      displayText = 'Loading clock...';
    } else if (_error != null) {
      displayText = 'Error loading clock: $_error';
    } else if (_currentTime != null) {
      // Format the time (example: HH:MM:SS)
      final formattedTime = "${_currentTime!.hour.toString().padLeft(2, '0')}:"
          "${_currentTime!.minute.toString().padLeft(2, '0')}:"
          "${_currentTime!.second.toString().padLeft(2, '0')}";
      displayText = 'Current time: $formattedTime';
    } else {
      displayText = 'Waiting for time...';
    }

    // Return the Map representation for the basic renderer
    // Return a VNode representation
    // Return a VNode representation: an element node containing a text node.
    return VNode.element(
      'span', // Render as a <span> element
      children: [VNode.text(displayText)], // Text content as a child VNode
    );
  }
}
