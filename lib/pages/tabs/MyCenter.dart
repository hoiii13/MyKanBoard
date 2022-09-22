import 'package:board_app/pages/Login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:board_app/component/requestNetwork.dart';

class MyCenterPage extends StatefulWidget {
  final username;
  final userToken;
  MyCenterPage({Key? key, this.username, required this.userToken})
      : super(key: key);

  @override
  State<MyCenterPage> createState() => _MyCenterPageState();
}

class _MyCenterPageState extends State<MyCenterPage> {
  RequestHttp httpCode = RequestHttp();
  String myRole = "";
  Map _userMessage = {};
  Map _appRoles = {};

  void _getMe(String baseCode) async {
    final response = await httpCode.requestHttpCode(
        json.encode({"jsonrpc": "2.0", "method": "getMe", "id": 1718627783}),
        baseCode);
    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final userMess = json.decode(res);
      setState(() {
        _userMessage = userMess["result"];
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  _getAppRoles() async {
    final response = await httpCode.requestHttpCode(
        json.encode({
          "jsonrpc": "2.0",
          "method": "getApplicationRoles",
          "id": 317154243
        }),
        "anNvbnJwYzpiMDNhMWRlODcxNmE5YTc2MDc0MTc2MjEyNTc0OTc2MjM2YWI1YjczOThkMmU3NGJmYzM5MmRhYjZkZGM=");

    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final appRoles = json.decode(res);
      _appRoles = appRoles["result"];
    } else {
      print(response.reasonPhrase);
    }
  }

  //删除存储下来的token（退出登陆）
  deleteData(String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final result = await prefs.remove(password);
    if (result) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          (route) => false);
    }
    print("delete = $result");
  }

  @override
  void initState() {
    _getMe(widget.userToken);
    _getAppRoles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width; //得到屏幕的宽高
    if (_userMessage.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true, //标题居中
          title: const Text(
            "个人中心",
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
          elevation: 0.5, //阴影高度
        ),
        body: Center(
          child: CircularProgressIndicator(
              color: Color.fromARGB(255, 148, 196, 235)),
        ),
      );
    } else {
      return Scaffold(
          appBar: AppBar(
            centerTitle: true, //标题居中
            title: const Text(
              "个人中心",
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
            elevation: 0.5, //阴影高度
          ),
          body: Container(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    //头像
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 35,
                        child: _userMessage["name"] == ""
                            ? Text(
                                _userMessage["username"]
                                    .toString()
                                    .substring(0, 1),
                                style: const TextStyle(fontSize: 23),
                              )
                            : Text(
                                _userMessage["name"].toString().substring(0, 1),
                                style: const TextStyle(fontSize: 23),
                              ),
                      ),
                    ),
                    //用户名和姓名
                    Container(
                      width: _width * 0.6,
                      margin: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(
                            color: const Color.fromARGB(255, 238, 238, 238),
                            style: BorderStyle.solid,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(5.0)),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                            child: Container(
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: _width * 0.2,
                                    child: Text(
                                      "用户名：",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      _userMessage["username"],
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                            child: Container(
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: _width * 0.2,
                                    child: Text(
                                      "姓名：",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Container(
                                      child: _userMessage["name"] == ""
                                          ? Text("无",
                                              style: TextStyle(fontSize: 16))
                                          : Text(
                                              _userMessage["name"],
                                              style: TextStyle(fontSize: 16),
                                            ))
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 30, 10, 0),
                  child: Container(
                    // width: _width * 0.8,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(
                          color: const Color.fromARGB(255, 238, 238, 238),
                          style: BorderStyle.solid,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.mail,
                            color: Colors.black45,
                          ),
                          title: const Text(
                            "邮箱:",
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          ),
                          trailing: _userMessage["email"] == ""
                              ? Text("无")
                              : Text("${_userMessage["email"]}"),
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.emoji_people,
                            color: Colors.black45,
                          ),
                          title: const Text(
                            "角色:",
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          ),
                          trailing: _userMessage["role"] == ""
                              ? Text("无")
                              : Text("${_appRoles[_userMessage["role"]]}"),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  width: _width * 0.5,
                  height: 50,
                  margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child: ElevatedButton(
                    onPressed: () {
                      deleteData("password");
                    },
                    child: Text("退出登录"),
                  ),
                )
              ],
            ),
          ));
    }
  }
}
