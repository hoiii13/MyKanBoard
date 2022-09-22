import 'dart:convert';

import 'package:board_app/routes/Routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'colorAbout/color.dart';
import 'package:date_format/date_format.dart';
import 'package:board_app/pages/testpage.dart';

void main() {
  runApp(const MyApp());
  Map a = {"2": "1234", "22": "555", "99": "9999"};
  print("qq = ${a[1]}");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: createMaterialColor(Colors.white),
      ),
      debugShowCheckedModeBanner: false, //去掉debug的图标
      initialRoute: '/login', //表示初始化要加载的页面
      onGenerateRoute: onGenerateRoute,
    );
  }
}
