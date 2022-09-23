import 'package:board_app/component/timeChange.dart';
import 'package:board_app/pages/MyTaskDetail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:board_app/component/requestNetwork.dart';

class ProjectListsPage extends StatefulWidget {
  final title;
  final project_id;
  const ProjectListsPage({Key? key, this.project_id, this.title})
      : super(key: key);

  @override
  _ProjectListsPageState createState() => _ProjectListsPageState();
}

class _ProjectListsPageState extends State<ProjectListsPage> {
  RequestHttp httpCode = RequestHttp();
  TimeChange timeChange = TimeChange();
  List columnTitles = [];
  List projectColumns = [];
  List _taskLists = [];
  bool _isClick = false;
  int num = 0;

  //项目看板内容
  _getBoards(int project_id) async {
    final response = await httpCode.requestHttpCode(
        json.encode({
          "jsonrpc": "2.0",
          "method": "getBoard",
          "id": 827046470,
          "params": [project_id]
        }),
        "anNvbnJwYzpiMDNhMWRlODcxNmE5YTc2MDc0MTc2MjEyNTc0OTc2MjM2YWI1YjczOThkMmU3NGJmYzM5MmRhYjZkZGM=");
    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final projectBoard = json.decode(res);
      projectColumns = projectBoard["result"][0]["columns"];
      //int len = projectColumns.length;
      if (mounted) {
        setState(() {
          for (var i = 0; i < projectColumns.length; i++) {
            columnTitles.add(projectColumns[i]["title"]);
          }
          print("111 = ${columnTitles}");
          //print("object = ${projectBoard["result"][0]["columns"][2]}");
        });
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  _getUser(int user_id) async {
    String username = "";
    final response = await httpCode.requestHttpCode(
        json.encode({
          "jsonrpc": "2.0",
          "method": "getUser",
          "id": 1769674781,
          "params": {"user_id": user_id}
        }),
        "anNvbnJwYzpiMDNhMWRlODcxNmE5YTc2MDc0MTc2MjEyNTc0OTc2MjM2YWI1YjczOThkMmU3NGJmYzM5MmRhYjZkZGM=");
    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final userInfo = json.decode(res);
      username = userInfo["result"]["name"] == ""
          ? userInfo["result"]["username"]
          : userInfo["result"]["name"];
    } else {
      print(response.reasonPhrase);
    }
    return username;
  }

  @override
  void initState() {
    _getBoards(int.parse(widget.project_id));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true, //标题居中
          title: Text(
            widget.title,
            style: TextStyle(fontSize: 15, color: Colors.black),
          ),
          elevation: 0.5, //阴影高度
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 300,
                  margin: EdgeInsets.only(top: 20),
                  alignment: Alignment.center,
                  color: Colors.grey[200],
                  child: ListTile(
                    title: columnTitles.isEmpty
                        ? Text("加载中...")
                        : Text(columnTitles[num]),
                    trailing: _isClick
                        ? Icon(Icons.expand_more)
                        : Icon(Icons.chevron_right),
                    onTap: () {
                      setState(() {
                        _isClick = !_isClick;
                      });
                    },
                  ),
                ),
              ),
              Container(
                width: 300,
                child: Divider(color: Colors.white),
              ),
              Stack(
                children: [_buildTasksList(_taskLists), _buildColumns()],
              ),
            ],
          ),
        ));
  }

  Widget _buildColumns() {
    return Center(
      child: Container(
        width: 300,
        color: Colors.grey[200],
        child: Visibility(
            visible: _isClick,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: columnTitles.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      GestureDetector(
                        child: ListTile(
                          title: Text(columnTitles[index]),
                          onTap: () {
                            setState(() {
                              _isClick = !_isClick;
                              num = index;
                              _taskLists = projectColumns[index]["tasks"];
                              print("_task = ${_taskLists}");
                            });
                          },
                        ),
                      )
                    ],
                  );
                })),
      ),
    );
  }

  Widget _buildTasksList(List tasksList) {
    final _heigth = MediaQuery.of(context).size.height; //得到屏幕的宽高

    return SingleChildScrollView(
      child: Container(
        height: _heigth,
        child: ListView.builder(
            itemCount: tasksList.length,
            itemBuilder: (context, index) {
              return Column(children: [
                GestureDetector(
                  child: ListTile(
                    title: Text(tasksList[index]["title"]),
                    subtitle: tasksList[index]["date_due"] == "0"
                        ? Text("截止时间: 未设置", style: TextStyle(fontSize: 13))
                        : Text(
                            "截止时间:${timeChange.timeStamp(tasksList[index]["date_due"])}",
                            style: TextStyle(fontSize: 13)),
                    onTap: () async {
                      String name = await _getUser(
                          int.parse(tasksList[index]["owner_id"]));

                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => MyTaskDetailPage(
                              taskDetail: tasksList[index],
                              user_id: tasksList[index]["owner_id"],
                              username: name)));
                    },
                  ),
                ),
                const Divider()
              ]);
            }),
      ),
    );
  }
}
