import 'dart:convert';
import 'package:board_app/component/timeChange.dart';
import 'package:board_app/pages/MyTaskDetail.dart';
import 'package:board_app/pages/chatProject.dart';
import 'package:board_app/pages/tabs/MyProject.dart';
import 'package:board_app/routes/Routes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:board_app/component/requestNetwork.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

//"我的任务"页面
class MyTaskPage extends StatefulWidget {
  final user_id;
  final username;
  final ipText;

  MyTaskPage({
    Key? key,
    required this.user_id,
    this.username,
    required this.ipText,
  }) : super(key: key);

  @override
  State<MyTaskPage> createState() => _MyTaskPageState();
}

class _MyTaskPageState extends State<MyTaskPage>
    with SingleTickerProviderStateMixin {
  final JPush jpush = JPush();
  List user_tasks = [];
  List toDos0 = [];
  List toDos1 = [];
  List toDos2 = [];
  late AnimationController _animateController;

  RequestHttp httpCode = RequestHttp();

  TimeChange timeChange = TimeChange();

  Future<void> _onRefresh() async {
    print("执行刷新");
    user_tasks = [];
    toDos0 = [];
    toDos1 = [];
    toDos2 = [];
    _getProject();
    await Future.delayed(Duration(seconds: 2), () {});
  }

//通过项目的id来得到这个项目中所含有的列的信息
  Future<String> _getProjectColumns(int id, String status) async {
    final changeStatus;
    var _change;
    final response = await httpCode.requestHttpCode(
        json.encode({
          "jsonrpc": "2.0",
          "method": "getColumns",
          "id": 887036325,
          "params": [id]
        }),
        "anNvbnJwYzpiMDNhMWRlODcxNmE5YTc2MDc0MTc2MjEyNTc0OTc2MjM2YWI1YjczOThkMmU3NGJmYzM5MmRhYjZkZGM=",
        widget.ipText);
    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final projectColumns = json.decode(res);

      List _projectColumns =
          projectColumns["result"].map<ProjectColumns>((row) {
        return ProjectColumns(
          column_id: row["id"],
          column_title: row["title"],
        );
      }).toList();

      int len = _projectColumns.length;

      for (var i = 0; i < len; i++) {
        if (_projectColumns[i].column_title == status) {
          _change = _projectColumns[i].column_id;
          break;
        }
      }
    } else {
      print(response.reasonPhrase);
      throw ("error");
    }
    return _change;
  }

//移动任务的位置，即实现任务状态的转换
  _moveTaskToOthers(int task_id, int project_id, int column_id) async {
    final response = await httpCode.requestHttpCode(
        json.encode({
          "jsonrpc": "2.0",
          "method": "moveTaskToProject",
          "id": 15775829,
          "params": [task_id, project_id, 1, column_id]
        }),
        "anNvbnJwYzpiMDNhMWRlODcxNmE5YTc2MDc0MTc2MjEyNTc0OTc2MjM2YWI1YjczOThkMmU3NGJmYzM5MmRhYjZkZGM=",
        widget.ipText);
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());

      user_tasks = [];
      toDos0 = [];
      toDos1 = [];
      toDos2 = [];
      _getProject();
    } else {
      print(response.reasonPhrase);
    }
  }

  List<Projects> Allprojects = [];
  int count = 0;
  //得到所有项目的id
  _getProject() async {
    final response = await httpCode.requestHttpCode(
        json.encode(
            {"jsonrpc": "2.0", "method": "getAllProjects", "id": 2134420212}),
        "anNvbnJwYzpiMDNhMWRlODcxNmE5YTc2MDc0MTc2MjEyNTc0OTc2MjM2YWI1YjczOThkMmU3NGJmYzM5MmRhYjZkZGM=",
        widget.ipText);

    if (response.statusCode != 200) {
      print(response.reasonPhrase);
      throw ("error");
    }
    final res = await response.stream.bytesToString();
    final projects = json.decode(res);
    // print(projects["result"]);
    final _projects = projects["result"].map<Projects>((row) {
      return Projects(project_id: row["id"]);
    }).toList();
    setState(() {
      if (mounted) {
        Allprojects = _projects;
        //print("## = ${Allprojects}");
        for (var i = 0; i < Allprojects.length; i++) {
          _getData(int.parse(Allprojects[i].project_id));
        }
      }
    });
  }

  _getData(int id) async {
    //获得数据
    final response = await httpCode.requestHttpCode(
        json.encode({
          "jsonrpc": "2.0",
          "method": "getBoard",
          "id": 827046470,
          "params": [id]
        }),
        "anNvbnJwYzpiMDNhMWRlODcxNmE5YTc2MDc0MTc2MjEyNTc0OTc2MjM2YWI1YjczOThkMmU3NGJmYzM5MmRhYjZkZGM=",
        widget.ipText);

    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final tasks = json.decode(res); //得到数据
      final _tasks = []; //为了筛选出任务中不为空的而设置的变量
      List _content = tasks["result"][0]["columns"]; //为了计算长度而设置的List变量

      for (var i = 0; i < _content.length; i++) {
        //进行判断中
        if (_content[i]["tasks"].isNotEmpty) {
          _tasks.addAll(_content[i]["tasks"]);
          //print("?? = ${_tasks}");
        }
      }
      List _list;
      if (mounted) {
        setState(() {
          _list = _tasks;
          /* final taskAbout =
              _list.where((v) => v["owner_id"] == widget.user_id).toList(); */
          final taskAbout =
              _list.where((v) => v["owner_id"] == widget.user_id).toList();
          user_tasks.addAll(taskAbout);

          toDos0 = user_tasks.where((v) => v["column_name"] == "待办").toList();
          toDos1 = user_tasks.where((v) => v["column_name"] == "进行中").toList();
          toDos2 = user_tasks.where((v) => v["column_name"] == "完成").toList();
        });
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  _showAlertDialog(String task_title, String content, String sendPeople) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("任务：${task_title}"),
              content: Text("${sendPeople}@提到了你: \n\n${content}"),
              semanticLabel: 'Label',
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "ok",
                      style: TextStyle(color: Colors.red),
                    ))
              ],
            ));
  }

