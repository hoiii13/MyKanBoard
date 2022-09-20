import 'dart:typed_data';

import 'package:board_app/pages/Tabs.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';


class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController(); //输入框用户名内容监听
  final _passwordController = TextEditingController(); //输入框密码内容监听
  bool _showPassword = false;

//用于遮挡密码
  void _passwordIcon() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }
  String encodeBase64(String data) {
    var content = utf8.encode(data);
    var digest = base64Encode(content);
    return digest;
  }

  String decodeBase64(String data) {
    return String.fromCharCodes(base64Decode(data));
  }

  
  List _allUsers = [];
  void _getAllUser() async{
    var headers = {
      'Authorization': 'Basic anNvbnJwYzpiMDNhMWRlODcxNmE5YTc2MDc0MTc2MjEyNTc0OTc2MjM2YWI1YjczOThkMmU3NGJmYzM5MmRhYjZkZGM=',
      'Content-Type': 'application/json'
      };
      var request = http.Request('GET', Uri.parse('http://43.154.142.249:18868/jsonrpc.php'));
      request.body = json.encode({
        "jsonrpc": "2.0",
        "method": "getAllUsers",
        "id": 1438712131
        });
        request.headers.addAll(headers);
        http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final res = await response.stream.bytesToString();
        final getAll = json.decode(res);
        _allUsers = getAll["result"];
      }
      else {
        print(response.reasonPhrase);
      }

  }

  @override
  void initState() {
    print("3333 = ${encodeBase64("123456")}");
    //print("dddd = ${decodeBase64("$2y$10$OFUT6f9BC6AsAv/u7ajK7e9pZW5/AKHDp.TL9t/327oaIBaq.NVAK")}");
    _getAllUser();
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
                 decoration: const InputDecoration(
                   border: OutlineInputBorder(
                     borderSide: BorderSide(
                       color: Colors.red,
                       width: 3,
                       style: BorderStyle.solid
                     )
                   ),
                   labelText: "用户名",
                   labelStyle: TextStyle(color: Colors.red, fontSize: 16),
                   enabledBorder: OutlineInputBorder(
                     borderSide: BorderSide(color: Colors.red)
                   ),
                   focusedBorder: OutlineInputBorder(
                     borderSide: BorderSide(
                       color: Colors.red
                     )
                   ),
                   prefixIcon: Icon(Icons.person, color: Colors.red,),
                   ),
                  
                  ),
                const SizedBox(height: 20.0),

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
                    onPressed: (){
                      String name = _usernameController.text;
                      int num = 0;
                      /* Navigator.pushReplacementNamed(context, "/", arguments: {
                        "username": _usernameController.text
                      }); */
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => Tabs(username: _usernameController.text)));
                      
                      /* for(var i = 0; i < _allUsers.length; i++) {
                        if(_allUsers[i]["username"] == _usernameController && _allUsers[i]["password"] == _passwordController) {
                          Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => Tabs(username: _passwordController)));
                        } else {
                          print("??? = ${_allUsers[i]["username"]}, ${_allUsers[i]["password"]}");
                          //print(".... = ${EncrytData")
                          num++;
                        }
                      }
                      if(num == _allUsers.length) {
                        print("nonono");
                      } */
                    }, 
                    child: Text("登陆", style: TextStyle(color: Colors.red, fontSize: 18),)
                    ),
                  )
             ],
           ),
         )
       ]),
       ),
     )
    );
  }
}
