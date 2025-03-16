import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String baseUrl = 'http://localhost:5000/api';

  Future<List<Map<String, dynamic>>> getChatMessages(String productId) async {
    final response = await http.get(Uri.parse('$baseUrl/chat/$productId'));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Error al obtener los mensajes del chat');
    }
  }

  Future<void> sendMessage(
    String productId,
    String userId,
    String message,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/$productId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'sender': userId, 'message': message}),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al enviar el mensaje');
    }
  }
}
