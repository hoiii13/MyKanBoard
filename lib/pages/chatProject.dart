import 'dart:async';

import 'package:board_app/pages/MyTaskDetail.dart';
import 'package:board_app/pages/tabs/MyMessage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:board_app/component/requestNetwork.dart';

//评论详情页
class ChatProjectPage extends StatefulWidget {
  final task_id;
  final user_id;
  final project_title;
  final project_id;
  final username;
  ChatProjectPage(
      {Key? key,
      required this.task_id,
      required this.user_id,
      required this.project_title,
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

  List AllComments = [];

  List sendComment = [];
  //根据任务得到这个任务的所有评论记录
  Future<List> _getComments(int task_id) async {
    final response = await httpCode.requestHttpCode(json.encode({
      "jsonrpc": "2.0",
      "method": "getAllComments",
      "id": 148484683,
      "params": {"task_id": task_id}
    }));

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
    final response = await httpCode.requestHttpCode(json.encode({
      "jsonrpc": "2.0",
      "method": "createComment",
      "id": 1580417921,
      "params": {
        "task_id": task_id,
        "user_id": user_id,
        "content": content,
      }
    }));

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
    final response = await httpCode.requestHttpCode(json.encode({
      "jsonrpc": "2.0",
      "method": "getComment",
      "id": 867839500,
      "params": {"comment_id": commtent_id}
    }));

    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final newComment = json.decode(res);

//为了实现在通知得到当@我的消息
      if (newComment["result"]["comment"].contains('@' + widget.username)) {
        showNotification(widget.project_title, newComment["result"]["comment"]);
      }
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
    final response = await httpCode.requestHttpCode(json.encode({
      "jsonrpc": "2.0",
      "method": "getProjectUsers",
      "id": 1601016721,
      "params": [project_id]
    }));

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
    final response = await httpCode.requestHttpCode(json.encode({
      "jsonrpc": "2.0",
      "method": "getUser",
      "id": 1769674781,
      "params": {"user_id": user_id}
    }));

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
  @override
  void initState() {
    _getComments(int.parse(widget.task_id));
    /* if (AllComments.length != 0) {
      _jumpBottom();
    } */

    _timer = Timer.periodic(Duration(milliseconds: 1000), (timer) async {
      //print("All  ==== ${AllComments[AllComments.length - 1]}");
      List commentList = await _getComments(int.parse(widget.task_id));
      commentsAll = commentList;

      _streamController.add(commentList);
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
          widget.project_title,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.navigate_before,
            color: Colors.grey,
            size: 35,
          ),
          onPressed: () {
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
                buildChatStream(),
                inputView(),
              ],
            ),
          )),
    );
  }
//评论内容
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
            int len = ChatContents.length - 1;
            //print("LiaoTian = ${LiaoTian[0]}");
            return Expanded(
              child: ListView.builder(
                  reverse: true, //先翻转再倒着输出，这样是为了在我们打开评论页面的时候页面是处于最底部
                  controller: _msgController,
                  itemCount: ChatContents.length,
                  itemBuilder: (context, index) {
                    return BubbleWidget(
                      //avatar: comments[index]["avatar_path"] == "" ? name : ,
                      text: ChatContents[len - index]["comment"],
                      isMyself:
                          ChatContents[len - index]["user_id"] == widget.user_id
                              ? true
                              : false,
                      name: ChatContents[len - index]["name"] == null ||
                              ChatContents[len - index]["name"] == ""
                          ? ChatContents[len - index]["username"]
                          : ChatContents[len - index]["name"],
                      time: ChatContents[len - index]["date_creation"],
                    );
                  }),
            );
          }

          //return chatView(snapshot.data, widget.user_id);
        });
  }



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
                  "${DateTime.fromMillisecondsSinceEpoch(int.parse(time) * 1000).toString().substring(0, 16)}",
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
