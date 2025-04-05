import 'package:dust_component/component.dart';
import 'package:dust_router/dust_router.dart'; // Import Link and LinkProps

import 'package:dust_component/html.dart' as html;

// Props for the UserPage component
class UserPageProps implements Props {
  final String userId;

  UserPageProps({required this.userId});
}

// Simple component to display a user ID
class UserPage extends StatelessWidget<UserPageProps> {
  const UserPage({required UserPageProps props, super.key})
      : super(props: props);

  @override
  VNode? build(BuildContext context) {
    return html.div(
      children: [
        html.h1(children: [html.text('User Page')]),
        html.p(children: [
          html.text('Displaying profile for User ID: ${props.userId}')
        ]),
        Link(props: LinkProps(to: '/', child: html.text('Go back Home'))),
      ],
    );
  }
}
