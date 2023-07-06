// ignore_for_file: use_build_context_synchronously

import "dart:convert";
import "package:flutter/material.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:http/http.dart" as http;
import "../pages/chat_page.dart";

class Connect {
  final storage = const FlutterSecureStorage();

  registerUser({
    required String username,
    required String email,
    required String pass,
    required String name,
    required BuildContext context,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse("http://10.0.2.2:3000/api/v1/users.register"),
        headers: <String, String>{"Content-type": "application/json"},
        body: jsonEncode(
            {"username": username, "email": email, "pass": pass, "name": name}),
      );

      if (response.statusCode == 200) {
        print("user created");
        // print(response.body);

        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const ChatPage(),
        ));
      }
    } catch (e) {
      print("Register Error: ${e.toString()}");
    }
  }

  loginUser({
    required String user,
    required String password,
    required BuildContext context,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse("http://10.0.2.2:3000/api/v1/login"),
        headers: <String, String>{"Content-type": "application/json"},
        body: jsonEncode({"user": user, "password": password}),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const ChatPage(),
        ));
        print("user logged in");

        var data = jsonDecode(response.body)["data"];
        // print("data: $data");
        await storage.write(key: "userData", value: jsonEncode(data));
      }
    } catch (e) {
      print("Login Error: ${e.toString()}");
    }
  }

  sendMessage({required String text}) async {
    try {
      String? storedData = await storage.read(key: "userData");

      if (storedData != null) {
        var userData = jsonDecode(storedData);
        // print(userData["authToken"]);

        http.Response response = await http.post(
          Uri.parse("http://10.0.2.2:3000/api/v1/chat.postMessage"),
          headers: <String, String>{
            "X-Auth-Token": userData["authToken"],
            "X-User-Id": userData["userId"],
            "Content-type": "application/json",
          },
          body: jsonEncode({"channel": "@one", "text": text}),
        );

        if (response.statusCode == 200) {
          var msgId = jsonDecode(response.body)["message"]["_id"];
          // print(msgId);
          await storage.write(key: "msgId", value: jsonEncode(msgId));
        }
      }
    } catch (e) {
      print("Message Sending Error: ${e.toString()}");
    }
  }

  Stream<String> getMessageStream() async* {
    while (true) {
      try {
        String? storedData = await storage.read(key: "userData");
        String? msgIdString = await storage.read(key: "msgId");

        if (storedData != null && msgIdString != null) {
          var userData = jsonDecode(storedData);
          // print("userData: $userData");
          var msgId = jsonDecode(msgIdString);
          // print(msgId);

          http.Response response = await http.get(
            Uri.parse(
                "http://10.0.2.2:3000/api/v1/chat.getMessage?msgId=$msgId"),
            headers: <String, String>{
              "X-Auth-Token": userData["authToken"],
              "X-User-Id": userData["userId"],
              "Content-type": "application/json",
            },
          );
          var text = jsonDecode(response.body)["message"]["msg"];
          yield text.toString();
        }
      } catch (e) {
        print("Message Receipt Error: ${e.toString()}");
      }
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  getUserInfo() async {}
}


// getMessage() async {
//     try {
//       String? storedData = await storage.read(key: "userData");
//       String? msgIdString = await storage.read(key: "msgId");

//       if (storedData != null && msgIdString != null) {
//         var userData = jsonDecode(storedData);
//         // print("userData: $userData");

//         var msgId = jsonDecode(msgIdString);
//         // print(msgId);

//         http.Response response = await http.get(
//           Uri.parse("http://10.0.2.2:3000/api/v1/chat.getMessage?msgId=$msgId"),
//           headers: <String, String>{
//             "X-Auth-Token": userData["authToken"],
//             "X-User-Id": userData["userId"],
//             "Content-type": "application/json",
//           },
//         );
//         var text = jsonDecode(response.body)["message"]["msg"];
//         return text;
//       }
//     } catch (e) {
//       print("Message Receipt Error: ${e.toString()}");
//     }
//   }

