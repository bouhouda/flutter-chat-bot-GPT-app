import 'package:flutter/material.dart';
import 'home.page.dart';
import 'chat.page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {"/chat": (context) => const ChatPage()},
      theme: ThemeData(
        primaryColor: Colors.teal,
        indicatorColor: Colors.white,
      ),
      home: HomePage(),
    );
  }
}
