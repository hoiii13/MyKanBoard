import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:board_app/component/requestNetwork.dart';

class ProjectAboutpage extends StatefulWidget {
  final username;
  final userToken;
  ProjectAboutpage({Key? key, this.username, this.userToken}) : super(key: key);

  @override
  State<ProjectAboutpage> createState() => _ProjectAboutpageState();
}

class _ProjectAboutpageState extends State<ProjectAboutpage> {
  RequestHttp httpCode = RequestHttp();
  bool _isVisible = false;
  Map _myProjects = {};
  List _projectIDs = [];
  void _getMyProjectList(String baseCode) async {
    final response = await httpCode.requestHttpCode(
        json.encode(
            {"jsonrpc": "2.0", "method": "getMyProjectsList", "id": 987834805}),
        baseCode);
    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final myProjects = json.decode(res);
      setState(() {
        _myProjects = myProjects["result"];
        _myProjects.forEach((key, value) {
          _projectIDs.add(value);
        });
      });
      print("== ${_myProjects}");
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    _getMyProjectList(widget.userToken);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("pro = ${_projectIDs}");
    final _width = MediaQuery.of(context).size.width; //得到屏幕的宽高
    return Scaffold(
        appBar: AppBar(
          centerTitle: true, //标题居中
          title: const Text(
            "我的项目",
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
          elevation: 0.5, //阴影高度
        ),
        body: ListView(
          children: _projectIDs.map((value) {
            return Container(
              width: _width,
              child: Column(
                children: [
                  ListTile(
                    title: Text(value),
                    onTap: () {
                      setState(() {
                        _isVisible = !_isVisible;
                      });
                    },
                  ),
                  /* Visibility(
                    visible: _isVisible,
                    child: Text("111"),
                  ) */
                ],
              ),
            );
          }).toList(),
        ));
  }
}
