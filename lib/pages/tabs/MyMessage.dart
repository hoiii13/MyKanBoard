import 'package:board_app/component/timeChange.dart';
import 'package:board_app/pages/MyTaskDetail.dart';
import 'package:board_app/pages/chatProject.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:board_app/component/requestNetwork.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

//"我的消息"页面
class MyMessagePage extends StatefulWidget {
  final user_id;
  final username;
  final name;
  MyMessagePage({Key? key, this.user_id, this.username, this.name})
      : super(key: key);

  @override
  State<MyMessagePage> createState() => _MyMessagePageState();
}

class _MyMessagePageState extends State<MyMessagePage> {
  RequestHttp httpCode = RequestHttp();
  TimeChange timeChange = TimeChange();
  final JPush jpush = JPush();

  List _messageList = [];
  List _TaskDetails = [];

  Future<void> _onRefresh() async {
    print("执行刷新");
    _messageList = [];
    _Alltasks = [];
    _AllComments = [];
    _TaskDetails = [];
    _getProject();
    await Future.delayed(Duration(seconds: 2), () {});
  }

  List Allprojects = [];
  //得到所有项目的id
  _getProject() async {
    final response = await httpCode.requestHttpCode(
        json.encode(
            {"jsonrpc": "2.0", "method": "getAllProjects", "id": 2134420212}),
        "anNvbnJwYzpiMDNhMWRlODcxNmE5YTc2MDc0MTc2MjEyNTc0OTc2MjM2YWI1YjczOThkMmU3NGJmYzM5MmRhYjZkZGM=");
    if (response.statusCode != 200) {
      print(response.reasonPhrase);
      throw ("error");
    }
    final res = await response.stream.bytesToString();
    final projects = json.decode(res);
    final _projects = projects["result"];
    setState(() {
      Allprojects = _projects;
      for (var i = 0; i < Allprojects.length; i++) {
        //_getData(int.parse(Allprojects[i]["id"]));
        Future.delayed(Duration(seconds: 1), () async {
          final Activities =
              await _getProjectActivity(int.parse(Allprojects[i]["id"]));
          print("chang = ${Activities.length}   ${Allprojects[i]["id"]}");
          _Allactivities.addAll(Activities);
        });
      }
    });
  }

//得到动态记录
  List _Allactivities = [];
  List _MyActivityAbouts = [];
  List _myTasks = [];
  _getProjectActivity(int id) async {
    List _activities = [];
    final response = await httpCode.requestHttpCode(
        json.encode({
          "jsonrpc": "2.0",
          "method": "getProjectActivity",
          "id": 942472945,
          "params": {"project_id": id}
        }),
        "anNvbnJwYzpiMDNhMWRlODcxNmE5YTc2MDc0MTc2MjEyNTc0OTc2MjM2YWI1YjczOThkMmU3NGJmYzM5MmRhYjZkZGM=");

    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final activities = json.decode(res);
      setState(() {
        _activities = activities["result"];
      });
      print("lll = ${_activities.length}");
      /* setState(() {
        _Allactivities.addAll(_activities);
        print("ppp = ${_Allactivities.length}");
      }); */
    } else {
      print(response.reasonPhrase);
    }
    return _activities;
  }

  List _Alltasks = [];
  //得到所有项目中的任务
  _getData(int id) async {
    //获得数据
    final response = await httpCode.requestHttpCode(
        json.encode({
          "jsonrpc": "2.0",
          "method": "getBoard",
          "id": 827046470,
          "params": [id]
        }),
        "anNvbnJwYzpiMDNhMWRlODcxNmE5YTc2MDc0MTc2MjEyNTc0OTc2MjM2YWI1YjczOThkMmU3NGJmYzM5MmRhYjZkZGM=");

    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final tasks = json.decode(res);
      List _tasks = [];
      List _content = tasks["result"][0]["columns"]; //为了计算长度而设置的List变量
      for (var i = 0; i < _content.length; i++) {
        //通过看板的列得到任务
        if (_content[i]["tasks"].isNotEmpty) {
          _tasks.addAll(_content[i]["tasks"]);
        }
      }
      setState(() {
        for (var i = 0; i < _tasks.length; i++) {
          _getComments(int.parse(_tasks[i]["id"]));
        }
      });

      final mytasks = _tasks;
      _Alltasks.addAll(mytasks);
    } else {
      print(response.reasonPhrase);
    }
  }

