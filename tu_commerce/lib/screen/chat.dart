import 'package:flutter/material.dart';
import 'package:tu_commerce/screen/navigationbarCustomer.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic>  username;
  final Map<String, dynamic>? product;

  ChatScreen({Key? key, required this.username,this.product}) : super(key: key);
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat'),),

    );
  }
}