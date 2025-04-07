import 'dart:async';
import 'package:flutter/material.dart';
import 'package:marketplace/providers/auth_provider.dart';
import 'package:marketplace/views/chat/time_helper.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;

  const ChatDetailScreen({super.key, required this.chatId});

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late TextEditingController _messageController;
  late IO.Socket _socket;
  late StreamController<List<dynamic>> _messagesController;
  List<dynamic> _messages = [];
  static const String baseUrl = 'http://localhost:5000';

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _messagesController = StreamController<List<dynamic>>();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _socket = IO.io(baseUrl, {
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': authProvider.token},
    });

    _socket.connect();
    _socket.on('connect', (_) {
      _socket.emit('joinChat', widget.chatId);
    });

    _socket.on('newMessage', (data) {
      setState(() {
        _messages.insert(0, data);
      });
    });

    // Cargar mensajes iniciales
    fetchChatMessages().then((messages) {
      setState(() {
        _messages =
            messages.reversed
                .toList(); // Reversa si quieres ver los más recientes abajo
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messagesController.close(); // Cerrar el StreamController
    _socket.disconnect();
    super.dispose();
  }

  Future<List<dynamic>> fetchChatMessages() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null || token.isEmpty) {
      throw Exception('No autenticado');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/chat/${widget.chatId}/messages'),
      headers: {'Authorization': 'Bearer $token'},
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
      Uri.parse('$baseUrl/api/chat/${widget.chatId}/messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'content': content}),
    );

    if (response.statusCode == 200) {
      _messageController.clear();
      setState(() {});
    } else {
      throw Exception('Error al enviar el mensaje');
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      _socket.emit('sendMessage', {
        'chatId': widget.chatId,
        'content': content,
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(
      context,
    ); // Aquí se obtiene el authProvider

    return Scaffold(
      appBar: AppBar(title: const Text('Detalles del Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Opcional: muestra los mensajes nuevos abajo
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isSender =
                    message['sender']['_id'] == authProvider.userId;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Align(
                    alignment:
                        isSender ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSender ? Colors.blue[100] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            isSender
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
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
                              color:
                                  isSender
                                      ? Colors.blue[800]
                                      : Colors.grey[600],
                            ),
                          ),
                          Text(
                            formatearTiempoTranscurrido(
                              DateTime.parse(message['createdAt']),
                            ),
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
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
