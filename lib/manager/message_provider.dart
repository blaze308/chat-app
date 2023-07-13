import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

class MessageProvider with ChangeNotifier {
  final storage = const FlutterSecureStorage();

  final List _sentMsgs = [];
  List _messages = [];

  List get sentMsgs => _sentMsgs;
  List get messages => _messages;

  set messages(List updatedMessages) {
    _messages = updatedMessages;
    notifyListeners();
    print("messages: $_messages");
  }

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
