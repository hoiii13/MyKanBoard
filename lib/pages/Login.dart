import 'package:board_app/pages/Tabs.dart';
import 'package:board_app/routes/Routes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:board_app/component/requestNetwork.dart';
import 'package:board_app/component/toastPosition.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
  String hintName = "用户名";

//用于遮挡密码
  void _passwordIcon() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

//存储token
  saveData(String password) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool pasToken = await prefs.setString('password', password);
    print("ppp = $pasToken");
  }

//读存储的token
  readData(String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final passwordKey = await prefs.getString(password);
    if(passwordKey != null) {
      final loginMess = await _loginVerify(passwordKey);
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
        builder: (BuildContext context) => Tabs(username: loginMess["username"])), 
        (route) => false);
    }
    //return passwordKey;
    print("pass = $passwordKey");
  }

  deleteData(String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final result = await prefs.remove(password);
    print("delete = $result");
  }
  Future _loginVerify(String baseCode) async{
    Map? _userMessage;
    var headers = {
      'Authorization': 'Basic ' + baseCode,
      'Content-Type': 'application/json',
      'Cookie': 'KB_SID=dq9v0kf4822r9dg9tm5u0l8etp'
      };
      var request = http.Request('POST', Uri.parse('http://43.154.142.249:18868/jsonrpc.php'));
      request.body = json.encode({
        "jsonrpc": "2.0",
        "method": "getMe",
        "id": 1718627783
        });
        request.headers.addAll(headers);
        http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        final res = await response.stream.bytesToString();
        final userMess = json.decode(res);
        setState(() {
          _userMessage = userMess["result"];
        });
      }
      else {
        print(response.reasonPhrase);
        _userMessage = null;
      }
      return _userMessage;

  }
  @override
  void initState() {
    readData("password");
    //String? readPassword = readData("password");
    //print("resd = ${readPassword}");
    //saveData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("登陆", style: TextStyle(fontSize: 20),),
        automaticallyImplyLeading: false,
        elevation: 1,
      ),
     body: Center(
       child: Padding(
         padding: const EdgeInsets.only(top: 150),
         child: Column(
       children: <Widget>[
         Container(
           width: 330,
           child: Column(
             children: <Widget>[

               TextField(
                 //autofocus: true,
                 controller: _usernameController,
                 cursorColor: Colors.red,
                 decoration:  InputDecoration(
                   border: const OutlineInputBorder(
                     borderSide: BorderSide(
                       color: Colors.red,
                       width: 3,
                       style: BorderStyle.solid
                     )
                   ),
                   labelText: hintName,
                   labelStyle: const TextStyle(color: Colors.red, fontSize: 16),
                   enabledBorder: const OutlineInputBorder(
                     borderSide: BorderSide(color: Colors.red)
                   ),
                   focusedBorder: const OutlineInputBorder(
                     borderSide: BorderSide(
                       color: Colors.red
                     )
                   ),
                   prefixIcon: Icon(Icons.person, color: Colors.red,),
                   ),
                  
                  ),
                const SizedBox(height: 40),

                TextField(
                 controller: _passwordController,
                 cursorColor: Colors.red,
                 decoration: InputDecoration(
                   border: const OutlineInputBorder(
                     borderSide: BorderSide(
                       color: Colors.red,
                       width: 3,
                       style: BorderStyle.solid
                     )
                   ),
                   labelText: "密码",
                   labelStyle: const TextStyle(color: Colors.red, fontSize: 16),
                   enabledBorder: const OutlineInputBorder(
                     borderSide: BorderSide(color: Colors.red)
                   ),
                   focusedBorder: const OutlineInputBorder(
                     borderSide: BorderSide(
                       color: Colors.red
                     )
                   ),
                   suffixIcon: GestureDetector(
                     onTap: () {
                       _passwordIcon();
                     },
                     child: Icon(
                       _showPassword ? Icons.visibility : Icons.visibility_off,
                       color: Colors.grey,
                     ),
                   ),
                   prefixIcon: Icon(Icons.lock, color: Colors.red),
                   ),
                  obscureText: !_showPassword,
                  ),
                  const SizedBox(height: 50.0),
                  Container(
                    width: 330,
                    height: 50,
                    child: ElevatedButton(
                    onPressed: () async {
                      String name = _usernameController.text;
                      String password = _passwordController.text;
                      if(name.isEmpty || password.isEmpty) {
                        ToastPosition.toast(context, "用户名/密码不能为空");
                      } else {
                        String textUser = base64Encode(utf8.encode("$name:$password"));
                        final loginMess = await _loginVerify(textUser);
                        if(loginMess != null) {
                          saveData(textUser);
                        print("login = ${loginMess["id"]}");
                          saveData(textUser);
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                            builder: (BuildContext context) => Tabs(username: _usernameController.text)), 
                            (route) => false);
                            ToastPosition.toast(context, "登陆成功");
                            } else {
                              _passwordController.clear();
                              ToastPosition.toast(context, "用户名/密码错误");
                      }
                      }
                    }, 
                    child: Text("登陆", style: TextStyle(color: Colors.red, fontSize: 18),),
                    ),
                  ),
             ],
           ),
         )
       ]),
       ),
     )
    );
  }
}


