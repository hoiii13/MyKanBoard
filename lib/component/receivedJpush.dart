import 'package:flutter/material.dart';

class ReceviedJPushCode {
  showAlertDialog(BuildContext context, String task_title, String content,
      String sendPeople) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(task_title),
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
}
