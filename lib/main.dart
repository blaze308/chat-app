import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rocketchat/manager/message_provider.dart';
import 'package:rocketchat/pages/login_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MessageProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const LoginPage();
  }
}
