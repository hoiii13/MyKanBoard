import 'package:flutter/material.dart';

//toast
class ToastPosition {
  static OverlayEntry? overlayEntry;
  static final ToastPosition _showToast = ToastPosition._internal();
  factory ToastPosition() {
    return _showToast;
  }
  ToastPosition._internal();
  static toast(context, String str) {
    if (overlayEntry != null) return;
    overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        top: MediaQuery.of(context).size.height * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 4),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              constraints: BoxConstraints(
                minHeight: 50,
              ),
              child: Center(
                child: Text(
                  str,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      );
    });
    var overlayState = Overlay.of(context);
    overlayState?.insert(overlayEntry!);
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry!.remove();
      overlayEntry = null;
    });
  }
}
