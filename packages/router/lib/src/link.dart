import 'package:dust_component/component.dart'; // Correct import path
import 'package:dust_component/html.dart' as html; // For html helpers like a()
import 'package:dust_renderer/dom_event.dart'; // Correct import for DomEvent
import 'dart:js_interop'; // Import for JS interop
// import 'dart:html' as browser_html; // Avoid dart:html
import 'web_interop.dart'; // Import shared interop definitions

// Props for the Link component
class LinkProps implements Props {
  final String to; // The target path (e.g., '/home', '/users/1')
  final VNode child; // The content of the link, now expecting a VNode

  LinkProps({required this.to, required this.child});
}

class Link extends StatelessWidget {
  @override
  final LinkProps props;

  Link({required this.props, Key? key}) : super(key: key, props: props);

  void _handleClick(DomEvent event) {
    event.preventDefault(); // Prevent default anchor tag navigation
    // Update the URL hash to trigger the Router
    // Use JS interop to set the hash
    location.hash = props.to; // Use imported 'location' from web_interop
  }

  @override
  @override // Add override annotation
  VNode? build(BuildContext context) {
    // Return VNode?
    // Render an anchor tag
    return html.a(
      attributes: {
        // Use 'attributes' instead of 'props'
        'href': '#${props.to}', // Set href for accessibility/semantics
      },
      listeners: {
        'click': _handleClick,
      },
      children: [
        props.child,
      ],
    );
  }
}