//6022 alias 操作正在进行中，暂时不能进行其他 alias 操作 3.0.7 版本新增的错误码，
//多次调用 alias 相关的 API，请在获取到上一次调用回调后再做下一次操作；在未取到回调的情况下，等待 20 秒后再做下一次操作。

//6002 alias的接口调用频率是5s以上，低于5s就会报6002超时
  Future initJpush(String aliasName) async {
    jpush.applyPushAuthority(
        new NotificationSettingsIOS(sound: true, alert: true, badge: true));
    //注册registerID
    /* jpush.getRegistrationID().then((rid) {
      print("获得注册的id: $rid");
    }); */

    jpush.setup(
        appKey: "e36315a8b61572f70978d86b",
        channel: "thisChannel",
        production: false,
        debug: true);
    jpush.setAlias(aliasName).then((map) {
      print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>设置别名成功");
    });

    try {
      jpush.addEventHandler(
          onReceiveNotification: (Map<String, dynamic> message) async {
        print("flutter onReceiveNotification: $message");
      },
          //点击通知栏跳转到聊天页面
          onOpenNotification: (Map<String, dynamic> message) async {
        final res = message["extras"]["cn.jpush.android.EXTRA"];
        final _extra = json.decode(res);
        _showAlertDialog(
            message["title"], message["alert"], _extra["sendPeople"]);
        print("flutter onOpenNotification: $message");
      }, onReceiveMessage: (Map<String, dynamic> message) async {
        print("flutter onReceiveMessage: $message");
      });
    } catch (e) {
      print("极光sdk配置异常");
    }
  }

  List _myTask = [];
  late TabController tabController;

  @override
  void initState() {
    _getProject();
    //String? name = widget.username;
    Future.delayed(Duration(seconds: 1), () {
      initJpush(widget.username);
    });
    //print("pppp = $name");
    tabController = TabController(length: 3, vsync: this) //监听tabBar
      ..addListener(() {
        if (tabController.index.toDouble() == tabController.animation!.value) {
          print("tabController.index = ${tabController.index}");
        }
      });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true, //标题居中
            title: Text("我的任务",
                style: TextStyle(fontSize: 18, color: Colors.white)),
            elevation: 0.5, //阴影高度
            //shadowColor: Colors.red,
            bottom: TabBar(
              controller: tabController, //监听
              isScrollable: true,
              indicatorColor: Color.fromARGB(255, 0, 29, 72), //导航线（指示器）的颜色
              labelColor: Colors.white, //选中时的颜色
              unselectedLabelColor: Colors.grey, //未选中时的颜色
              labelStyle: TextStyle(fontSize: 16),
              /* tabs: tabsName.map((_tabName) {
                return Text(
                  _tabName,
                  style: TextStyle(fontSize: 16),
                );
              }).toList(), */
              tabs: <Widget>[
                Tab(text: "我的待办"),
                Tab(text: "进行中"),
                Tab(text: "我的已办"),
              ],
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _onRefresh();
              });
            },
            child: Listener(
              child: TabBarView(
                controller: tabController,
                children: <Widget>[
                  _buildToDo(toDos0),
                  _buildToDo(toDos1),
                  _buildToDo(toDos2),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _onRefresh();
            },
            child: Icon(Icons.refresh, color: Colors.white),
          ),
        ));
  }

  ListView _buildToDo(List toDos) {
    //传过来3种状态的数组，各自显示列表
    DateTime nowTime = DateTime.now();
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      addAutomaticKeepAlives: true,
      itemCount: toDos.length,
      itemBuilder: (context, index) {
        print(tabController.index);
        return Column(
          children: [
            GestureDetector(
              child: ListTile(
                title: toDos.isEmpty
                    ? Text(
                        "加载中...",
                        style: TextStyle(fontSize: 18),
                      )
                    : Text(
                        toDos[index]["title"],
                        style: TextStyle(fontSize: 18),
                      ),
                subtitle: toDos[index]["date_due"] == "0"
                    ? Text("截止时间: 未设置", style: TextStyle(fontSize: 15))
                    : Text(
                        "截止时间:${timeChange.timeStamp(toDos[index]["date_due"])}",
                        style: TextStyle(fontSize: 15)),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => MyTaskDetailPage(
                            taskDetail: toDos[index],
                            user_id: widget.user_id,
                            username: widget.username,
                            ipText: widget.ipText,
                          )));
                },
              ),
              onLongPressStart: (LongPressStartDetails details) {
                double globlePositionX = details.globalPosition.dx;
                double globlePositionY = details.globalPosition.dy;
                onLongPress(context, globlePositionX, globlePositionY, index,
                    toDos[index]);
              },
            ),
            const Divider()
          ],
        );
      },
    );
  }

