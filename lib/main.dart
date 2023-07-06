import 'package:flutter/material.dart';
import 'package:rocketchat/pages/login_page.dart';
import 'package:rocketchat/pages/register_page.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("RocketChat")),
      body: const LoginPage(),
    );
  }
}
