import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/product.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';

class ChatScreen extends StatefulWidget {
  final Product product;

  const ChatScreen({Key? key, required this.product}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late io.Socket socket;
  List<Map<String, dynamic>> messages = []; // Lista de mensajes
  final AuthService _authService = AuthService();
  final ProductService _productService = ProductService();
  String? userId;

  @override
  void initState() {
    super.initState();
    _connectToSocket();
    _loadMessages();
    _loadUserId(); // Cargar mensajes al iniciar la pantalla
  }

  void _loadUserId() async {
    final id = await _authService.getUserId();
    setState(() {
      userId = id; // Guardar el userId en el estado
    });
  }
  void _connectToSocket() {
    socket = io.io(
      'http://localhost:5000',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();
    socket.onConnectError((error) {
      print('Error de conexión: $error');
    });

    // Manejar desconexiones
    socket.onDisconnect((_) {
      print('Desconectado del WebSocket');
    });

    if (userId != null) {
      socket.emit('message', {
        // Usar 'message' como evento
        'type': 'authenticate', // Campo requerido por el backend
        'userId': userId, // ID del usuario
      });
    }

    // Unirse a la sala del producto
    socket.emit('joinRoom', widget.product.id);

    // Escuchar mensajes entrantes
    socket.on('chat', (data) {
      setState(() {
        messages.add(data); // Agregar el mensaje a la lista
      });
    });
  }

  void _loadMessages() async {
    try {
      // Obtener los mensajes anteriores desde el backend
      final chatMessages = await _productService.getChatMessages(widget.product.id);
      setState(() {
        messages = chatMessages; // Cargar mensajes en la lista
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los mensajes: $error')),
      );
    }
  }



  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final message = _messageController.text;
      // Enviar el mensaje al servidor
      socket.emit('message', {
        'type': 'chat', // Campo requerido por el backend
        'room': widget.product.id, // ID del producto (room)
        'message': message, // Contenido del mensaje
        'sender': userId, // ID del remitente
      });

      // Agregar el mensaje a la lista local
      setState(() {
        messages.add({
          'sender': userId,
          'message': message,
        });
      });

      _messageController.clear();
    }
  }

  @override
  void dispose() {
    socket.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat sobre ${widget.product.name}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message['sender'] == userId; // Verificar si el mensaje es del usuario actual

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, // Alinear a la derecha o izquierda
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey[300], // Color diferente para el remitente
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message['message'],
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black, // Color del texto
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
                    decoration: const InputDecoration(hintText: 'Escribe un mensaje...'),
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