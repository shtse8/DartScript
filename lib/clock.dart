// lib/clock.dart
import 'dart:async';
import 'package:riverpod/riverpod.dart';
import 'package:dust_component/component.dart'; // Import base Component and Props
import 'package:dust_component/state.dart'; // Use State

// 1. Define the time provider using StreamProvider
final clockProvider = StreamProvider<DateTime>((ref) {
  // Create a stream that emits the current time every second
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

// 2. Create the Clock Component using Dust's StatefulWidget
class ClockComponent extends StatefulWidget<Props?> {
  // Specify Props type argument
  // Add const constructor and call super with null props
  const ClockComponent({super.key}) : super(props: null);

  @override
  State<ClockComponent> createState() => _ClockComponentState();
}

class _ClockComponentState extends State<ClockComponent> {
  // Riverpod container and subscription management
  late final ProviderContainer _container;
  ProviderSubscription? _subscription; // Changed type
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
    _subscription?.close(); // Close previous subscription if any

    // Listen directly to the provider's AsyncValue state
    _subscription = _container.listen<AsyncValue<DateTime>>(
      clockProvider,
      (previous, next) {
        // Use Dust's setState to trigger a rebuild when AsyncValue changes
        setState(() {
          next.when(
            data: (time) {
              _currentTime = time;
              _isLoading = false;
              _error = null;
            },
            loading: () {
              _isLoading = true;
              _error = null; // Clear previous error on reload
            },
            error: (err, stack) {
              _error = err;
              _isLoading = false;
            },
          );
        });
      },
      fireImmediately: true, // Handle initial state immediately
    );

    // Initial state is handled by fireImmediately: true in listen now.
  }

  @override
  void dispose() {
    _subscription?.close(); // Use close for ProviderSubscription
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
