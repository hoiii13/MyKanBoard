import 'package:board_app/pages/Login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyCenterPage extends StatefulWidget {
  MyCenterPage({Key? key}) : super(key: key);

  @override
  State<MyCenterPage> createState() => _MyCenterPageState();
}

class _MyCenterPageState extends State<MyCenterPage> {

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: Text("个人中心")),
      body: Container(
        child: ElevatedButton(onPressed: (){
          deleteData("password");

        }, child: Text("退出")),
      ),
    );
  }
}
