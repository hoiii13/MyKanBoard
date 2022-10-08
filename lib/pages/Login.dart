import 'package:board_app/pages/Tabs.dart';
import 'package:board_app/routes/Routes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:board_app/component/requestNetwork.dart';
import 'package:board_app/component/toastPosition.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:board_app/pages/tabs/MyCenter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController(); //输入框用户名内容监听
  final _passwordController = TextEditingController(); //输入框密码内容监听
  bool _showPassword = false;
  RequestHttp httpCode = RequestHttp();
  final JPush jpush = JPush();

//用于遮挡密码
  void _passwordIcon() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

//存储token
  saveData(String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool pasToken = await prefs.setString('password', password);
    print("ppp = $pasToken");
  }

//读存储的token
  readData(String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final passwordKey = await prefs.getString(password);
    if (passwordKey != null) {
      final loginMess = await _loginVerify(passwordKey);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => Tabs(
                    username: loginMess["username"],
                    token: passwordKey,
                  )),
          (route) => false);
    }
    print("pass = ${passwordKey}");
    //return passwordKey;
  }

  /* deleteData(String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final result = await prefs.remove(password);
    print("delete = $result");
  } */
  Future _loginVerify(String baseCode) async {
    Map? _userMessage;
    final response = await httpCode.requestHttpCode(
        json.encode({"jsonrpc": "2.0", "method": "getMe", "id": 1718627783}),
        baseCode);
    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final userMess = json.decode(res);
      setState(() {
        _userMessage = userMess["result"];
      });
    } else {
      print(response.reasonPhrase);
      _userMessage = null;
    }
    return _userMessage;
  }

  @override
  void initState() {
    readData("password");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width; //得到屏幕的宽高

    return Scaffold(
        appBar: AppBar(
          centerTitle: true, //标题居中
          automaticallyImplyLeading: false,
          title: const Text(
            "登陆",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
            //textScaleFactor: 1.0,
          ),

          elevation: 0.5, //阴影高度
        ),
        resizeToAvoidBottomInset: false, //解决键盘遮住组件而引发的问题
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 130),
            child: Column(children: <Widget>[
              Container(
                width: 330,
                child: Column(
                  children: <Widget>[
                    TextField(
                      //autofocus: true,
                      controller: _usernameController,
                      cursorColor: Color.fromARGB(255, 0, 29, 72),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 0, 29, 72),
                                width: 3,
                                style: BorderStyle.solid)),
                        labelText: "用户名",
                        labelStyle: TextStyle(
                            color: Color.fromARGB(255, 0, 29, 72),
                            fontSize: 16),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 0, 29, 72))),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 0, 29, 72))),
                        prefixIcon: Icon(
                          Icons.person,
                          color: Color.fromARGB(255, 0, 29, 72),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _passwordController,
                      cursorColor: Color.fromARGB(255, 0, 29, 72),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 0, 29, 72),
                                width: 3,
                                style: BorderStyle.solid)),
                        labelText: "密码",
                        labelStyle: const TextStyle(
                            color: Color.fromARGB(255, 0, 29, 72),
                            fontSize: 16),
                        enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 0, 29, 72))),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 0, 29, 72))),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            _passwordIcon();
                          },
                          child: Icon(
                            _showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                        ),
                        prefixIcon: Icon(Icons.lock,
                            color: Color.fromARGB(255, 0, 29, 72)),
                      ),
                      obscureText: !_showPassword,
                    ),
                    const SizedBox(height: 50.0),
                    Container(
                      width: 330,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      Tabs(username: "yds", token: "123456")),
                              (route) => false);
                          String name = _usernameController.text;
                          String password = _passwordController.text;
                          if (name.isEmpty || password.isEmpty) {
                            ToastPosition.toast(context, "用户名/密码不能为空");
                          } else {
                            String textUser =
                                base64Encode(utf8.encode("$name:$password"));
                            final loginMess = await _loginVerify(textUser);
                            print("textUser = ${textUser}");

                            if (loginMess != null) {
                              //initJpush(name);
                              saveData(textUser);
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) => Tabs(
                                          username: _usernameController.text,
                                          token: textUser)),
                                  (route) => false);
                              ToastPosition.toast(context, "登陆成功");
                            } else {
                              _passwordController.clear();
                              ToastPosition.toast(context, "用户名/密码错误");
                            }
                          }
                        },
                        child: Text(
                          "登陆",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ]),
          ),
        ));
  }
}
