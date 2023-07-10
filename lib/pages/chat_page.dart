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
  var messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat Page")),
      body: Container(
        child: Column(
          children: [
            StreamBuilder(
              stream: context.read<MessageProvider>().addMessagetoArray(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return Container(
                  child: Text(snapshot.data.toString()),
                  // child: ListView.builder(
                  //   itemCount: snapshot,
                  //   itemBuilder: (context, index) {
                  //     return Text(snapshot.data.toString());
                  //   },
                  // ),
                );
              },
            ),
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
                  Connect().postMessage(
                      username: usernamecontroller.text,
                      text: textcontroller.text);
                },
                child: const Text("send message")),
            ElevatedButton(
                onPressed: () async {
                  // var message = await Connect().getsMessage();
                  // messages.add(message);
                  // print(messages);

                  await context.read<MessageProvider>().addMessagetoArray();
                },
                child: const Text("get message")),
          ],
        ),
      ),
    );
  }
}
