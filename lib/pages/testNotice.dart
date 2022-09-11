import 'package:board_app/pages/MyTaskDetail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NoticePage extends StatefulWidget {
  NoticePage({Key? key}) : super(key: key);

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android: android, iOS: iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String? payload) async {
    debugPrint("payload: $payload");
    /*  Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => MyTaskDetailPage(taskDetail: a, user_id: 2))); */
    Navigator.pushNamed(context, '/');
    /* showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: Text('Notification'),
              content: Text('$payload'),
            )); */
  }

/* Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => MyTaskDetailPage(
                            taskDetail: toDos[index],
                            user_id: widget.user_id,
                          )) */
  /* Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = 
    
  } */
  /* decoration: BoxDecoration(
            color: Colors.grey[200],
            //弄一个框出来
            border: Border.all(
              color: Color.fromARGB(255, 238, 238, 238),
              style: BorderStyle.solid,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(5.0))); */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Flutter Local Notification'),
        ),
        body: Stack(
          children: <Widget>[
            Column(
              children: [
                ElevatedButton(
                  child: Text(
                    'Demo',
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  onPressed: showNotification,
                ),
                ElevatedButton(
                  child: Text(
                    '顶部',
                  ),
                  onPressed: () {
                    showTopMessage();
                  },
                ),
              ],
            ),
            Positioned(
                top: -10,
                child: Center(
                  child: Container(
                    height: 100,
                    width: 300,
                    child: Text("123456"),
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(
                            color: Color.fromARGB(255, 238, 238, 238),
                            style: BorderStyle.solid,
                            width: 2.0),
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                )),
          ],
        ));
  }

  showMessage() {}

  showNotification() async {
    var andriod = const AndroidNotificationDetails('chat', '聊天消息');
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android: andriod, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(0, '实验一', '这是一个test', platform,
        payload: 'Nitish Kumar Singh is part time Youtuber');
  }

  showTopMessage() {
    return showDialog(
        context: context,
        builder: (context) {
          return Container(
              alignment: AlignmentDirectional.topCenter,
              height: 150,
              child: const AlertDialog(
                contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                title: Text("实验一"),
                content: Text("@yds 完成得好吗"),
              ));
        });
  }
}
