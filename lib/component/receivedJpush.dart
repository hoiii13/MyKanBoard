import 'package:flutter/material.dart';

class ReceviedJPushCode extends StatefulWidget {
  final task_title;
  final content;
  final sendPeople;
  ReceviedJPushCode({Key? key, this.task_title, this.content, this.sendPeople});

  @override
  State<ReceviedJPushCode> createState() => _ReceviedJPushCodeState();
}

class _ReceviedJPushCodeState extends State<ReceviedJPushCode> {
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

  @override
  Widget build(BuildContext context) {
    return _showAlertDialog(
        widget.task_title, widget.content, widget.sendPeople);
  }
}
