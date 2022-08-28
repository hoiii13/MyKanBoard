import 'package:board_app/routes/Routes.dart';
import 'package:flutter/material.dart';
import 'colorAbout/color.dart';
import 'res/task.dart';
import 'package:date_format/date_format.dart';

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
        primarySwatch: createMaterialColor(Color.fromARGB(255, 134, 195, 245)),
      ),
      debugShowCheckedModeBanner: false, //去掉debug的图标
      initialRoute: '/', //表示初始化要加载的页面
      onGenerateRoute: onGenerateRoute,
    );
  }
}
