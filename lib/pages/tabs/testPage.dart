import 'package:flutter/material.dart';

class TestPageRoute extends StatefulWidget {
  const TestPageRoute({Key? key}) : super(key: key);

  @override
  _TestPageRouteState createState() => _TestPageRouteState();
}

class _TestPageRouteState extends State<TestPageRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, //标题居中
        title: const Text(
          "项目",
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
        elevation: 0.5, //阴影高度
      ),
      body: Column(children: []),
    );
  }
}
