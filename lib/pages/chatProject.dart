import 'dart:async';

import 'package:board_app/component/timeChange.dart';
import 'package:board_app/pages/MyTaskDetail.dart';
import 'package:board_app/pages/tabs/MyMessage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:board_app/component/requestNetwork.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

//评论详情页
class ChatProjectPage extends StatefulWidget {
  final task_id;
  final user_id;
  final task_title;
  final project_id;
  final username;
  ChatProjectPage(
      {Key? key,
      required this.task_id,
      required this.user_id,
      required this.task_title,
      required this.project_id,
      this.username})
      : super(key: key);

  @override
  State<ChatProjectPage> createState() => _ChatProjectPageState();
}

class _ChatProjectPageState extends State<ChatProjectPage> {
  final _textController = TextEditingController(); //输入框内容监听
  ScrollController _msgController = new ScrollController();
  StreamController<List> _streamController = StreamController();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  RequestHttp httpCode = RequestHttp();
  final JPush jpush = JPush();

  List AllComments = [];
  List sendComment = [];

  List aliasList = [];
  //根据任务得到这个任务的所有评论记录
  Future<List> _getComments(int task_id) async {
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
      if (mounted) {
        setState(() {
          AllComments = comments["result"];
        });
      }
    } else {
      print(response.reasonPhrase);
    }
    return AllComments;
  }

//添加评论
  Future<int> _sendComment(int task_id, int user_id, String content) async {
    int? text_id;
    final response = await httpCode.requestHttpCode(
        json.encode({
          "jsonrpc": "2.0",
          "method": "createComment",
          "id": 1580417921,
          "params": {
            "task_id": task_id,
            "user_id": user_id,
            "content": content,
          }
        }),
        "anNvbnJwYzpiMDNhMWRlODcxNmE5YTc2MDc0MTc2MjEyNTc0OTc2MjM2YWI1YjczOThkMmU3NGJmYzM5MmRhYjZkZGM=");

    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final sendText = json.decode(res);
      if (mounted) {
        setState(() {
          text_id = sendText["result"];
        });
      }
    } else {
      print(response.reasonPhrase);
    }
    return text_id!;
  }

//得到将新添加的评论的id然后添加到评论的List中
  _getSendText(int commtent_id) async {
    final response = await httpCode.requestHttpCode(
        json.encode({
          "jsonrpc": "2.0",
          "method": "getComment",
          "id": 867839500,
          "params": {"comment_id": commtent_id}
        }),
        "anNvbnJwYzpiMDNhMWRlODcxNmE5YTc2MDc0MTc2MjEyNTc0OTc2MjM2YWI1YjczOThkMmU3NGJmYzM5MmRhYjZkZGM=");

    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final newComment = json.decode(res);

//为了实现在通知得到当@我的消息
      /* if (newComment["result"]["comment"].contains('@' + widget.username)) {
        showNotification(widget.project_title, newComment["result"]["comment"]);
      } */
      if (mounted) {
        setState(() {
          AllComments.add(newComment["result"]);
          print("All = ${AllComments}");
        });
      }
    } else {
      print(response.reasonPhrase);
    }
  }

//得到项目成员的id
  Future<List> _getProjectUsers(String project_id) async {
    Map _allProjectUsers = {};
    List users = [];
    List AllUsers = [];
    final response = await httpCode.requestHttpCode(
        json.encode({
          "jsonrpc": "2.0",
          "method": "getProjectUsers",
          "id": 1601016721,
          "params": [project_id]
        }),
        "anNvbnJwYzpiMDNhMWRlODcxNmE5YTc2MDc0MTc2MjEyNTc0OTc2MjM2YWI1YjczOThkMmU3NGJmYzM5MmRhYjZkZGM=");

    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final allProjectUsers = json.decode(res);
      if (mounted) {
        setState(() {
          _allProjectUsers = allProjectUsers["result"];
          _allProjectUsers.forEach((key, value) {
            //因为_allProjectUsers是Map类型
            users.add(key);
            /*  print("value = ${key}");
          Map a = await _getUsers(int.parse(key));
          AllUsers.add(a);

          print("AllUSers = ${AllUsers}"); */
          });
        });
      }
    } else {
      print(response.reasonPhrase);
    }

    return users;
  }

