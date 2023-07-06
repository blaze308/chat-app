import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:rocketchat/connections/connect.dart';
import 'package:rocketchat/pages/message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  StreamController<String> streamController = StreamController<String>();
  @override
  void initState() {
    super.initState();
    startMessageStream();
  }

  void startMessageStream() async {
    await for (var messageText in Connect().getMessageStream()) {
      streamController.add(messageText);
    }
  }

  TextEditingController textcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Chat Page")),
        body: Container(
          child: Column(
            children: [
              Expanded(
                  child: StreamBuilder<String>(
                stream: streamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (snapshot.hasData) {
                    final messageList = snapshot.data!.split("\n");
                    return ListView.builder(
                      itemCount: messageList.length,
                      itemBuilder: (context, index) {
                        final messageText = messageList[index];
                        return ListTile(
                          title: Text(messageText),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text("not found"));
                  }
                },
              )),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  color: Colors.grey.shade300,
                  child: TextFormField(
                    controller: textcontroller,
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(12),
                        hintText: "Type your message here...."),
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    Connect().sendMessage(text: textcontroller.text);
                  },
                  child: const Text("send message")),
            ],
          ),
        ));
  }
}
