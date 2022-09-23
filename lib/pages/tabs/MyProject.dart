import 'package:board_app/pages/ProjectLists.dart';
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
  List _projectTitles = [];

  //得到与用户有关的所有项目的id和title
  void _getMyProjectList(String baseCode) async {
    final response = await httpCode.requestHttpCode(
        json.encode(
            {"jsonrpc": "2.0", "method": "getMyProjectsList", "id": 987834805}),
        baseCode);
    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final myProjects = json.decode(res);
      if (mounted) {
        setState(() {
          _myProjects = myProjects["result"];
          _myProjects.forEach((key, value) {
            _projectIDs.add(key);
            _projectTitles.add(value);
          });
        });
      }
      print("== ${_myProjects}");
    } else {
      print(response.reasonPhrase);
    }
  }

//项目看板内容
  _getBoards(int project_id) async {
    final response = await httpCode.requestHttpCode(
        json.encode({
          "jsonrpc": "2.0",
          "method": "getBoard",
          "id": 827046470,
          "params": [project_id]
        }),
        "anNvbnJwYzpiMDNhMWRlODcxNmE5YTc2MDc0MTc2MjEyNTc0OTc2MjM2YWI1YjczOThkMmU3NGJmYzM5MmRhYjZkZGM=");
    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final projectBoard = json.decode(res);
      if (mounted) {
        setState(() {
          print("object = ${projectBoard["result"][0]["columns"][2]}");
        });
      }
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
    int num = 0;
    final _width = MediaQuery.of(context).size.width; //得到屏幕的宽高
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, //标题居中
        title: const Text(
          "我的项目",
          style: TextStyle(fontSize: 15, color: Colors.black),
        ),
        elevation: 0.5, //阴影高度
      ),
      body: ListView.builder(
          itemCount: _projectTitles.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                ListTile(
                  title: Text(_projectTitles[index]),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ProjectListsPage(
                              project_id: _projectIDs[index],
                              title: _projectTitles[index],
                            )));
                  },
                ),
                const Divider()
              ],
            );
          }),
    );
  }
}