//根据user_id得到用户的信息
  Future<Map> _getUsers(int user_id) async {
    Map _user = {};
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
      final users = json.decode(res);
      if (mounted) {
        setState(() {
          _user = users["result"];
        });
      }
    } else {
      print(response.reasonPhrase);
    }
    return _user;
  }

  List commentsAll = [];
  late Timer _timer;

  _getTaskDetail(int task_id) async {
    Map _taskDetail = {};
    var headers = {
      'Authorization':
          'Basic anNvbnJwYzpiMDNhMWRlODcxNmE5YTc2MDc0MTc2MjEyNTc0OTc2MjM2YWI1YjczOThkMmU3NGJmYzM5MmRhYjZkZGM=',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST', Uri.parse('http://43.154.142.249:18868/jsonrpc.php'));
    request.body = json.encode({
      "jsonrpc": "2.0",
      "method": "getTask",
      "id": 700738119,
      "params": {"task_id": task_id}
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final taskDetail = json.decode(res);
      _taskDetail = taskDetail["result"];
      //print("test = ${_taskDetail}");
    } else {
      print(response.reasonPhrase);
    }
    return _taskDetail;
  }

//极光推送
  void _pushMessage(List alias, String alertContent, String task_title,
      String task_id, String project_id) async {
    var headers = {
      'Authorization':
          'Basic ZTM2MzE1YThiNjE1NzJmNzA5NzhkODZiOmFhYmIwZjNkNmYyZDQwMTcxM2U1OTNmZA==',
      'Content-Type': 'application/json'
    };
    var request =
        http.Request('POST', Uri.parse('https://api.jpush.cn/v3/push'));
    request.body = json.encode({
      "platform": "all",
      "audience": {"alias": alias},
      "notification": {
        "android": {
          "alert": alertContent,
          "title": task_title,
          "builder_id": 1,
          "large_icon": "http://www.jiguang.cn/largeIcon.jpg",
          "extras": {
            "task_id": task_id,
            "project_id": project_id,
            "sendPeople": widget.username
          }
        }
      },
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

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
    //注册registerID
    /* jpush.getRegistrationID().then((rid) {
      print("获得注册的id: $rid");
    }); */

    jpush.setup(
        appKey: "e36315a8b61572f70978d86b",
        channel: "thisChannel",
        production: false,
        debug: true);

    try {
      jpush.addEventHandler(
          onReceiveNotification: (Map<String, dynamic> message) async {
        print("flutter onReceiveNotification: $message");
      }, onOpenNotification: (Map<String, dynamic> message) async {
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
    _getComments(int.parse(widget.task_id));
    Future.delayed(Duration(seconds: 1), () {
      initJpush(widget.username);
    });
    /* if (AllComments.length != 0) {
      _jumpBottom();
    } */

    _timer = Timer.periodic(Duration(milliseconds: 1000), (timer) async {
      List commentList = await _getComments(int.parse(widget.task_id));
      commentsAll = commentList;

      _streamController.add(commentList);
      _streamController.addError("error信息");
    });

    var andriod = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = IOSInitializationSettings();
    var initSettings = InitializationSettings(android: andriod, iOS: iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: onSelectNotification);

    super.initState();
  }

  bool _isDisposed = false;
  @override
  void dispose() {
    _streamController.close();
    _isDisposed = true;
    _timer.cancel();
    super.dispose();
  }

  Future onSelectNotification(String? payload) async {
    debugPrint("payload: $payload");
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => MyMessagePage(
              user_id: widget.user_id,
              username: widget.username,
            )));
  }

  showNotification(String title, String content) async {
    var andriod = AndroidNotificationDetails('channelId', 'channelName');
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android: andriod, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch >> 10, title, content, platform,
        payload: '通知栏');
  }

  //打开聊天页面显示最新的记录
  void _jumpBottom() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _msgController.animateTo(
        _msgController.position.maxScrollExtent + 300,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        centerTitle: true,
        title: Text(
          widget.task_title,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.navigate_before,
            color: Colors.grey,
            size: 35,
          ),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
      ),
      body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            //点击其他地方，让输入框失去焦点
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SafeArea(
            child: Column(
              children: [
                chatView(AllComments, widget.user_id),
                //buildChatStream(),
                inputView(),
              ],
            ),
          )),
    );
  }

  Widget chatView(List comments, String user_id) {
    if (comments.isEmpty) {
      return const Expanded(
          child: Center(
        child: Text("暂时没有对话"),
      ));
    } else {
      //_jumpBottom();
      int len = comments.length - 1;
      return Expanded(
        child: ListView.builder(
            reverse: true, //先翻转再倒着输出，这样是为了在我们打开评论页面的时候页面是处于最底部
            controller: _msgController,
            itemCount: comments.length,
            itemBuilder: (context, index) {
              return BubbleWidget(
                //avatar: comments[index]["avatar_path"] == "" ? name : ,
                text: comments[len - index]["comment"],
                isMyself:
                    comments[len - index]["user_id"] == user_id ? true : false,
                name: comments[len - index]["name"] == null ||
                        comments[len - index]["name"] == ""
                    ? comments[len - index]["username"]
                    : comments[len - index]["name"],
                time: comments[len - index]["date_creation"],
              );
            }),
      );
    }
  }

/* //评论内容
  StreamBuilder<List> buildChatStream() {
    return StreamBuilder(
        stream: _streamController.stream,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          //return Text("${snapshot.data}");
          if (snapshot.data == null) {
            return const Expanded(
              child: Center(
                  child: CircularProgressIndicator(
                color: Colors.red,
              )),
            );
          } else {
            final ChatContents = snapshot.data;
            //int len = ChatContents.length - 1;
            print("LiaoTian = ${ChatContents}");
            return Expanded(
              child: ListView.builder(
                  reverse: true, //先翻转再倒着输出，这样是为了在我们打开评论页面的时候页面是处于最底部
                  controller: _msgController,
                  itemCount: ChatContents.length,
                  itemBuilder: (context, index) {
                    return BubbleWidget(
                      //avatar: comments[index]["avatar_path"] == "" ? name : ,
                      text: ChatContents[ChatContents.length - 1 - index]["comment"],
                      isMyself:
                          ChatContents[ChatContents.length - 1 - index]["user_id"] == widget.user_id
                              ? true
                              : false,
                      name: ChatContents[ChatContents.length - 1 - index]["name"] == null ||
                              ChatContents[ChatContents.length - 1 - index]["name"] == ""
                          ? ChatContents[ChatContents.length - 1 - index]["username"]
                          : ChatContents[ChatContents.length - 1 - index]["name"],
                      time: ChatContents[ChatContents.length - 1 - index]["date_creation"],
                    );
                  }),
            );
          }

          //return chatView(snapshot.data, widget.user_id);
        });
  }
 */
//输入框
  Widget inputView() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200.0, minHeight: 65), //限制高度
      color: Colors.grey[300],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 5, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
                child: Container(
              constraints: const BoxConstraints(maxHeight: 150.0),
              child: TextField(
                maxLines: null,
                style: const TextStyle(fontSize: 14),
                keyboardType: TextInputType.multiline,
                cursorColor: Colors.black,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  hintText: "请输入",
                  contentPadding: EdgeInsets.fromLTRB(5, 8, 5, 8),
                ),
                controller: _textController,
              ),
            )),
            TextButton(
              onPressed: () async {
                List projectUserName =
                    await _getProjectUsers(widget.project_id);
                _showChoicePeople(projectUserName);
                print("project = ${projectUserName}");
              },
              child: const Text(
                "@",
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
              style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size(5, 5))),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = _textController.text;
                if (text.isNotEmpty) {
                  int getComment_id = await _sendComment(
                      int.parse(widget.task_id),
                      int.parse(widget.user_id),
                      text);
                  if (getComment_id != null) {
                    _getSendText(getComment_id);
                  }
                  _textController.clear(); //清空输入框的内容
                  //_jumpBottom();
                }
                _pushMessage(aliasList, text, widget.task_title, widget.task_id,
                    widget.project_id);
              },
              child: const Text(
                "发送",
                style: TextStyle(color: Colors.red),
              ),
            )
          ],
        ),
      ),
    );
  }

  //@人的时候的底部弹窗
  Future<void> _showChoicePeople(List people) async {
    final _width = MediaQuery.of(context).size.width; //得到屏幕的宽
    List _people = [];
    for (var i = 0; i < people.length; i++) {
      final _user = await _getUsers(int.parse(people[i]));
      _people.add(_user);
    }

    if (_people.length <= 0) {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 250,
              child: const Center(
                  child: CircularProgressIndicator(
                color: Colors.red,
              )),
            );
          });
    } else {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 250,
              child: ListView.builder(
                  itemCount: _people.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        ListTile(
                          contentPadding:
                              EdgeInsets.fromLTRB(20, 0, _width * 0.2, 0),
                          leading: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: _people[index]["name"] == null ||
                                    _people[index]["name"] == ""
                                ? Text(
                                    _people[index]["username"]
                                        .toString()
                                        .substring(0, 1), //取名字的前1个字
                                    style: const TextStyle(color: Colors.white),
                                  )
                                : Text(
                                    _people[index]["name"]
                                        .toString()
                                        .substring(0, 1), //取名字的前1个字
                                    style: const TextStyle(color: Colors.white),
                                  ),
                          ),
                          title: Text("${_people[index]["username"]}"),
                          trailing: _people[index]["name"] == null ||
                                  _people[index]["name"] == ""
                              ? Text(" ")
                              : Text(
                                  _people[index]["name"],
                                  style: const TextStyle(color: Colors.grey),
                                ),
                          onTap: () {
                            aliasList.add(_people[index]["username"]);
                            _textController.text =
                                "${_textController.text + "@" + _people[index]["username"]} ";
                            Navigator.of(context).pop(_people[index]);
                          },
                        ),
                        const Divider()
                      ],
                    );
                  }),
            );
          });
    }
  }
}

