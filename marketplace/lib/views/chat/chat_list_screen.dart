import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:marketplace/providers/auth_provider.dart';
import 'package:marketplace/views/chat/chat_detail_screen.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});
  static const String baseUrl = 'http://localhost:5000';

  Future<List<dynamic>> fetchChats(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;


    if (token == null || token.isEmpty) {
      throw Exception('No autenticado');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/chat/user/chats'),
      headers: {
        'Authorization': 'Bearer $token', // Usa el token obtenido desde el provider
      },
    );

    if (response.statusCode == 200) {
      // Si el servidor responde correctamente, parseamos los datos
      final data = json.decode(response.body);
      return data; // Retornamos la lista de chats
    } else {
      // Si no hay respuesta exitosa
      throw Exception('Error al cargar los chats');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Chats'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchChats(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tienes chats aún.'));
          } else {
            final chats = snapshot.data!;
            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                final lastMessage = chat['messages'].isEmpty
                    ? 'No hay mensajes aún.'
                    : chat['messages'][0]['content'];

                final product = chat['product']; // Obtener el producto relacionado
                final productTitle = product['title'] ?? 'Producto desconocido';
                return ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: product['images'] != null && product['images'].isNotEmpty
                      ? Image.network(product['images'][0], width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 50),
                  title: Text(productTitle, style: TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lastMessage),
                      SizedBox(height: 4),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(chatId: chat['_id']),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
