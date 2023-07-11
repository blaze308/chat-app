// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rocketchat/connections/connect.dart';
import 'package:rocketchat/manager/provider.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text("Chat Page")),
      body: Container(
        color: Colors.grey.shade200,
        child: Column(
          children: [
            // StreamBuilder(
            //   stream: context.read<MessageProvider>().addMessagetoArray(),
            //   builder: (BuildContext context, AsyncSnapshot snapshot) {
            //     return Container(
            //       child: Text(snapshot.data.toString()),
            //       // child: ListView.builder(
            //       //   itemCount: snapshot,
            //       //   itemBuilder: (context, index) {
            //       //     return Text(snapshot.data.toString());
            //       //   },
            //       // ),
            //     );
            //   },
            // ),
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
            // ElevatedButton(
            //     onPressed: () async {
            //       await Connect().getChannelHistory();
            //     },
            //     child: const Text("get history")),
            // ElevatedButton(
            //     onPressed: () async {
            //       await Connect().getMessage();
            //     },
            //     child: const Text("get message")),
            ElevatedButton(
                onPressed: () async {
                  await Connect().syncMessages();
                },
                child: const Text("sync messages")),
          ],
        ),
      ),
    );
  }
}
