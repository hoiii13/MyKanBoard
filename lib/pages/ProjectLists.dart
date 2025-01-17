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
  List columnIds = [];
  List projectColumns = [];
  List _taskLists = [];
  List columnTitle2 = [];
  bool _isClick = false;
  bool status = false;
  int num = 0;

  Future<void> _onRefresh() async {
    print("执行刷新");
    columnTitles.clear();
    columnIds.clear();
    projectColumns.clear();
    _taskLists.clear();
    columnTitle2.clear();
    _getBoards(int.parse(widget.project_id));
    await Future.delayed(Duration(seconds: 2), () {});
  }

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
            columnTitle2.add(projectColumns[i]["title"]);
            columnIds.add(projectColumns[i]["id"]);
          }
          // print("111 = ${columnTitles}");
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

  _moveTaskToOthers(int task_id, int project_id, int column_id) async {
    final response = await httpCode.requestHttpCode(
        json.encode({
          "jsonrpc": "2.0",
          "method": "moveTaskToProject",
          "id": 15775829,
          "params": [task_id, project_id, 1, column_id]
        }),
        "anNvbnJwYzpiMDNhMWRlODcxNmE5YTc2MDc0MTc2MjEyNTc0OTc2MjM2YWI1YjczOThkMmU3NGJmYzM5MmRhYjZkZGM=");
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());

      columnTitles.clear();
      columnIds.clear();
      projectColumns.clear();
      _taskLists.clear();
      columnTitle2.clear();
      _getBoards(int.parse(widget.project_id));
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    _getBoards(int.parse(widget.project_id));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //为了让默认列表显示出来，并且在进行任务调整后不会让列表消失
    if (projectColumns.isNotEmpty) {
      _taskLists = projectColumns[num]["tasks"];
    }
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onRefresh();
        },
        child: Icon(
          Icons.refresh,
          color: Colors.red,
        ),
      ),
    );
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
                              //print("_task = ${_taskLists}");
                            });
                          },
                        ),
                      ),
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
                        print("name =  ${tasksList[index]["owner_id"]}");

                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => MyTaskDetailPage(
                                taskDetail: tasksList[index],
                                user_id: tasksList[index]["owner_id"],
                                username: name)));
                      },
                    ),
                    onLongPressStart: (LongPressStartDetails details) {
                      double globlePositionX = details.globalPosition.dx;
                      double globlePositionY = details.globalPosition.dy;

                      print("$columnTitle2---$columnTitles");
                      onLongPress(context, globlePositionX, globlePositionY,
                          tasksList[index], columnTitles, columnIds);
                    }),
                const Divider()
              ]);
            }),
      ),
    );
  }

  void onLongPress(BuildContext context, double x, double y, final task,
      List _columnTitles, final columnId) {
    final RenderBox? overlay =
        Overlay.of(context)?.context.findRenderObject() as RenderBox;
    RelativeRect position = RelativeRect.fromRect(
        Rect.fromLTRB(x, y, x + 50, y + 50), Offset.zero & overlay!.size);
    List<PopupMenuEntry<dynamic>> list = [];
    // _columnsTitle.removeAt(index);
    print("ppppppp = ${_columnTitles[num]}");
    list.clear();
    for (var i = 0; i < _columnTitles.length; i++) {
      if (_columnTitles[num] != _columnTitles[i]) {
        PopupMenuItem popupMenuItem = PopupMenuItem(
          child: Text(_columnTitles[i]),
          value: i,
        );
        list.add(popupMenuItem);
      }
    }
    showMenu(context: context, position: position, items: list)
        .then((value) async {
      int task_id = int.parse(task["id"]);
      int project_id = int.parse(task["project_id"]);

      //添加这个判断是为了在长按列表后，如果取消点击，这样不会报错（因为value为null时，则不执行_moveTaskToOthers函数）
      if (value != null) {
        _moveTaskToOthers(task_id, project_id, columnId[value]);
      } else {
        print("取消");
      }
    });
  }
}
