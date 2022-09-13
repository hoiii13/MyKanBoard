import 'dart:math';
import 'dart:convert';
import 'package:board_app/pages/chatProject.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../pages/tabs/MyTask.dart';
import '../colorAbout/color.dart';

class MyTaskDetailPage extends StatefulWidget {
  final taskDetail;
  final user_id;
  final username;
  MyTaskDetailPage(
      {Key? key,
      required this.taskDetail,
      required this.user_id,
      this.username})
      : super(key: key);
  @override
  State<MyTaskDetailPage> createState() => _MyTaskDetailPageState();
}

class _MyTaskDetailPageState extends State<MyTaskDetailPage> {
  String createUser = "";
  String _createUser = " ";
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void _getCreateTasksUser(int id) async {
    var headers = {
      'Authorization':
          'Basic anNvbnJwYzpiMDNhMWRlODcxNmE5YTc2MDc0MTc2MjEyNTc0OTc2MjM2YWI1YjczOThkMmU3NGJmYzM5MmRhYjZkZGM=',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'GET', Uri.parse('http://43.154.142.249:18868/jsonrpc.php'));
    request.body = json.encode({
      "jsonrpc": "2.0",
      "method": "getUser",
      "id": 1769674781,
      "params": {"user_id": id}
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final userDetail = json.decode(res);
      if (userDetail["result"]["name"] == null ||
          userDetail["result"]["name"] == "") {
        createUser = userDetail["result"]["username"];
      } else
        createUser = userDetail["result"]["name"];
      setState(() {
        _createUser = createUser;
      });
      print("@! = ${createUser}");
    } else {
      print(response.reasonPhrase);
      throw ("error");
    }
  }

  @override
  void initState() {
    /* _getCreateUser(); */
    int id = int.parse(widget.taskDetail["creator_id"]);
    _getCreateTasksUser(id);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width; //得到屏幕的宽高
    final _height = MediaQuery.of(context).size.height;
    var _adminColor = Colors.primaries[
        Random().nextInt(Colors.primaries.length)]; //随机生成创建人员的头像的背景颜色

    int id = int.parse(widget.taskDetail["creator_id"]);
    // print("!! = ${widget.taskDetail}");
    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        centerTitle: true,
        title: Text(
          "${widget.taskDetail["title"]}",
          style: TextStyle(fontSize: 15, color: Colors.red),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.navigate_before,
            color: Colors.red,
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
            /* const Text(
              "任务详情：",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontSize: 15),
            ), */
            Padding(
              //任务详情内容的显示
              padding: EdgeInsets.only(top: 5.0),
              child: Container(
                //constraints: BoxConstraints(maxHeight: 100, minHeight: 30),
                width: _width - 15.0 * 2,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    //弄一个框出来
                    border: Border.all(
                      color: Color.fromARGB(255, 238, 238, 238),
                      style: BorderStyle.solid,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(5.0)),
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
                          style: TextStyle(color: Colors.black, fontSize: 15),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          widget.taskDetail["description"],
                          style: TextStyle(color: Colors.black45),
                        ),
                      )
                    ],
                  )),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5.0),
              child: Container(
                width: _width - 15.0 * 2,
                margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    //弄一个框出来
                    border: Border.all(
                      color: Color.fromARGB(255, 238, 238, 238),
                      style: BorderStyle.solid,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(5.0)),
                child: Column(children: [
                  ListTile(
                    //contentPadding: EdgeInsets.all(5),
                    leading: const Icon(
                      Icons.calendar_today,
                      color: Colors.black,
                      size: 20,
                    ),
                    title: const Text(
                      "开始时间:",
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    trailing: widget.taskDetail["date_started"] == "0"
                        ? Text(
                            "0000-00-00",
                            style:
                                TextStyle(color: Colors.black45, fontSize: 15),
                          )
                        : Text(
                            "${DateTime.fromMillisecondsSinceEpoch(int.parse(widget.taskDetail["date_started"]) * 1000).toString().substring(0, 16)}",
                            style:
                                TextStyle(color: Colors.black45, fontSize: 15),
                          ),
                  ),
                  ListTile(
                    //contentPadding: EdgeInsets.all(5),
                    leading: Icon(
                      Icons.domain_verification,
                      color: Colors.black,
                    ),
                    title: Text(
                      "结束时间:",
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    trailing: widget.taskDetail["date_due"] == "0"
                        ? Text(
                            "0000-00-00",
                            style:
                                TextStyle(color: Colors.black45, fontSize: 15),
                          )
                        : Text(
                            "${DateTime.fromMillisecondsSinceEpoch(int.parse(widget.taskDetail["date_due"]) * 1000).toString().substring(0, 16)}",
                            style:
                                TextStyle(color: Colors.black45, fontSize: 15),
                          ),
                  ),
                ]),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5.0),
              child: Container(
                width: _width - 15.0 * 2,
                margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    //弄一个框出来
                    border: Border.all(
                      color: Color.fromARGB(255, 238, 238, 238),
                      style: BorderStyle.solid,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(5.0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ListTile(
                      leading: Icon(
                        Icons.people,
                        color: Colors.black,
                      ),
                      title: Text(
                        "参与人员:",
                        style: TextStyle(color: Colors.black, fontSize: 15),
                      ),
                    ),
                    Padding(
                      //显示参与的人员的头像
                      padding: EdgeInsets.only(left: 20),
                      child: CircleAvatar(
                        child: widget.taskDetail["assignee_name"] == ""
                            ? Text(
                                "${widget.taskDetail["assignee_username"].toString().substring(0, 1)}", //取名字的第一个字
                                style: TextStyle(color: Colors.white),
                              )
                            : Text(
                                "${widget.taskDetail["assignee_name"].toString().substring(0, 1)}", //取名字的第一个字
                                style: TextStyle(color: Colors.white),
                              ),
                        backgroundColor: Color.fromARGB(255, 136, 199, 138),
                        /* backgroundColor: Colors.primaries[
                            Random().nextInt(Colors.primaries.length)], */
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.person_outline,
                        color: Colors.black,
                      ),
                      title: Text(
                        "创建人员:",
                        style: TextStyle(color: Colors.black, fontSize: 15),
                      ),
                    ),
                    Padding(
                      //显示创建人员的头像
                      padding: EdgeInsets.only(left: 20),
                      child: CircleAvatar(
                        child: Text(
                          "${_createUser.toString().substring(0, 1)}", //取名字的前2个字
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                        // backgroundColor: _adminColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              alignment: AlignmentDirectional.center,
              child: ElevatedButton(
                child: Text(
                  "进入评论区",
                  style: TextStyle(color: Colors.red),
                ),
                style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(200, 50)),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.grey[200])),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ChatProjectPage(
                            task_id: widget.taskDetail["id"],
                            user_id: widget.user_id,
                            project_title: widget.taskDetail["title"],
                            project_id: widget.taskDetail["project_id"],
                            username: widget.username,
                          )));
                },
              ),
            )
          ],
        ),
      )),
    );
  }

  /* void layoutbox() {
    final _width = MediaQuery.of(context).size.width;
    Container(
        width: _width - 15.0 * 2,
        margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
        decoration: BoxDecoration(
            color: Colors.grey[200],
            //弄一个框出来
            border: Border.all(
              color: Color.fromARGB(255, 238, 238, 238),
              style: BorderStyle.solid,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(5.0)));
  } */

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
