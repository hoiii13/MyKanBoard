import 'package:board_app/pages/chatProject.dart';
import 'package:board_app/pages/tabs/MyCenter.dart';
import 'package:board_app/pages/tabs/MyMessage.dart';
import 'package:board_app/pages/tabs/MyTask.dart';
import 'package:board_app/pages/tabs/MyProject.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:board_app/component/requestNetwork.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:board_app/pages/Login.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Tabs extends StatefulWidget {
  final index;
  final username;
  final token;
  final name;
  final ipText;

  Tabs({
    Key? key,
    this.index = 0,
    this.username,
    this.token,
    this.name,
    required this.ipText,
  }) : super(key: key);

  @override
  State<Tabs> createState() => _TabsState(index);
}

class _TabsState extends State<Tabs> {
  Map _userInfo = {};
  String userInfo_id = "";
  RequestHttp httpCode = RequestHttp();
  final JPush jpush = JPush();

  _getMe() async {
    final response = await httpCode.requestHttpCode(
        json.encode({"jsonrpc": "2.0", "method": "getMe", "id": 1718627783}),
        widget.token,
        widget.ipText);
    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final userContent = json.decode(res);
      setState(() {
        _userInfo = userContent["result"];
        print("_userInfo = ${_userInfo["id"]}");
      });
      //userInfo_id = _userInfo["id"].toString();
    } else {
      print(response.reasonPhrase);
    }
  }

  /* _getUser(String username) async {
    final response = await httpCode.requestHttpCode(
        json.encode({
          "jsonrpc": "2.0",
          "method": "getUserByName",
          "id": 1769674782,
          "params": {"username": username}
        }),
        "anNvbnJwYzpiMDNhMWRlODcxNmE5YTc2MDc0MTc2MjEyNTc0OTc2MjM2YWI1YjczOThkMmU3NGJmYzM5MmRhYjZkZGM=",
        widget.ipText);

    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final userContent = json.decode(res);
      setState(() {
        _userInfo = userContent["result"];
        print("_userInfo = ${_userInfo["id"]}");
      });
      userInfo_id = _userInfo["id"];
    } else {
      print(response.reasonPhrase);
    }
  } */

  int _currentIndex = 0;

  _TabsState(index) {
    //初始化_currentIndex
    _currentIndex = index;
  }
  //删除存储下来的token（退出登陆）
  deleteData(String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final result = await prefs.remove(password);
    if (result) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => LoginPage(
                    ipText: widget.ipText,
                  )),
          (route) => false);
    }
    print("delete = $result");
  }

  @override
  void initState() {
    print("token = ${widget.token}");
    if (widget.token != null) {
      Future.delayed(Duration(days: 3), () {
        deleteData("password");
        print("我执行了");
      });
    } else {
      print("没有token");
    }

    _getMe();
    /* String? name = widget.username;
    if (name != null) {
      _getUser(name);
      //initJpush(name);
    } */

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height; //得到屏幕的宽高
    final List _pageList = [
      //页面集合
      MyTaskPage(
        user_id: _userInfo["id"],
        username: _userInfo["username"],
        ipText: widget.ipText,
        token: widget.token,
      ), //我的任务
      MyMessagePage(
        user_id: _userInfo["id"],
        username: _userInfo["username"],
        name: _userInfo["name"],
        ipText: widget.ipText,
        token: widget.token,
      ), //我的消息
      ProjectAboutpage(
        username: widget.username,
        token: widget.token,
        user_id: _userInfo["id"],
        ipText: widget.ipText,
      ), //项目
      MyCenterPage(
        username: widget.username,
        userToken: widget.token,
        user_id: _userInfo["id"],
        name: _userInfo["name"],
        ipText: widget.ipText,
      ) //个人中心
    ];
    return Scaffold(
      body: _pageList[
          _currentIndex], //因为在开始之前我们默认设定的是index=0,而我们的_currentIndex=index，所以
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          //因为点击每个按钮会返回所按的序号是哪个，然后根据_pageList[_currentIndex]来转换页面
          setState(() {
            _currentIndex = index;
          });
        },
        iconSize: 28.0, //每个导航按钮的大小
        fixedColor: Color.fromARGB(255, 0, 29, 72),
        type: BottomNavigationBarType.fixed, //type是按钮的显示类型，这样写才可以让按钮超过3个
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.pending_actions), label: "任务"),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: "消息"),
          BottomNavigationBarItem(
              icon: Icon(Icons.fact_check_rounded), label: "项目"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "我"),
        ],
      ),
    );
  }
}
