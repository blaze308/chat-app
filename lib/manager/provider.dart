import 'package:flutter/material.dart';
import 'package:rocketchat/connections/connect.dart';

class MessageProvider with ChangeNotifier {
  final List _messages = [];

  List get messages => _messages;

  Stream addMessagetoArray() async* {
    var message = await Connect().getsMessage();
    _messages.add(message);
    print(messages);
    notifyListeners();
    yield messages;
    await Future.delayed(Duration(seconds: 3));
  }
}
