import 'package:board_app/pages/Login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../component/toastPosition.dart';

class ChangeIPPage extends StatefulWidget {
  final ipText;
  const ChangeIPPage({super.key, required this.ipText});

  @override
  State<ChangeIPPage> createState() => _ChangeIPPageState();
}

class _ChangeIPPageState extends State<ChangeIPPage> {
  final _IPController = TextEditingController();
  String ip = "";

  saveIP(String ip) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool address = await prefs.setString('ipAddress', ip);
    print("address = $address");
  }

  readIP(String ipAddress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final ipKey = await prefs.getString(ipAddress);

    ip = ipKey.toString();
    if (ipKey != null) {
      //final loginMess = await _loginVerify(passwordKey);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => LoginPage(ipText: ipKey)),
          (route) => false);
    }
    print("ipKeyChange = ${ip}");
    //return passwordKey;
  }

  deleteData(String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final result = await prefs.remove(password);
    if (result) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  LoginPage(ipText: widget.ipText)),
          (route) => false);
    }
    print("delete = $result");
  }

  void initState() {
    _IPController.text = widget.ipText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width; //得到屏幕的宽高

    return Scaffold(
        appBar: AppBar(
          title: Text("IP地址"),
          centerTitle: true,
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
                    autofocus: false,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 0, 29, 72),
                                width: 3,
                                style: BorderStyle.solid)),
                        hintText: "请填写IP地址"),
                    onChanged: (v) {
                      setState(() {
                        _IPController.value = TextEditingValue(
                            text: v,
                            selection: TextSelection.fromPosition(TextPosition(
                                affinity: TextAffinity.downstream,
                                offset: v.length)));
                      });
                    },
                  ),
                ),
                Container(
                  width: _width * 0.9,
                  height: 50,
                  margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child: ElevatedButton(
                      onPressed: () {
                        if (_IPController.text != widget.ipText) {
                          print("ip == ${_IPController.text}");
                          saveIP(_IPController.text);
                          deleteData("password");
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      LoginPage(ipText: _IPController.text)),
                              (route) => false);
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Text("确定修改")),
                )
              ],
            ),
          ),
        ));
  }
}