//聊天气泡处
class BubbleWidget extends StatelessWidget {
  const BubbleWidget(
      {Key? key,
      //required this.avatar,
      required this.text,
      required this.isMyself,
      required this.name,
      required this.time})
      : super(key: key);
  //final String avatar;
  final String text;
  final String name;
  final bool isMyself; //聊天界面的方向
  final String time;

  @override
  Widget build(BuildContext context) {
    TimeChange timeChange = TimeChange();
    final _width = MediaQuery.of(context).size.width; //得到屏幕的宽
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: isMyself ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Container(
            child: CircleAvatar(
              //头像部分
              child: Text(
                "${name.toString().substring(0, 1)}", //取名字的前2个字
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
            /* child: CircleAvatar(
              backgroundImage: NetworkImage(avatar),
            ), */
          ),
          const SizedBox(width: 8.0),
          Column(
            crossAxisAlignment: isMyself
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start, //根据是否是用户本人来判断布局的方向
            children: [
              Container(
                alignment: isMyself
                    ? AlignmentDirectional.topEnd
                    : AlignmentDirectional.topStart,
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ), //用户名部分
                //color: Colors.blue,
              ),
              const SizedBox(height: 5.0),
              Container(
                constraints: BoxConstraints(maxWidth: _width * 0.7), //气泡的最大宽度
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 238, 238, 238),
                    style: BorderStyle.solid,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.grey[200],
                ),
                child: Text(text),
              ),
              Container(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  "${timeChange.timeStamp(time)}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
