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
  final ipText;
  final token;
  MyMessagePage(
      {Key? key,
      this.user_id,
      this.username,
      this.name,
      required this.ipText,
      required this.token})
      : super(key: key);

  @override
  State<MyMessagePage> createState() => _MyMessagePageState();
}

class _MyMessagePageState extends State<MyMessagePage> {
  RequestHttp httpCode = RequestHttp();
  TimeChange timeChange = TimeChange();
  final JPush jpush = JPush();
  ScrollController _scrollController = ScrollController();

  List _messageList = [];
  List _TaskDetails = [];
  List _tasksList = [];
  List _isClicks = [false];
  //bool _isClick = false;

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
            {"jsonrpc": "2.0", "method": "getmyProjects", "id": 2134420212}),
        widget.token,
        widget.ipText);
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
        _getData(int.parse(Allprojects[i]["id"]));
      }
    });
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
        widget.token,
        widget.ipText);

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
        widget.token,
        widget.ipText);
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
    if (_AllComments.isNotEmpty) {
      //过滤出@用户的评论
      _messageList = _AllComments.where((v) =>
          v["comment"].contains("@" + widget.username + " ") == true ||
          v["comment"].contains("@" + widget.username) == true).toList();
      _messageList.sort(
          (a, b) => b["date_modification"].compareTo(a["date_modification"]));
      //整合所有评论中的任务是哪些
      _tasksList = [];
      if (_messageList.isNotEmpty) {
        _tasksList.add(_messageList[0]);
      }

      for (var i = 0; i < _messageList.length; i++) {
        if (_tasksList.length != 0) {
          int len = _tasksList.length;
          int num = 0;
          for (var j = 0; j < len; j++) {
            if (_tasksList[j]["task_id"] != _messageList[i]["task_id"]) {
              num++;
            }
          }
          if (num == len) {
            _tasksList.add(_messageList[i]);
            _isClicks.add(false);
          }
        }
      }
      //根据整理出的任务，得到相应任务的详情
      _TaskDetails = [];
      for (var i = 0; i < _tasksList.length; i++) {
        for (var j = 0; j < _Alltasks.length; j++) {
          if (_tasksList[i]["task_id"] == _Alltasks[j]["id"]) {
            _TaskDetails.add(_Alltasks[j]);
          }
        }
      }
    } else {
      _messageList = [];
      _tasksList = [];
    }
    final _width = MediaQuery.of(context).size.width; //得到屏幕的宽高
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, //标题居中
        title: const Text(
          "我的消息",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        elevation: 0.5, //阴影高度
      ),
      backgroundColor: Colors.grey[200],
      body: RefreshIndicator(
        color: Color.fromARGB(255, 0, 29, 72),
        onRefresh: () async {
          setState(() {
            _onRefresh();
          });
        },
        child: _buildTasksList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _scrollController.animateTo(.0,
              duration: Duration(seconds: 2), curve: Curves.ease);
        },
        child: Icon(Icons.arrow_upward, color: Colors.white),
      ),
    );
  }

  //任务列表
  _buildTasksList() {
    if (_tasksList.isEmpty) {
      return Container(
          child: const Center(
        child: Text(
          "暂无通知",
          style: TextStyle(
            fontSize: 18,
            color: Color.fromARGB(255, 0, 29, 72),
          ),
        ),
      ));
    } else {
      return Scrollbar(
        child: ListView.builder(
            controller: _scrollController,
            itemCount: _tasksList.length,
            itemBuilder: ((context, index) {
              return Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Card(
                      elevation: 5,
                      child: Column(
                        children: [
                          Container(
                            //color: Color.fromARGB(255, 0, 29, 72),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 5.0, color: Colors.white)
                                ],
                                color: Color.fromARGB(255, 0, 29, 72),
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(4))
                                //BorderRadius.all(Radius.circular(0,0,10,20))
                                ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    margin: EdgeInsets.fromLTRB(10, 5, 0, 0),
                                    child: _isClicks[index]
                                        ? Text(
                                            "${_TaskDetails[index]["title"]}",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey),
                                          )
                                        : Text(
                                            "${_TaskDetails[index]["title"]}",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white),
                                          )),
                                IconButton(
                                  onPressed: () {
                                    setState(
                                      () {
                                        _isClicks[index] = !_isClicks[index];
                                      },
                                    );
                                  },
                                  icon: _isClicks[index]
                                      ? Icon(
                                          Icons.expand_more,
                                          color: Colors.grey,
                                        )
                                      : Icon(
                                          Icons.chevron_right,
                                          color: Colors.white,
                                        ),
                                )
                              ],
                            ),
                          ),
                          _buildLastComment(
                              _isClicks[index],
                              _tasksList[index]["task_id"],
                              _TaskDetails[index]["title"],
                              _TaskDetails[index]["project_id"]),
                          //Container(child: Text("aaa")),
                          _buildCommentList(
                              _tasksList[index]["task_id"],
                              _isClicks[index],
                              _TaskDetails[index]["title"],
                              _TaskDetails[index]["project_id"])
                        ],
                      ),
                    )
                  ],
                ),
              );
            })),
      );
    }
  }

