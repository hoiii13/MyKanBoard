import 'dart:math';
import 'dart:convert';
import 'package:board_app/component/receivedJpush.dart';
import 'package:board_app/component/timeChange.dart';
import 'package:board_app/pages/chatProject.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jpush_flutter/jpush_flutter.dart';
import '../pages/tabs/MyTask.dart';
import '../colorAbout/color.dart';
import 'package:board_app/component/requestNetwork.dart';

class MyTaskDetailPage extends StatefulWidget {
  final taskDetail;
  final user_id;
  final username;
  final ipText;
  final token;
  MyTaskDetailPage(
      {Key? key,
      required this.taskDetail,
      required this.user_id,
      this.username,
      required this.ipText,
      required this.token})
      : super(key: key);
  @override
  State<MyTaskDetailPage> createState() => _MyTaskDetailPageState();
}

class _MyTaskDetailPageState extends State<MyTaskDetailPage> {
  String createUser = "";
  String _createUser = " ";
  RequestHttp httpCode = RequestHttp();
  TimeChange timeChange = TimeChange();
  final JPush jpush = JPush();
  ReceviedJPushCode showBox = ReceviedJPushCode();

  void _getCreateTasksUser(int id) async {
    final response = await httpCode.requestHttpCode(
        json.encode({
          "jsonrpc": "2.0",
          "method": "getUser",
          "id": 1769674781,
          "params": {"user_id": id}
        }),
        "anNvbnJwYzpiMDNhMWRlODcxNmE5YTc2MDc0MTc2MjEyNTc0OTc2MjM2YWI1YjczOThkMmU3NGJmYzM5MmRhYjZkZGM=",
        widget.ipText);

    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final userDetail = json.decode(res);
      if (userDetail["result"]["name"] == null ||
          userDetail["result"]["name"] == "") {
        createUser = userDetail["result"]["username"];
      } else
        createUser = userDetail["result"]["name"];
      setState(() {
        if (mounted) {
          _createUser = createUser;
        }
      });
    } else {
      print(response.reasonPhrase);
      throw ("error");
    }
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
    /* _getCreateUser(); */
    Future.delayed(Duration(seconds: 1), () {
      initJpush("user" + widget.user_id.toString());
    });
    int id = int.parse(widget.taskDetail["creator_id"]);
    _getCreateTasksUser(id);
    if (widget.user_id is String) {
      print(">>>>> ${widget.user_id}");
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width; //得到屏幕的宽高
    final _height = MediaQuery.of(context).size.height;
    var _adminColor = Colors.primaries[
        Random().nextInt(Colors.primaries.length)]; //随机生成创建人员的头像的背景颜色

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.2,
        centerTitle: true,
        title: Text(
          "${widget.taskDetail["title"]}",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.navigate_before,
            color: Colors.white,
            size: 35,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: EdgeInsets.fromLTRB(15.0, 20.0, 10.0, 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              //constraints: BoxConstraints(maxHeight: 100, minHeight: 30),
              width: _width - 15.0 * 2,
              decoration: BoxDecoration(
                  color: Colors.white,
                  //弄一个框出来
                  border: Border.all(
                    color: Colors.white,
                    style: BorderStyle.solid,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0)),
              //alignment: AlignmentDirectional.topStart,
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: SingleChildScrollView(
                    //设置框中的内容，实现框中内容的滚动
                    child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topLeft,
                      child: const Text(
                        "任务详情：",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color.fromARGB(255, 0, 29, 72),
                            fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        widget.taskDetail["description"],
                        style: TextStyle(color: Colors.black45, fontSize: 17),
                      ),
                    )
                  ],
                )),
              ),
            ),
            Container(
              width: _width - 15.0 * 2,
              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  //弄一个框出来
                  border: Border.all(
                    color: Colors.white,
                    style: BorderStyle.solid,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(5.0)),
              child: Column(children: [
                Container(
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(16, 20, 20, 10),
                        child: const Icon(
                          Icons.alarm,
                          color: Color.fromARGB(255, 0, 29, 72),
                          size: 24,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 20, 30, 10),
                        child: const Text(
                          "开始时间:",
                          style: TextStyle(
                              color: Color.fromARGB(255, 0, 29, 72),
                              fontSize: 18),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: widget.taskDetail["date_started"] == "0" ||
                                widget.taskDetail["date_started"] == null
                            ? Text(
                                "0000-00-00",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 0, 29, 72),
                                    fontSize: 18),
                              )
                            : Text(
                                "${timeChange.timeStamp(widget.taskDetail["date_started"])}",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 0, 29, 72),
                                    fontSize: 18),
                              ),
                      )
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(16, 10, 20, 20),
                        child: const Icon(
                          Icons.alarm_off,
                          color: Color.fromARGB(255, 0, 29, 72),
                          size: 24,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 30, 20),
                        child: const Text(
                          "结束时间:",
                          style: TextStyle(
                              color: Color.fromARGB(255, 0, 29, 72),
                              fontSize: 18),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                        child: widget.taskDetail["date_due"] == "0" ||
                                widget.taskDetail["date_due"] == null
                            ? Text(
                                "0000-00-00",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 0, 29, 72),
                                    fontSize: 18),
                              )
                            : Text(
                                "${timeChange.timeStamp(widget.taskDetail["date_due"])}",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 0, 29, 72),
                                    fontSize: 18),
                              ),
                      )
                    ],
                  ),
                ),
              ]),
            ),
            Container(
              width: _width - 15.0 * 2,
              margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  //弄一个框出来
                  border: Border.all(
                    color: Colors.white,
                    style: BorderStyle.solid,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(5.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 20, 20, 20),
                        child: const Icon(Icons.people,
                            color: Color.fromARGB(255, 0, 29, 72), size: 22),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 20, 30, 20),
                        child: const Text(
                          "参与人员:",
                          style: TextStyle(
                              color: Color.fromARGB(255, 0, 29, 72),
                              fontSize: 18),
                        ),
                      ),
                      Container(
                        //显示参与的人员的头像
                        child: widget.taskDetail["assignee_username"] == null
                            ? const CircleAvatar(
                                backgroundColor:
                                    Color.fromARGB(255, 136, 199, 138),
                                child: Text(""),
                              )
                            : CircleAvatar(
                                backgroundColor:
                                    const Color.fromARGB(255, 136, 199, 138),
                                child: widget.taskDetail["assignee_name"] ==
                                            "" ||
                                        widget.taskDetail["assignee_name"] ==
                                            null
                                    ? Text(
                                        widget.taskDetail["assignee_username"]
                                            .toString()
                                            .substring(0, 1), //取名字的第一个字
                                        style: const TextStyle(
                                            color: Colors.white),
                                      )
                                    : Text(
                                        widget.taskDetail["assignee_name"]
                                            .toString()
                                            .substring(0, 1), //取名字的第一个字
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                /* backgroundColor: Colors.primaries[
                            Random().nextInt(Colors.primaries.length)], */
                              ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 10, 20, 20),
                        child: const Icon(Icons.person_outline,
                            color: Color.fromARGB(255, 0, 29, 72), size: 22),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 10, 30, 20),
                        child: const Text(
                          "创建人员:",
                          style: TextStyle(
                              color: Color.fromARGB(255, 0, 29, 72),
                              fontSize: 18),
                        ),
                      ),
                      Container(
                        //margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                        //显示参与的人员的头像
                        child: CircleAvatar(
                          backgroundColor:
                              const Color.fromARGB(255, 191, 64, 100),
                          child: Text(
                            _createUser.toString().substring(0, 1), //取名字的前2个字
                            style: const TextStyle(color: Colors.white),
                          ),
                          // backgroundColor: _adminColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              alignment: AlignmentDirectional.center,
              child: ElevatedButton(
                style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(const Size(200, 50)),
                    backgroundColor: MaterialStateProperty.all(Colors.white)),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ChatProjectPage(
                            task_id: widget.taskDetail["id"],
                            user_id: widget.user_id,
                            task_title: widget.taskDetail["title"],
                            project_id: widget.taskDetail["project_id"],
                            username: widget.username,
                            ipText: widget.ipText,
                            token: widget.token,
                          )));
                },
                child: const Text(
                  "进入评论区",
                  style: TextStyle(
                      color: Color.fromARGB(255, 0, 29, 72), fontSize: 18),
                ),
              ),
            )
          ],
        ),
      )),
    );
  }
}

class CreateTaskUser {
  final String createUser_id;
  final String createUsername;
  CreateTaskUser({required this.createUser_id, required this.createUsername});

  @override
  String toString() {
    return "$createUser_id $createUsername";
  }
}
