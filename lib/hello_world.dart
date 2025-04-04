// lib/hello_world.dart

import 'package:dust_component/stateless_component.dart';

class HelloWorld extends StatelessWidget {
  const HelloWorld();

  @override
  dynamic build() {
    // For now, build returns a description.
    // Later, this should return a representation that the renderer understands
    // (e.g., an Element, a description of a DOM node like {'tag': 'h1', 'text': 'Hello Dust!'}).
    print('Building HelloWorld component...');
    return {'tag': 'h1', 'text': 'Hello Dust!'}; // Placeholder representation
  }
}
