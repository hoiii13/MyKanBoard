import 'package:board_app/pages/ProjectLists.dart';
import 'package:board_app/pages/chatProject.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:board_app/component/requestNetwork.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

class ProjectAboutpage extends StatefulWidget {
  final username;
  final userToken;
  final user_id;
  ProjectAboutpage({Key? key, this.username, this.userToken, this.user_id})
      : super(key: key);

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
  List _creatorList = [];
  List creatorIds = [];
  int num = 0;
  final JPush jpush = JPush();

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
          creatorIds = _myProjects.map<ProjectAbout>((row) {
            return ProjectAbout(owner_id: row["owner_id"]);
          }).toList();
          print("object == ${creatorIds}");

          for (var i = 0; i < _myProjects.length; i++) {
            Future.delayed(Duration(seconds: 1), () async {
              final _user =
                  await _getUser(int.parse(_myProjects[i]["owner_id"]));
              users.add(_user);
            });
          }
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
      if (mounted) {
        setState(() {
          _userDetail = userDetail["result"];
        });
      }
    } else {
      print(response.reasonPhrase);
    }
    return _userDetail;
  }

  Future initJpush(String aliasName) async {
    jpush.applyPushAuthority(
        new NotificationSettingsIOS(sound: true, alert: true, badge: true));
    try {
      jpush.addEventHandler(
          onReceiveNotification: (Map<String, dynamic> message) async {
        print("flutter onReceiveNotification: $message");
      },
          //点击通知栏跳转到聊天页面
          onOpenNotification: (Map<String, dynamic> message) async {
        final res = message["extras"]["cn.jpush.android.EXTRA"];
        final _extra = json.decode(res);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ChatProjectPage(
                  task_id: _extra["task_id"],
                  user_id: widget.user_id,
                  task_title: message["title"],
                  project_id: _extra["project_id"],
                  username: widget.username,
                )));
        print("flutter onOpenNotification: $message");
      }, onReceiveMessage: (Map<String, dynamic> message) async {
        print("flutter onReceiveMessage: $message");
      });
    } catch (e) {
      print("极光sdk配置异常");
    }
  }

  @override
  void initState() {
    _getMyProjectList(widget.userToken);
    Future.delayed(Duration(seconds: 1), () {
      initJpush(widget.username);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            //防止_creatorList叠加
            _creatorList.clear();
            if (users.length == _myProjects.length) {
              for (var i = 0; i < users.length; i++) {
                for (var j = 0; j < users.length; j++) {
                  if (users[j]["id"] == creatorIds[i].toString()) {
                    _creatorList.add(users[j]);
                    break;
                  }
                }
              }
            }
            return Column(
              children: [
                ListTile(
                  title: Text(_myProjects[index]["name"]),
                  subtitle: users.length != _myProjects.length
                      ? Text(
                          "创建人：加载中...",
                          style: TextStyle(fontSize: 13),
                        )
                      : Text(
                          "创建人：${_creatorList[index]["username"]}",
                          style: TextStyle(fontSize: 13),
                        ),
                  //subtitle: Text("创建人：${users[index]["username"]}"),
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
