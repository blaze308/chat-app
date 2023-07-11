// ignore_for_file: use_build_context_synchronously

import "dart:convert";
import "dart:developer";
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

          print("post message response: ${response.body}");
          // print("message: $message");
          print("msgId: $msgId");
          print("roomId: $roomId");
          print("sentMsg: $sentMsg");

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

  syncMessages() async {
    try {
      String? roomIdString = await storage.read(key: "roomId");
      String? authTokenString = await storage.read(key: "authToken");
      String? userIdString = await storage.read(key: "userId");
      String? usernameString = await storage.read(key: "username");

      if (roomIdString != null &&
          authTokenString != null &&
          userIdString != null &&
          usernameString != null) {
        var roomId = await jsonDecode(roomIdString);
        var authToken = await jsonDecode(authTokenString);
        var userId = await jsonDecode(userIdString);
        var username = await jsonDecode(usernameString);

        http.Response response = await http.get(
          Uri.parse(
              "http://10.0.2.2:3000/api/v1/chat.syncMessages?roomId=$roomId&lastUpdate=2019-04-16T18:30:46.669Z"),
          headers: <String, String>{
            "X-Auth-Token": authToken,
            "X-User-Id": userId,
            "Content-type": "application/json"
          },
        );

        //get jsondata
        var data = jsonDecode(response.body)["result"]["updated"];

        //mapping
        var mMap = List<Map<String, dynamic>>.from(data)
            .map((x) => Map<String, dynamic>.from(x));
        // print(mList);
        // for (var item in mList) {
        //   print("item: $item");
        //   return item;
        // }
        // var one = item[8]["msg"];
        // print(one);

        //convert to List
        var mList = mMap.toList();
        // print(itemList.length);

        for (int i = 0; i < mList.length;) {
          var mapUsername = mList[i]["u"]["username"];
          var mapMsg = mList[i]["msg"];
          // print(mList[i]["msg"]);
          // print(username);
          // print(mapId);

          if (mapUsername == username) {
            print("$mapUsername: $mapMsg");
            var senderMsg = mapMsg;
            return senderMsg.toString();
          } else {
            print("other: $mapMsg");
            var receiverMsg = mapMsg;
            return receiverMsg.toString();
          }
        }
      }
    } catch (e) {
      print("Sync messages Error: ${e.toString()}");
    }
  }
}

  // getMessage() async {
  //   try {
  //     String? authTokenString = await storage.read(key: "authToken");
  //     String? userIdString = await storage.read(key: "userId");
  //     String? msgIdString = await storage.read(key: "msgId");

  //     if (authTokenString != null &&
  //         msgIdString != null &&
  //         userIdString != null) {
  //       var userId = jsonDecode(userIdString);
  //       var authToken = jsonDecode(authTokenString);
  //       var msgId = jsonDecode(msgIdString);

  //       http.Response response = await http.get(
  //         Uri.parse("http://10.0.2.2:3000/api/v1/chat.getMessage?msgId=$msgId"),
  //         headers: <String, String>{
  //           "X-Auth-Token": authToken,
  //           "X-User-Id": userId,
  //           "Content-type": "application/json",
  //         },
  //       );
  //       var text = jsonDecode(response.body)["message"]["msg"];
  //       return text.toString();
  //     }
  //   } catch (e) {
  //     print("Message Receipt Error: ${e.toString()}");
  //   }
  // }