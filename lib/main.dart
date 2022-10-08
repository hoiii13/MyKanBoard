import 'dart:collection';
import 'dart:convert';

import 'package:board_app/pages/Login.dart';
import 'package:board_app/pages/MyTaskDetail.dart';
import 'package:board_app/pages/Tabs.dart';
import 'package:board_app/pages/chatProject.dart';
import 'package:board_app/pages/tabs/MyCenter.dart';
import 'package:board_app/pages/tabs/MyMessage.dart';
import 'package:board_app/pages/tabs/MyProject.dart';
import 'package:board_app/pages/tabs/MyTask.dart';
import 'package:board_app/routes/Routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colorAbout/color.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            primarySwatch: createMaterialColor(Color.fromARGB(255, 0, 29, 72)),
            fontFamily: "Siyuan-Light"),
        /* builder: (context, widget) {
          return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: LoginPage());
        }, */
        debugShowCheckedModeBanner: false, //去掉debug的图标
        initialRoute: '/', //表示初始化要加载的页面
        onGenerateRoute: onGenerateRoute);
  }
}
