import 'package:flutter/material.dart';

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Chats'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text('Aquí puedes ver la lista de Chats.'),
      ),
    );
  }
}