//长按后显示菜单
  void onLongPress(
      BuildContext context, double x, double y, int index, final tasks) {
    final RenderBox? overlay =
        Overlay.of(context)?.context.findRenderObject() as RenderBox;
    RelativeRect position = RelativeRect.fromRect(
        Rect.fromLTRB(x, y, x + 50, y + 50), Offset.zero & overlay!.size);

    late String text1, text2;
    if (tabController.index == 0) {
      //监听到是当前页面是哪页，然后再根据是哪页来显示不同的菜单
      text1 = "进行中";
      text2 = "完成";
    } else if (tabController.index == 1) {
      text1 = "待办";
      text2 = "完成";
    } else if (tabController.index == 2) {
      text1 = "待办";
      text2 = "进行中";
    }

    PopupMenuItem popupMenuItem1 = PopupMenuItem(
      value: 1,
      child: Text(text1),
    );
    PopupMenuItem popupMenuItem2 = PopupMenuItem(
      value: 2,
      child: Text(text2),
    );
    List<PopupMenuEntry<dynamic>> list = [popupMenuItem1, popupMenuItem2];

    showMenu(context: context, position: position, items: list)
        .then((value) async {
      int task_id = int.parse(tasks["id"]);

      int project_id = int.parse(tasks["project_id"]);

      if (value == 1) {
        final _columns = await _getProjectColumns(project_id, text1);

        int columns = int.parse(_columns);
        _moveTaskToOthers(task_id, project_id, columns);
      } else if (value == 2) {
        final _columns = await _getProjectColumns(project_id, text2);
        int columns = int.parse(_columns);
        _moveTaskToOthers(task_id, project_id, columns);
      }
    });
  }
}

class Projects {
  final String project_id;
  Projects({required this.project_id});

  @override
  String toString() {
    return "$project_id";
  }
}

class ProjectColumns {
  final String column_id;
  final String column_title;
  ProjectColumns({required this.column_id, required this.column_title});

  @override
  String toString() {
    return "$column_id $column_title";
  }
}

class Tasks {
  final String status;
  final String title; //标题
  final String desc;
  final String owner_name; //任务的主人
  final String owner_id;
  final String create_id; //创建项目的人
  final String date_started; //开始时间
  final String date_due; //结束时间
  final String column_id;
  final String task_id;
  final String project_id;
  Tasks(
      {required this.status,
      required this.title,
      required this.desc,
      required this.owner_name,
      required this.owner_id,
      required this.create_id,
      required this.date_started,
      required this.date_due,
      required this.column_id,
      required this.task_id,
      required this.project_id});
  @override
  String toString() {
    return "$title $status $owner_name";
  }
}
