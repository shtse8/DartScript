// lib/prop_tester.dart
import 'package:dust_component/stateful_component.dart';
import 'package:dust_component/state.dart';
import 'package:dust_component/context.dart';
import 'package:dust_component/vnode.dart';
import 'package:dust_component/html.dart' as html;
import 'package:dust_component/key.dart'; // Import Key and ValueKey

import 'package:dust_renderer/dom_event.dart';
import 'hello_world.dart'; // Import the component to test

class PropTester extends StatefulWidget {
  const PropTester({super.key, super.props});

  @override
  State<PropTester> createState() => _PropTesterState();
}

class _PropTesterState extends State<PropTester> {
  final List<String> _names = [
    'Short',
    'LongerName',
    'Tiny',
    'VeryLongNameIndeed'
  ];
  int _currentIndex = 0;

  void _changeName() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _names.length;
      print(
          'PropTester: Changing name index to $_currentIndex (${_names[_currentIndex]})');
    });
  }

  @override
  VNode build() {
    final currentName = _names[_currentIndex];
    print('Building PropTester (current name: $currentName)');

    return html.div(
      children: [
        html.button(
          text: 'Change Name (Current: $currentName)',
          listeners: {'click': (_) => _changeName()},
        ),
        // Pass the current name via props map to HelloWorld, using a FIXED key
        HelloWorld(
          key: ValueKey(
              'hello-world-instance'), // Use a fixed key to test updates
          props: {'name': currentName},
        ),
      ],
    );
  }
}
