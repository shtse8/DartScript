import 'package:dust_component/component.dart';
import 'package:dust_router/dust_router.dart'; // Import Link and LinkProps

import 'package:dust_component/html.dart' as html;

// Props for the UserPage component
class UserPageProps implements Props {
  final String userId;
  final VNode? childVNode; // Add field to hold the child route's VNode

  UserPageProps({required this.userId, this.childVNode}); // Update constructor
}

// Simple component to display a user ID
class UserPage extends StatelessWidget<UserPageProps> {
  const UserPage({required UserPageProps props, super.key})
      : super(props: props);

  @override
  VNode? build(BuildContext context) {
    // Render the childVNode if it exists, otherwise render nothing for the child slot
    final childContent = props.childVNode ?? VNode.text('');

    return html.div(
      children: [
        html.h1(children: [html.text('User Page')]),
        html.p(children: [
          html.text('Displaying profile for User ID: ${props.userId}')
        ]),
        // Add a link to the nested profile route
        Link(
            props: LinkProps(
                to: '/users/${props.userId}/profile', // Use full path for clarity
                child: html.text('View Profile Section'))),
        html.hr(), // Add a separator
        // Render the child route's content here
        childContent,
        html.hr(), // Add another separator
        Link(props: LinkProps(to: '/', child: html.text('Go back Home'))),
      ],
    );
  }
}
