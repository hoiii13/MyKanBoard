import 'package:board_app/component/receivedJpush.dart';
import 'package:board_app/pages/ChangeIp.dart';
import 'package:board_app/pages/WriteIP.dart';
import 'package:board_app/pages/Login.dart';
import 'package:board_app/pages/chatProject.dart';
import 'package:board_app/pages/tabs/MyMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:board_app/component/requestNetwork.dart';

class MyCenterPage extends StatefulWidget {
  final username;
  final userToken;
  final user_id;
  final name;
  final ipText;
  MyCenterPage(
      {Key? key,
      this.username,
      required this.userToken,
      this.user_id,
      this.name,
      required this.ipText})
      : super(key: key);

  @override
  State<MyCenterPage> createState() => _MyCenterPageState();
}

class _MyCenterPageState extends State<MyCenterPage> {
  RequestHttp httpCode = RequestHttp();
  String myRole = "";
  Map _userMessage = {};
  Map _appRoles = {};
  final JPush jpush = JPush();
  ReceviedJPushCode showBox = ReceviedJPushCode();

  void _getMe(String baseCode) async {
    final response = await httpCode.requestHttpCode(
        json.encode({"jsonrpc": "2.0", "method": "getMe", "id": 1718627783}),
        baseCode,
        widget.ipText);
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
        widget.userToken,
        widget.ipText);

    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final appRoles = json.decode(res);
      _appRoles = appRoles["result"];
      // print("appR = ${_appRoles}");
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
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  LoginPage(ipText: widget.ipText)),
          (route) => false);
    }
    print("delete = $result");
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
        /* return ReceviedJPushCode(
          task_title: message["title"],
          content: message["alert"],
          sendPeople: _extra["sendPeople"],
        ); */
        showBox.showAlertDialog(
            context, message["title"], message["alert"], _extra["sendPeople"]);
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
    Future.delayed(Duration(seconds: 2), () {
      initJpush("user" + widget.user_id.toString());
    });
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
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: Center(
            child: CircularProgressIndicator(
                color: Color.fromARGB(255, 0, 29, 72))),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  //头像
                  Container(
                    //color: Colors.green,
                    margin: EdgeInsets.fromLTRB(20, 0, 10, 10),
                    child: CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 191, 64, 100),
                      radius: 37,
                      child: _userMessage["name"] == ""
                          ? Text(
                              _userMessage["username"]
                                  .toString()
                                  .substring(0, 1),
                              style: const TextStyle(
                                  fontSize: 23, color: Colors.white),
                            )
                          : Text(
                              _userMessage["name"].toString().substring(0, 1),
                              style: const TextStyle(
                                  fontSize: 23, color: Colors.white),
                            ),
                    ),
                  ),
                  //用户名和姓名
                  Container(
                    width: _width * 0.7,
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          alignment: Alignment.topLeft,
                          child: Text(
                            _userMessage["username"],
                            style: TextStyle(
                                fontSize: 24,
                                color: Color.fromARGB(255, 0, 29, 72)),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: _userMessage["name"] == ""
                                      ? Text("姓名：无",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Color.fromARGB(
                                                  255, 0, 29, 72)))
                                      : Text(
                                          "姓名：${_userMessage["name"]}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Color.fromARGB(
                                                  255, 0, 29, 72)),
                                        )),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        ChangeIPPage(
                                                          ipText: widget.ipText,
                                                        )));
                                      },
                                      child: Text(
                                        "切换ip",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                    /* child: Text(
                                      "切换ip",
                                      style: TextStyle(color: Colors.grey),
                                    ), */
                                  ),
                                  Container(
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder:
                                                    ((BuildContext context) =>
                                                        ChangeIPPage(
                                                          ipText: widget.ipText,
                                                        ))));
                                        /* Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    ChangeIpPage())); */
                                      },
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: Container(
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Container(
                            color: Colors.white,
                            width: _width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.mail,
                                      color: Color.fromARGB(255, 0, 29, 72)),
                                  title: Container(
                                    transform:
                                        Matrix4.translationValues(-15, 0, 0),
                                    child: const Text(
                                      "邮箱:",
                                      style: TextStyle(
                                          color: Color.fromARGB(255, 0, 29, 72),
                                          fontSize: 17),
                                    ),
                                  ),
                                  trailing: _userMessage["email"] == ""
                                      ? Text(
                                          "无",
                                          style: TextStyle(
                                              fontSize: 17,
                                              color: Color.fromARGB(
                                                  255, 0, 29, 72)),
                                        )
                                      : Text(
                                          "${_userMessage["email"]}",
                                          style: TextStyle(
                                              fontSize: 17,
                                              color: Color.fromARGB(
                                                  255, 0, 29, 72)),
                                        ),
                                ),
                                const Divider(
                                  color: Color.fromARGB(255, 238, 238, 238),
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.assignment_ind,
                                    color: Color.fromARGB(255, 0, 29, 72),
                                  ),
                                  title: Container(
                                    transform:
                                        Matrix4.translationValues(-15, 0, 0),
                                    child: const Text(
                                      "角色:",
                                      style: TextStyle(
                                          color: Color.fromARGB(255, 0, 29, 72),
                                          fontSize: 17),
                                    ),
                                  ),
                                  trailing: _userMessage["role"] == ""
                                      ? Text(
                                          "无",
                                          style: TextStyle(
                                              fontSize: 17,
                                              color: Color.fromARGB(
                                                  255, 0, 29, 72)),
                                        )
                                      : Text(
                                          "${_appRoles[_userMessage["role"]]}",
                                          style: TextStyle(
                                              fontSize: 17,
                                              color: Color.fromARGB(
                                                  255, 0, 29, 72)),
                                        ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: _width * 0.5,
                          height: 50,
                          margin: EdgeInsets.fromLTRB(0, 30, 0, 40),
                          child: ElevatedButton(
                            onPressed: () {
                              jpush.deleteAlias();
                              deleteData("password");
                            },
                            child: Text("退出登录",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                          ),
                        ),
                      ],
                    ))),
          ],
        ),
      );
    }
  }
}
