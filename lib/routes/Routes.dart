import 'package:board_app/pages/chatProject.dart';
import 'package:flutter/material.dart';
import '../pages/Tabs.dart';
import 'package:board_app/pages/Login.dart';
import '../pages/test2.dart';
import '../pages/tabs/MyMessage.dart';

final routes = {
  '/tabs': (context, {aguments}) => Tabs(),
  '/chats': (context, {task_id, user_id, project_id, task_title}) =>
      ChatProjectPage(
        task_id: task_id,
        user_id: user_id,
        task_title: task_title,
        project_id: project_id,
      ),
  '/': (context) => LoginPage(),
  '/test': (context) => Test2Page(),
  '/message': (context, {user_id, username}) => MyMessagePage(
        user_id: user_id,
        username: username,
      )
};

var onGenerateRoute = (RouteSettings settings) {
  final String? name = settings.name;
  final Function pageContentBuilder = routes[name] as Function;
  if (settings.arguments != null) {
    final Route route = MaterialPageRoute(
        builder: (context) =>
            pageContentBuilder(context, arguments: settings.arguments));
    return route;
  } else {
    final Route route =
        MaterialPageRoute(builder: (context) => pageContentBuilder(context));
    return route;
  }
};
