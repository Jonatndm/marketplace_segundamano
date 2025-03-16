import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatProvider with ChangeNotifier {
  late io.Socket socket;
  List<Map<String, dynamic>> messages = [];

  void connectToChat(String userId, String productId) {
    socket = io.io(
      'http://localhost:5000',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();
    socket.emit('authenticate', {'userId': userId});
    socket.emit('joinRoom', productId);

    socket.on('chat', (data) {
      messages.add(data);
      notifyListeners();
    });
  }

  void sendMessage(String message, String userId, String productId) {
    socket.emit('message', {
      'type': 'chat',
      'room': productId,
      'message': message,
      'sender': userId,
    });

    messages.add({'sender': userId, 'message': message});
    notifyListeners();
  }

  void disconnectChat() {
    socket.disconnect();
  }
}
