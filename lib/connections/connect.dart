// ignore_for_file: use_build_context_synchronously

import "dart:convert";
import "package:flutter/material.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:http/http.dart" as http;
import "package:rocketchat/pages/login_page.dart";
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

        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
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

        //get data from object
        var data = await jsonDecode(response.body)["data"];
        var userId = await data["me"]["_id"];
        var username = await data["me"]["username"];
        var authToken = await data["authToken"];

        // print data
        print("user logged in");
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

        if (response.statusCode == 200) {
          var message = await jsonDecode(response.body)["message"];
          var msgId = await message["_id"];
          var roomId = await message["rid"];
          var sentMsg = await message["msg"];
          var timestamp = await message["_updatedAt"];

          // print("post message response: ${response.body}");
          // print("message: $message");
          // print("msgId: $msgId");
          // print("roomId: $roomId");
          // print("sentMsg: $sentMsg");
          // print("timestamp: $timestamp");

          //store response
          await storage.write(key: "msgId", value: jsonEncode(msgId));
          await storage.write(key: "roomId", value: jsonEncode(roomId));
          await storage.write(key: "sentMsg", value: jsonEncode(sentMsg));
          await storage.write(key: "timestamp", value: jsonEncode(timestamp));

          return sentMsg.toString();
        }
      }
    } catch (e) {
      print("Message Sending Error: ${e.toString()}");
    }
  }

  syncMessages({required BuildContext context}) async {
    String time = "2019-04-16T18:30:46.669Z";
    String newTime =
        DateTime.now().subtract(const Duration(seconds: 60)).toIso8601String();
    time = newTime;

    try {
      String? roomIdString = await storage.read(key: "roomId");
      String? authTokenString = await storage.read(key: "authToken");
      String? userIdString = await storage.read(key: "userId");

      if (roomIdString != null &&
          authTokenString != null &&
          userIdString != null) {
        var roomId = await jsonDecode(roomIdString);
        var authToken = await jsonDecode(authTokenString);
        var userId = await jsonDecode(userIdString);

        http.Response response = await http.get(
          Uri.parse(
              "http://10.0.2.2:3000/api/v1/chat.syncMessages?roomId=$roomId&lastUpdate=$time"),
          headers: <String, String>{
            "X-Auth-Token": authToken,
            "X-User-Id": userId,
            "Content-type": "application/json"
          },
        );

        //get jsondata
        var data = await jsonDecode(response.body)["result"]["updated"];

        //mapping
        var mMap = List<Map<String, dynamic>>.from(data)
            .map((x) => Map<String, dynamic>.from(x));

        var mList = mMap.toList();

        //securing data
        await storage.write(key: "mList", value: jsonEncode(mList));
        String? storedListString = await storage.read(key: "mList");
        var storedList = await jsonDecode(storedListString!);

        print("stored: $storedList");
        return storedList;
      }
    } catch (e) {
      print("Sync messages Error: ${e.toString()}");
    }
  }
}
