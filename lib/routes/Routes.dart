

import 'package:board_app/pages/chatProject.dart';
/* import 'package:board_app/pages/tabs/MyMessage.dart';
import 'package:board_app/pages/testNotice.dart'; */
import 'package:flutter/material.dart';
import '../pages/Tabs.dart';
import 'package:board_app/pages/Login.dart';
import '../pages/testpage.dart';
/* import '../pages/TestTime.dart';
import '../pages/TestGongXiang.dart';
import '../pages/chatProject.dart'; */

final routes = {
  '/': (context, {aguments}) => Tabs(),
  /*  '/notice': (context) => NoticePage(),
  '/time': (context) => TestStreamBuilderPage(),
  '/gongxiang': (context) => InheritedWidgetTestRoute(), */
  '/chats': (context, {task_id, user_id, project_id, project_title}) =>
      ChatProjectPage(
          task_id: task_id,
          user_id: user_id,
          project_title: project_title,
          project_id: project_id),
  '/login': (context) => LoginPage(),
  '/test': (context) => const TestPage()
  
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