//最新一条@
  _buildLastComment(
      bool _isClick, String task_id, String title, String project_id) {
    final taskComments =
        _messageList.where((v) => v["task_id"] == task_id).toList();
    return Visibility(
        visible: !_isClick,
        child: _commentView(taskComments, 0, title, project_id, _isClick));
  }

//@详情
  _commentView(final taskComment, int index, String title, String project_id,
      bool _isClick) {
    return Column(
      children: [
        Visibility(
          visible: _isClick,
          child: Divider(color: Color.fromARGB(255, 0, 29, 72)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Visibility(
                  visible: !_isClick,
                  child: Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.fromLTRB(10, 15, 5, 0),
                      child: Text(
                        "最新消息：",
                        style: TextStyle(fontSize: 16),
                      )),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.fromLTRB(10, 15, 5, 0),
                  child: taskComment[index]["name"] == "" ||
                          taskComment[index]["name"] == null
                      ? Text(
                          "${taskComment[index]["username"]}",
                          style: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 191, 64, 100)),
                        )
                      : Text(
                          "${taskComment[index]["name"]}",
                          style: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 191, 64, 100)),
                        ),
                ),
                Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.fromLTRB(0, 15, 5, 0),
                    child: Text(
                      "@了你",
                      style: TextStyle(fontSize: 16),
                    )),
              ],
            ),
            Visibility(
              visible: _isClick,
              child: Container(
                alignment: Alignment.topRight,
                child: IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ChatProjectPage(
                                task_id: taskComment[index]["task_id"],
                                user_id: widget.user_id.toString(),
                                task_title: title,
                                project_id: project_id,
                                username: widget.username,
                                ipText: widget.ipText,
                                token: widget.token,
                              )));
                    },
                    icon: Icon(Icons.chevron_right)),
              ),
            )
          ],
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: ListTile(
            title: Text(
              "${taskComment[index]["comment"]}",
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
            subtitle: Text(
              "${timeChange.timeStamp(
                taskComment[index]["date_modification"],
              )}",
              style: TextStyle(fontSize: 13),
            ),
          ),
        )
      ],
    );
  }

//每个任务下的@列表
  _buildCommentList(
      String task_id, bool _isClick, String title, String project_id) {
    final taskComments =
        _messageList.where((v) => v["task_id"] == task_id).toList();
    int len = taskComments.length;
    if (taskComments.length > 10) {
      len = 10;
    }

    return Visibility(
        visible: _isClick,
        child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: len,
            itemBuilder: ((context, index) {
              return _commentView(
                  taskComments, index, title, project_id, _isClick);
            })));
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
