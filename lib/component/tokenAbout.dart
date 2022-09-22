import 'package:board_app/pages/Login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:board_app/component/requestNetwork.dart';

class TokenAboutRoute extends StatefulWidget {
  TokenAboutRoute({Key? key}) : super(key: key);

  @override
  State<TokenAboutRoute> createState() => _TokenAboutRouteState();
}

class _TokenAboutRouteState extends State<TokenAboutRoute> {
  
  //删除存储下来的token（退出登陆）
  deleteData(String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final result = await prefs.remove(password);
    if(result) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
        builder: (BuildContext context) => LoginPage()), 
        (route) => false);
    }
    print("delete = $result");
  }

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
