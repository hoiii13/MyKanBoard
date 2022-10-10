import 'package:board_app/pages/Login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../component/toastPosition.dart';

class WriteIPPage extends StatefulWidget {
  const WriteIPPage({super.key});

  @override
  State<WriteIPPage> createState() => _WriteIPPageState();
}

class _WriteIPPageState extends State<WriteIPPage> {
  final _IPController = TextEditingController();
  saveIP(String ip) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool address = await prefs.setString('ipAddress', ip);
    print("address = $address");
  }

  readIP(String ip) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final ipKey = await prefs.getString(ip);
    if (ipKey != null) {
      //final loginMess = await _loginVerify(passwordKey);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => LoginPage(ipText: ipKey)),
          (route) => false);
    }
    print("ipKeyWrite = ${ipKey}");
    //return passwordKey;
  }

  void initState() {
    readIP("ipAddress");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width; //得到屏幕的宽高
    return Scaffold(
        appBar: AppBar(
          title: Text("IP地址"),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  width: _width * 0.9,
                  margin: EdgeInsets.fromLTRB(0, 130, 0, 0),
                  child: TextField(
                    controller: _IPController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 0, 29, 72),
                                width: 3,
                                style: BorderStyle.solid)),
                        hintText: "请先填写要访问的IP地址"),
                  ),
                ),
                Container(
                  width: _width * 0.9,
                  height: 50,
                  margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child: ElevatedButton(
                      onPressed: () {
                        String _ip = _IPController.text;
                        if (_ip.isEmpty) {
                          ToastPosition.toast(context, "请填写IP地址");
                        } else {
                          saveIP(_ip);
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      LoginPage(ipText: _ip)),
                              (route) => false);
                          ToastPosition.toast(context, "进入指定IP，请登录");
                        }

                        /* Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) => Tabs(
                                          username: _usernameController.text,
                                          token: textUser)),
                                  (route) => false); */
                      },
                      child: Text("确定")),
                )
              ],
            ),
          ),
        ));
  }
}
