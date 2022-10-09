import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestHttp {
  Future requestHttpCode(final requestBody, String token) async {
    var headers = {
      'Authorization': 'Basic ' + token,
      'Content-Type': 'application/json'
    };
    var request =
        http.Request('GET', Uri.parse('http://192.168.1.17:18868/jsonrpc.php'));
    request.body = requestBody;
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    return response;
  }
}
