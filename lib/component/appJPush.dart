import 'package:board_app/pages/chatProject.dart';
import 'package:flutter/material.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

class AppJPush {
  static final JPush jPush = JPush();

  static Future<void> initialized() async {
    jPush.setup(
        appKey: 'e36315a8b61572f70978d86b',
        channel: 'theChannel',
        production: false,
        debug: true);

    //jPush.setAlias(ChatProjectPage.);
    jPush.applyPushAuthority(
        new NotificationSettingsIOS(sound: true, alert: true, badge: true));
    jPush.addEventHandler(
        onReceiveNotification: (Map<String, dynamic> message) async {
          print(message);
        },
        onOpenNotification: (Map<String, dynamic> message) async {});
  }
}
