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

        //get data from object
        var data = await jsonDecode(response.body)["data"];
        var userId = await data["me"]["_id"];
        var authToken = await data["authToken"];
        var username = await data["me"]["username"];

        // saving userId
        print("data: $data");
        print("userId: $userId");
        print("authToken: $authToken");
        print("username: $username");

        //saving user data
        await storage.write(key: "userId", value: jsonEncode(userId));
        await storage.write(key: "authToken", value: jsonEncode(authToken));
        await storage.write(key: "username", value: jsonEncode(username));
      }
    } catch (e) {
      print("Login Error: ${e.toString()}");
    }
  }

  postMessage({required String text, required String username}) async {
    try {
      String? authTokenString = await storage.read(key: "authToken");
      String? userIdString = await storage.read(key: "userId");

      if (authTokenString != null && userIdString != null) {
        var authToken = jsonDecode(authTokenString);
        var userId = jsonDecode(userIdString);

        http.Response response = await http.post(
          Uri.parse("http://10.0.2.2:3000/api/v1/chat.postMessage"),
          headers: <String, String>{
            "X-Auth-Token": authToken,
            "X-User-Id": userId,
            "Content-type": "application/json",
          },
          body: jsonEncode({"channel": "@$username", "text": text}),
        );

        print(response.body);
        if (response.statusCode == 200) {
          var message = await jsonDecode(response.body)["message"];
          var msgId = await message["_id"];
          var roomId = await message["rid"];
          var sentMsg = await message["msg"];

          //store response
          await storage.write(key: "msgId", value: jsonEncode(msgId));
          await storage.write(key: "roomId", value: jsonEncode(roomId));
          await storage.write(key: "sentMsg", value: jsonEncode(sentMsg));

          return sentMsg.toString();
        }
      }
    } catch (e) {
      print("Message Sending Error: ${e.toString()}");
    }
  }

  getsMessage() async {
    try {
      String? authTokenString = await storage.read(key: "authToken");
      String? userIdString = await storage.read(key: "userId");
      String? msgIdString = await storage.read(key: "msgId");

      if (authTokenString != null &&
          msgIdString != null &&
          userIdString != null) {
        var userId = jsonDecode(userIdString);
        var authToken = jsonDecode(authTokenString);
        var msgId = jsonDecode(msgIdString);

        http.Response response = await http.get(
          Uri.parse("http://10.0.2.2:3000/api/v1/chat.getMessage?msgId=$msgId"),
          headers: <String, String>{
            "X-Auth-Token": authToken,
            "X-User-Id": userId,
            "Content-type": "application/json",
          },
        );
        var text = jsonDecode(response.body)["message"]["msg"];
        return text.toString();
      }
    } catch (e) {
      print("Message Receipt Error: ${e.toString()}");
    }
  }

  // Stream<String> getMessageStream() async* {
  //   try {
  //     String? storedData = await storage.read(key: "userData");
  //     String? msgIdString = await storage.read(key: "msgId");

  //     if (storedData != null && msgIdString != null) {
  //       var userData = jsonDecode(storedData);
  //       // print("userData: $userData");
  //       var msgId = jsonDecode(msgIdString);
  //       // print(msgId);

  //       http.Response response = await http.get(
  //         Uri.parse("http://10.0.2.2:3000/api/v1/chat.getMessage?msgId=$msgId"),
  //         headers: <String, String>{
  //           "X-Auth-Token": userData["authToken"],
  //           "X-User-Id": userData["userId"],
  //           "Content-type": "application/json",
  //         },
  //       );
  //       var text = jsonDecode(response.body)["message"]["msg"];
  //       print(jsonDecode(response.body)["message"]["msg"]);
  //       yield text.toString();
  //     }
  //   } catch (e) {
  //     print("Message Receipt Error: ${e.toString()}");
  //   }
  //   // await Future.delayed(const Duration(seconds: 3));
  // }

  // Stream<String> getDiscussionsStream() async* {
  //   try {
  //     String? storedData = await storage.read(key: "userData");
  //     String? roomIdString = await storage.read(key: "roomId");

  //     if (storedData != null && roomIdString != null) {
  //       var userData = jsonDecode(storedData);
  //       // print("userData: $userData");
  //       var roomId = jsonDecode(roomIdString);
  //       // print(msgId);

  //       http.Response response = await http.get(
  //         Uri.parse(
  //             "http://10.0.2.2:3000/api/v1/chat.getDiscussions?roomId=$roomId"),
  //         headers: <String, String>{
  //           "X-Auth-Token": userData["authToken"],
  //           "X-User-Id": userData["userId"],
  //           "Content-type": "application/json",
  //         },
  //       );
  //       var text = jsonDecode(response.body);
  //       print(jsonDecode(response.body));
  //       yield text.toString();
  //     }
  //   } catch (e) {
  //     print("Message Receipt Error: ${e.toString()}");
  //   }
  //   await Future.delayed(const Duration(seconds: 3));
  // }

  // getRoomInfo() async {
  //   try {
  //     String? storedData = await storage.read(key: "userData");
  //     String? roomIdString = await storage.read(key: "roomId");

  //     if (storedData != null && roomIdString != null) {
  //       var userData = jsonDecode(storedData);
  //       // print("userData: $userData");
  //       var roomId = jsonDecode(roomIdString);
  //       // print(msgId);

  //       http.Response response = await http.get(
  //         Uri.parse("http://10.0.2.2:3000/api/v1/rooms.info?roomId=$roomId"),
  //         headers: <String, String>{
  //           "X-Auth-Token": userData["authToken"],
  //           "X-User-Id": userData["userId"],
  //           "Content-type": "application/json",
  //         },
  //       );
  //       var text = jsonDecode(response.body)["message"]["msg"];
  //       print("msgs: ${jsonDecode(response.body)["message"]["msg"]}");

  //       return text.toString();
  //     }
  //   } catch (e) {
  //     print("Message Receipt Error: ${e.toString()}");
  //   }
  // }

  // Future<List<String>> getMessage() async {
  //   List<String> responseArray = [];

  //   try {
  //     String? storedData = await storage.read(key: "userData");
  //     String? msgIdString = await storage.read(key: "msgId");

  //     if (storedData != null && msgIdString != null) {
  //       var userData = jsonDecode(storedData);
  //       var msgId = jsonDecode(msgIdString);

  //       http.Response response = await http.get(
  //         Uri.parse("http://10.0.2.2:3000/api/v1/chat.getMessage?msgId=$msgId"),
  //         headers: <String, String>{
  //           "X-Auth-Token": userData["authToken"],
  //           "X-User-Id": userData["userId"],
  //           "Content-type": "application/json",
  //         },
  //       );

  //       var text = jsonDecode(response.body)["message"]["msg"];
  //       print(responseArray);
  //       responseArray.add(text.toString());

  //       print(jsonDecode(response.body)["message"]["msg"]);
  //       print(responseArray);
  //     }
  //   } catch (e) {
  //     print("Message Receipt Error: ${e.toString()}");
  //   }
  //   return responseArray;
  // }
}
