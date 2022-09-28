import 'package:flutter/material.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

//评论详情页
class Test2Page extends StatefulWidget {
  Test2Page({Key? key}) : super(key: key);

  @override
  State<Test2Page> createState() => _Test2PageState();
}

class _Test2PageState extends State<Test2Page> {
  final JPush jpush = JPush();
  @override
  void initState() {
    super.initState();
    initJpush();
  }

  Future initJpush() async {
    jpush.applyPushAuthority(
        new NotificationSettingsIOS(sound: true, alert: true, badge: true));
    jpush.getRegistrationID().then((rid) {
      print("获得注册的id: $rid");
    });

    jpush.setup(
        appKey: "e36315a8b61572f70978d86b",
        channel: "thisChannel",
        production: false,
        debug: true);
    jpush.setAlias("supperman").then((map) {
      print("设置别名成功");
    });

    try {
      jpush.addEventHandler(
          onReceiveNotification: (Map<String, dynamic> message) async {
        print("flutter onReceiveNotification: $message");
      }, onOpenNotification: (Map<String, dynamic> message) async {
        print("flutter onOpenNotification: $message");
      }, onReceiveMessage: (Map<String, dynamic> message) async {
        print("flutter onReceiveMessage: $message");
      });
    } catch (e) {
      print("极光sdk配置异常");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("极光推送")),
      body: Container(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  var fireDate = DateTime.fromMicrosecondsSinceEpoch(
                      DateTime.now().microsecondsSinceEpoch + 2000);
                  var localNotification = LocalNotification(
                      id: 2,
                      title: "验证码",
                      content: "验证码，仅用于密码修改",
                      buildId: 1,
                      fireTime: fireDate,
                      subtitle: "验证码",
                      badge: 5,
                      extra: {"": ""});
                  jpush.sendLocalNotification(localNotification).then((value) {
                    print(value);
                  });
                },
                child: Text("推送消息"))
          ],
        ),
      ),
    );
  }
}
