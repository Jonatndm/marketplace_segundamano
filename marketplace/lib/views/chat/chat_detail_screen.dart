import 'package:flutter/material.dart';
import 'package:marketplace/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;

  const ChatDetailScreen({super.key, required this.chatId});

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  Future<List<dynamic>> fetchChatMessages() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null || token.isEmpty) {
      throw Exception('No autenticado');
    }

    final response = await http.get(
      Uri.parse('http://192.168.100.4:5000/api/chat/${widget.chatId}/messages'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Retorna la lista de mensajes
    } else {
      throw Exception('Error al cargar los mensajes');
    }
  }

  Future<void> sendMessage(String content) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null || token.isEmpty) {
      throw Exception('No autenticado');
    }

    final response = await http.post(
      Uri.parse('http://192.168.100.4:5000/api/chat/${widget.chatId}/messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'content': content,
      }),
    );

    if (response.statusCode == 200) {
      _messageController.clear();
      setState(() {});
    } else {
      throw Exception('Error al enviar el mensaje');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context); // Aquí se obtiene el authProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Chat'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchChatMessages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No hay mensajes en este chat.'));
          } else {
            final messages = snapshot.data!;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isSender = message['sender']['_id'] == authProvider.userId;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Align(
                          alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSender ? Colors.blue[100] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['content'],
                                  style: TextStyle(
                                    color: isSender ? Colors.black : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  message['sender']['name'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSender ? Colors.blue[800] : Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  // Aquí puedes formatear la fecha de tu mensaje
                                  'hace ${DateTime.now().difference(DateTime.parse(message['createdAt'])).inMinutes} minutos',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Escribe un mensaje...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          final content = _messageController.text.trim();
                          if (content.isNotEmpty) {
                            sendMessage(content);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
