import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rocketchat/connections/connect.dart';

class MessageProvider with ChangeNotifier {
  final storage = const FlutterSecureStorage();
  final List _messages = [];

  final List _sentMsgs = [];

  List get messages => _messages;

  List get sentMsgs => _sentMsgs;

  Stream addMessagetoArray() async* {
    var message = await Connect().getsMessage();
    _messages.add(message);
    print(messages);
    notifyListeners();
    yield messages;
    await Future.delayed(Duration(seconds: 3));
  }

  getSentMessagesList() async {
    String? sentMsgString = await storage.read(key: "sentMsg");
    if (sentMsgString != null) {
      var sentMsg = jsonDecode(sentMsgString);
      print("sentMsg: $sentMsg");
      _sentMsgs.add(sentMsg);
      notifyListeners();
      return sentMsgs;
    }
  }
}
