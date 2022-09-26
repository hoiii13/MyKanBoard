/* import 'package:flutter/services.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:flutter/material.dart';

class TestPushPage extends StatefulWidget {
  const TestPushPage({super.key});

  @override
  State<TestPushPage> createState() => _TestPushPageState();
}

class _TestPushPageState extends State<TestPushPage> {
  String debugLable = "Unknown";
  final JPush jpush = new JPush();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String? platformVersion;

    try {
      jpush.addEventHandler(
          onReceiveNotification: (Map<String, dynamic> message) async {
        print(">>>>>>flutter 接收到推送: $message");
        setState(() {
          debugLable = "接收到推送: $message";
        });
      });
    } on PlatformException {
      platformVersion = "平台版本获取失败，请检查！";
    }
    if (!mounted) {
      return;
    }

    setState(() {
      debugLable = platformVersion!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("极光推送"),
      ),
      body: Center(
        child: Column(
          children: [
            Text("结果： $debugLable\n"),
            ElevatedButton(
                onPressed: () {
                  var fireDate = DateTime.fromMicrosecondsSinceEpoch(
                      DateTime.now().millisecondsSinceEpoch + 3000);
                  var localNotification = LocalNotification(
                      id: 123,
                      title: "test",
                      content: "12345678",
                      fireTime: fireDate,
                      subtitle: '一个测试');
                  jpush.sendLocalNotification(localNotification).then((res) {
                    setState(() {
                      debugLable = res;
                    });
                  });
                },
                child: Text("点击发送推送消息\n"))
          ],
        ),
      ),
    );
  }
}
 */