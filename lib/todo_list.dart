import 'package:dust_component/component.dart';
import 'package:dust_component/state.dart';
import 'dart:math'; // For random keys initially
import 'dart:async'; // For Future.delayed
import 'package:dust_renderer/dom_event.dart'; // Import DomEvent

// Simple Todo Item model
class TodoItem {
  final int id;
  String text;
  bool completed;

  TodoItem({required this.id, required this.text, this.completed = false});
}

// TodoListComponent State
class _TodoListState extends State<TodoListComponent> {
  List<TodoItem> _items = [];
  int _nextId = 0;
  final Random _random = Random(); // For shuffling
  Timer? _testTimer;

  @override
  void initState() {
    super.initState();
    // Add some initial items
    _addItem('Learn Dust');
    _addItem('Implement Keyed Diffing');
    _addItem('Test Keyed Diffing');

    // Schedule automatic state changes for testing (Now commented out)
    // _scheduleTestUpdates();
  }

  @override
  void dispose() {
    _testTimer?.cancel(); // Cancel timer when component is disposed
    super.dispose();
  }

  void _addItem(String text) {
    setState(() {
      _items.add(TodoItem(id: _nextId++, text: text));
      print("Items after add: ${_items.map((i) => i.id).toList()}");
    });
  }

  void _removeItem(int id) {
    setState(() {
      _items.removeWhere((item) => item.id == id);
      print("Items after remove ($id): ${_items.map((i) => i.id).toList()}");
    });
  }

  void _toggleItem(int id) {
    setState(() {
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        _items[index].completed = !_items[index].completed;
        print("Toggled item $id completion to ${_items[index].completed}");
      }
    });
  }

  void _shuffleItems() {
    setState(() {
      _items.shuffle(_random);
      print("Items after shuffle: ${_items.map((i) => i.id).toList()}");
    });
  }

  @override
  VNode build() {
    print("Building TodoList VNode tree using HTML helpers...");
    // Apply modern minimalist styles using Atomic CSS classes
    return div(attributes: {
      'class':
          'p-6 max-w-lg mx-auto bg-gray-50 rounded-xl shadow-md mt-10 space-y-6'
    }, children: [
      h1(
        text: 'My Todos',
        attributes: {
          'class': 'text-3xl font-bold text-gray-800 text-center mb-6'
        }, // Cleaner title
      ),
      // Input field (Example - still not functional)
      // div(attributes: {'class': 'flex shadow-sm rounded-md'}, children: [
      //   input(attributes: {'class': 'border-gray-300 p-3 flex-grow rounded-l-md focus:ring-indigo-500 focus:border-indigo-500', 'placeholder': 'What needs to be done?'}),
      //   button(attributes: {'class': 'bg-indigo-500 hover:bg-indigo-600 text-white font-semibold p-3 rounded-r-md'}, text: 'Add')
      // ]),
      ul(
        attributes: {
          'class': 'list-none p-0 space-y-2'
        }, // Remove default list styling, add vertical space
        children: _items.map((item) {
          // print("Creating VNode for item ID: ${item.id}, text: ${item.text}");
          return li(
            key: item.id,
            attributes: {
              // Flex layout, padding, subtle border, rounded corners for items
              // NOTE: 'last:border-b-0' requires specific setup or a different approach
              'class':
                  'flex items-center justify-between p-4 bg-white rounded-lg border border-gray-200'
            },
            children: [
              div(attributes: {
                'class': 'flex items-center'
              }, children: [
                // Group checkbox and text
                // Basic Checkbox simulation (non-functional) - Can be replaced with SVG later
                span(attributes: {
                  'class':
                      'cursor-pointer mr-3 w-5 h-5 border-2 rounded ${item.completed ? 'bg-blue-500 border-blue-500' : 'border-gray-300'}'
                }, listeners: {
                  'click': (DomEvent event) => _toggleItem(item.id)
                } // Make checkbox clickable
                    ),
                span(
                  attributes: {
                    // Conditional styling for completed items, slightly larger text
                    'class':
                        'text-lg ${item.completed ? 'line-through text-gray-400' : 'text-gray-900'}'
                  },
                  text: item.text,
                ),
              ]),
              div(// Container for buttons - subtle icons/text buttons
                  attributes: {
                'class': 'flex items-center space-x-3'
              }, children: [
                // Removed Toggle button, click checkbox instead
                button(
                  attributes: {
                    // Subtle remove button styling
                    'class':
                        'text-gray-400 hover:text-red-600 transition cursor-pointer' // Added cursor
                  },
                  listeners: {
                    'click': (DomEvent event) => _removeItem(item.id)
                  },
                  // Replace text with an icon (e.g., trash can) later if possible
                  text: '×', // Use '×' symbol for delete
                ),
              ])
            ],
          );
        }).toList(),
      ),
      // Add/Shuffle buttons container - less prominent
      div(attributes: {
        'class': 'mt-6 flex justify-end space-x-3'
      }, children: [
        // Align to end
        button(
          attributes: {
            'class':
                'text-sm text-indigo-600 hover:text-indigo-800 font-medium cursor-pointer'
          }, // Subtle add button
          listeners: {
            'click': (DomEvent event) => _addItem('New Item Added Manually')
          },
          text: '+ Add Item',
        ),
        button(
          attributes: {
            'class':
                'text-sm text-gray-500 hover:text-gray-700 font-medium cursor-pointer'
          }, // Subtle shuffle button
          listeners: {'click': (DomEvent event) => _shuffleItems()},
          text: 'Shuffle',
        ),
      ])
    ]);
    // NOTE: Buttons don't work yet as event handling is not implemented.
    // Automatic updates are scheduled in initState for testing.
  }
}

// TodoListComponent Widget
class TodoListComponent extends StatefulWidget<Props?> {
  // Specify Props type argument
  // Add const constructor and call super with null props
  const TodoListComponent({super.key}) : super(props: null);
  @override
  State<TodoListComponent> createState() => _TodoListState();
}