//根据所有任务得到所有评论
  List _AllComments = [];
  _getComments(int task_id) async {
    final response = await httpCode.requestHttpCode(
        json.encode({
          "jsonrpc": "2.0",
          "method": "getAllComments",
          "id": 148484683,
          "params": {"task_id": task_id}
        }),
        "anNvbnJwYzpiMDNhMWRlODcxNmE5YTc2MDc0MTc2MjEyNTc0OTc2MjM2YWI1YjczOThkMmU3NGJmYzM5MmRhYjZkZGM=");
    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final comments = json.decode(res);
      setState(() {
        final Allcomments = comments["result"];
        _AllComments.addAll(Allcomments);
        //print("this = ${Allcomments}");
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  List _taskName = [];
  _showAlertDialog(String task_title, String content, String sendPeople) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("任务：${task_title}"),
              content: Text("${sendPeople}@提到了你: \n\n${content}"),
              semanticLabel: 'Label',
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "ok",
                      style: TextStyle(color: Colors.red),
                    ))
              ],
            ));
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
        _showAlertDialog(
            message["title"], message["alert"], _extra["sendPeople"]);
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
    _getProject();
    Future.delayed(Duration(seconds: 1), () {
      initJpush(widget.username);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /* print("ooo = ${Allprojects.length}");
    if (_Allactivities.isNotEmpty) {
      List activity = [];
      print("len = ${_Allactivities.length}");
      for (var i = 0; i < _Allactivities.length; i++) {
        if (_Allactivities[i]["event_name"] == "comment.create") {
          //print("All == ${_Allactivities[i]["comment"]}");
          if (_Allactivities[i]["comment"]["comment"]
                  .contains("@" + widget.username) ==
              true) {
            _MyActivityAbouts.add(_Allactivities[i]);
          }
        } else if (_Allactivities[i]["event_name"] == "task.assign_change") {
          if (_Allactivities[i]["event_title"]
                      .contains("指派给了 " + widget.username) ==
                  true ||
              _Allactivities[i]["event_title"]
                      .contains("指派给了 " + widget.name) ==
                  true) {
            _MyActivityAbouts.add(_Allactivities[i]);
          }
        }
      }
      print("object == ${_MyActivityAbouts.length}");
      for (var i = 0; i < _MyActivityAbouts.length; i++) {
        if (_myTasks.contains(_MyActivityAbouts[i]["task_id"]) == false) {
          _myTasks.add(_MyActivityAbouts[i]);
        }
      }
      // print("object == ${_myTasks.length}");
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, //标题居中
        title: const Text(
          "我的消息",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        elevation: 0.5, //阴影高度
      ),
      body: ListView.builder(
          itemCount: _myTasks.length,
          itemBuilder: ((context, index) {
            return Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Card(
                    elevation: 5,
                    child: Column(
                      children: [Text("${_myTasks[index]["task"]["title"]}")],
                    ),
                  )
                ],
              ),
            );
          })),
    ); */
    //筛选出@当前用户的
    if (_AllComments.isNotEmpty) {
      _messageList = _AllComments.where((v) =>
          v["comment"].contains("@" + widget.username + " ") == true ||
          v["comment"].contains("@" + widget.username) == true).toList();
      _messageList.sort(
          (a, b) => b["date_modification"].compareTo(a["date_modification"]));
    } else {
      _messageList = [];
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true, //标题居中
        title: const Text(
          "我的消息",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        elevation: 0.5, //阴影高度
      ),
      body: RefreshIndicator(
        color: Color.fromARGB(255, 0, 29, 72),
        onRefresh: () async {
          setState(() {
            _onRefresh();
          });
        },
        child: _buildMessage(_messageList),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onRefresh();
        },
        child: Icon(
          Icons.refresh,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildMessage(List messageList) {
    if (messageList.isEmpty) {
      return Container(
          child: const Center(
        child: Text(
          "暂无通知",
          style: TextStyle(
            fontSize: 18,
            color: Color.fromARGB(255, 0, 29, 72),
          ),
        ),
        /* child: CircularProgressIndicator(
            color: Color.fromARGB(255, 148, 196, 235)), */
      ));
    } else {
      _TaskDetails = []; //为了防止上面异步请求而更新其他的List而造成多次执行这里，所以这里要将_TaskDetails清空
      for (var i = 0; i < _messageList.length; i++) {
        for (var j = 0; j < _Alltasks.length; j++) {
          if (_messageList[i]["task_id"] == _Alltasks[j]["id"]) {
            _TaskDetails.add(_Alltasks[j]);
            break;
          }
        }
      }

      final _width = MediaQuery.of(context).size.width; //得到屏幕的宽
      return ListView.builder(
        itemCount: messageList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Card(
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //标签部分
                          Container(
                            margin: EdgeInsets.all(5),
                            height: 32,
                            decoration: BoxDecoration(
                                //标签的阴影部分
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 5.0,
                                      color: Colors.grey.withOpacity(1))
                                ],
                                color: Color.fromARGB(255, 0, 29, 72),
                                border: Border.all(
                                  color: Color.fromARGB(255, 0, 29, 72),
                                ),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(6))),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
                              child: Row(
                                children: [
                                  Text(
                                    "@ 我",
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(5),
                            // color: Colors.black,
                            child: Row(
                              children: [
                                TextButton(
                                  child: Text(
                                    "点击查看任务",
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 0, 29, 72)),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (_) => MyTaskDetailPage(
                                                  taskDetail:
                                                      _TaskDetails[index],
                                                  user_id: widget.user_id,
                                                  username: widget.username,
                                                )));
                                  },
                                ),
                                Container(
                                  child: Icon(
                                    Icons.navigate_next,
                                    color: Color.fromARGB(255, 0, 29, 72),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Container(
                          margin: EdgeInsets.fromLTRB(10, 0, 0, 10),
                          child: _TaskDetails.length != 0
                              ? Text("任务：${_TaskDetails[index]["title"]}",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey))
                              : Text("加载中...",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey))),
                      Container(
                          width: _width * 0.7,
                          margin: EdgeInsets.fromLTRB(10, 5, 0, 5),
                          child: messageList[index]["name"] == null ||
                                  messageList[index]["name"] == ""
                              ? Text(
                                  "${messageList[index]["username"]} 评论: ${messageList[index]["comment"]}",
                                  style: TextStyle(color: Colors.black),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                )
                              : Text(
                                  "${messageList[index]["name"]} 评论: ${messageList[index]["comment"]}",
                                  style: TextStyle(color: Colors.black),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                )),
                      Container(
                        margin: EdgeInsets.all(10),
                        child: Text(
                          "评论时间：${timeChange.timeStamp(messageList[index]["date_modification"])}",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      );
    }
  }
}

class Tasks {
  final String status;
  final String title; //标题
  final String desc;
  final String owner_name; //任务的主人
  final String owner_id;
  final String create_id; //创建项目的人
  final String date_started; //开始时间
  final String date_due; //结束时间
  final String column_id;
  final String task_id;
  final String project_id;
  Tasks(
      {required this.status,
      required this.title,
      required this.desc,
      required this.owner_name,
      required this.owner_id,
      required this.create_id,
      required this.date_started,
      required this.date_due,
      required this.column_id,
      required this.task_id,
      required this.project_id});
  @override
  String toString() {
    return "$title $status $owner_name $create_id";
  }
}
