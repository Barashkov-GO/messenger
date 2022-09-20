import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatWithUsername, name;

  const ChatScreen(this.chatWithUsername, this.name, {super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
