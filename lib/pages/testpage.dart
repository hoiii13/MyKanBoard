import 'package:board_app/routes/Routes.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart';

class TestPage extends StatefulWidget {
  const TestPage({ Key? key }) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  void test() async {
    String basicAuth = base64Encode(utf8.encode("yds:123456"));
    Response r = await get(Uri.parse('http://43.154.142.249:18868/jsonrpc.php'),headers: <String, String>{'authorization': basicAuth});
    print("111 = ${r.statusCode}");
    print("222 = ${r.body}");
  }
  @override
  void initState() {
    //test();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("test"),),
      body: Center(
        child: ElevatedButton(onPressed: () {EolToast.toast(context, "str");}, child: Text("点击")),
      ),
    ); 
  }
}

class EolToast {
  static OverlayEntry? overlayEntry;

  static final EolToast _showToast = EolToast._internal();
  factory EolToast() {
    return _showToast;
  }
  EolToast._internal();

  static toast(context, String str) {
    if (overlayEntry != null) return;
    overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        top: MediaQuery.of(context).size.height * 0.7,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/4),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              constraints: BoxConstraints(
                minHeight: 50,
              ),
              child: Center(
                child: Text(
                  str,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      );
    });
    var overlayState = Overlay.of(context);
    overlayState?.insert(overlayEntry!);
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry!.remove();
      overlayEntry = null;
    });
  }
}
