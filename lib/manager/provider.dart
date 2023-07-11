import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MessageProvider with ChangeNotifier {
  final storage = const FlutterSecureStorage();

  final List _sentMsgs = [];

  List get sentMsgs => _sentMsgs;

  getSentMessagesList() async {
    String? sentMsgString = await storage.read(key: "sentMsg");
    if (sentMsgString != null) {
      var sentMsg = await jsonDecode(sentMsgString);
      if (sentMsg != "") {
        _sentMsgs.add(sentMsg);
        notifyListeners();
        print("sentMsgs: $sentMsgs");
        return sentMsgs;
      }
    }
  }
}
