import 'dart:async';

import 'package:flutter/material.dart';

class InheritedWidgetTestRoute extends StatefulWidget {
  @override
  _InheritedWidgetTestRouteState createState() =>
      _InheritedWidgetTestRouteState();
}

class _InheritedWidgetTestRouteState extends State<InheritedWidgetTestRoute> {
  int count = 0;
  int num = 9;
  int k = 0;
  late Timer _timer;
  late Timer _timer2;
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("test")),
      body: Center(
        child: ShareDataWidget(
          //使用ShareDataWidget
          data: count,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: _TestWidget(), //子widget中依赖ShareDataWidget
              ),
              /* ElevatedButton(
              child: Text("Increment"),
              //每点击一次，将count自增，然后重新build,ShareDataWidget的data将被更新
              onPressed: () => setState(() => ++count),
            ) */
              TestTime(),
              TestTime2()
            ],
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  TestTime() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        count++;
      });
    });
    print("VVVV = ${_timer}");
    return Container(
      child: Text("count = ${count}"),
    );
  }

  TestTime2() {
    _timer2 = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        num++;
      });
    });
    // print("VVVV = ${_timer}");
    return Container(
      child: Text("count = ${num}"),
    );
  }
}

class _TestWidget extends StatefulWidget {
  @override
  __TestWidgetState createState() => __TestWidgetState();
}

class __TestWidgetState extends State<_TestWidget> {
  int k = 1;
  @override
  Widget build(BuildContext context) {
    //使用InheritedWidget中的共享数据
    final a = ShareDataWidget.of(context)!.data.toString();
    return Container(
      height: 200,
      color: Colors.red,
      child: Text("123"),
    );
  }

  @override //下文会详细介绍。
  void didChangeDependencies() {
    super.didChangeDependencies();
    //父或祖先widget中的InheritedWidget改变(updateShouldNotify返回true)时会被调用。
    //如果build中没有依赖InheritedWidget，则此回调不会被调用。
    print("Dependencies change");
    k = 0;
  }
}

class ShareDataWidget extends InheritedWidget {
  ShareDataWidget({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  final int data; //需要在子树中共享的数据，保存点击次数

  //定义一个便捷方法，方便子树中的widget获取共享数据
  static ShareDataWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShareDataWidget>();
  }

  //该回调决定当data发生变化时，是否通知子树中依赖data的Widget重新build
  @override
  bool updateShouldNotify(ShareDataWidget old) {
    return old.data != data;
  }
}
