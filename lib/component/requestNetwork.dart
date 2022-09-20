import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestHttp extends StatelessWidget {
  const RequestHttp({ Key? key }) : super(key: key);

  Future requestHttpCode(final requestBody) async{
    var headers = {
      'Authorization': 'Basic anNvbnJwYzpiMDNhMWRlODcxNmE5YTc2MDc0MTc2MjEyNTc0OTc2MjM2YWI1YjczOThkMmU3NGJmYzM5MmRhYjZkZGM=',
      'Content-Type': 'application/json'
      };
      var request = http.Request('GET', Uri.parse('http://43.154.142.249:18868/jsonrpc.php'));
      request.body = requestBody;
      request.headers.addAll(headers);
      
      http.StreamedResponse response = await request.send();
      return response;

  }

  
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}