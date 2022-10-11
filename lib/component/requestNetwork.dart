import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//请求数据
class RequestHttp {
  Future requestHttpCode(final requestBody, String token, String ip) async {
    var headers = {
      'Authorization': 'Basic ' + token,
      'Content-Type': 'application/json'
    };
    var request = http.Request('GET', Uri.parse(ip + '/jsonrpc.php'));
    request.body = requestBody;
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    return response;
  }
}
