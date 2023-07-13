// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rocketchat/connections/connect.dart';

import '../manager/message_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController textcontroller = TextEditingController();
  TextEditingController usernamecontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MessageProvider(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Chat Page")),
        body: Container(
          color: Colors.grey.shade200,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  color: Colors.grey.shade300,
                  child: TextFormField(
                    controller: usernamecontroller,
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(12),
                        hintText: "Type username here...."),
                  ),
                ),
              ),
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
                  onPressed: () async {
                    await Connect().postMessage(
                        username: usernamecontroller.text,
                        text: textcontroller.text);

                    await context.read<MessageProvider>().getSentMessagesList();
                  },
                  child: const Text("send message")),
              ElevatedButton(
                  onPressed: () async {
                    // await Connect().syncMessages(context: context);
                  },
                  child: const Text("sync messages")),
            ],
          ),
        ),
      ),
    );
  }
}
