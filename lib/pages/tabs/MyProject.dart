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
  List _myProjects = [];
  List _projectIDs = [];
  List _projectTitles = [];
  Map _userDetail = {};
  List users = [];

  //得到与用户有关的所有项目的id和title
  void _getMyProjectList(String baseCode) async {
    final response = await httpCode.requestHttpCode(
        json.encode(
            {"jsonrpc": "2.0", "method": "getmyProjects", "id": 2134420212}),
        baseCode);
    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final myProjects = json.decode(res);
      if (mounted) {
        setState(() {
          _myProjects = myProjects["result"];
          List a = _myProjects.map<ProjectAbout>((row) {
            return ProjectAbout(owner_id: row["owner_id"]);
          }).toList();
          print("object == ${a}");
          /* for (var i = 0; i < _myProjects.length; i++) {
            print("test = ${_myProjects[i]["owner_id"]}");
            _getUser(int.parse(_myProjects[i]["owner_id"]));
          } */
          /* _myProjects.forEach((key, value) {
            _projectIDs.add(key);
            _projectTitles.add(value);
          }); */
        });
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  _getUser(int user_id) async {
    final response = await httpCode.requestHttpCode(
        json.encode({
          "jsonrpc": "2.0",
          "method": "getUser",
          "id": 1769674781,
          "params": {"user_id": user_id}
        }),
        "anNvbnJwYzpiMDNhMWRlODcxNmE5YTc2MDc0MTc2MjEyNTc0OTc2MjM2YWI1YjczOThkMmU3NGJmYzM5MmRhYjZkZGM=");

    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final userDetail = json.decode(res);
      _userDetail = userDetail["result"];
      print("999 = ${_userDetail["username"]}");
      setState(() {
        users.add(_userDetail);
        List s = users.map<UserAbout>((row) {
          return UserAbout(username: row["username"]);
        }).toList();
        print("nnn = ${user_id} ${s}");
        //print("users = ${users}");
      });
    } else {
      print(response.reasonPhrase);
    }
    // return _userDetail;
  }

  @override
  void initState() {
    _getMyProjectList(widget.userToken);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int num = 0;
    for (var i = 0; i < _myProjects.length; i++) {
      //_getUser(int.parse(_myProjects[i]["owner_id"]));
    }
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
          itemCount: _myProjects.length,
          itemBuilder: (context, index) {
            //_getUser(int.parse(_myProjects[index]["owner_id"]));
            return Column(
              children: [
                ListTile(
                  title: Text(_myProjects[index]["name"]),
                  subtitle: users.isEmpty
                      ? Text("创建人：")
                      : Text("创建人：${users[index]["username"]}"),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ProjectListsPage(
                              project_id: _myProjects[index]["id"],
                              title: _myProjects[index]["name"],
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

class UserAbout {
  final String username;
  UserAbout({required this.username});

  @override
  String toString() {
    return username;
  }
}

class ProjectAbout {
  final String owner_id;
  ProjectAbout({required this.owner_id});

  @override
  String toString() {
    return owner_id;
  }
}
