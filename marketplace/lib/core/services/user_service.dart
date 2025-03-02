import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:marketplace/models/user.dart';

class UserService {
  // static const String baseUrl = 'http://192.168.100.3:5000/api/profile';
  static const String baseUrl = 'http://localhost:5000/api/profile';

  Future<User> getUser(String userId, String token) async {
    final url = Uri.parse('$baseUrl/$userId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // Verificar que el cuerpo de la respuesta no sea nulo
      if (response.body.isNotEmpty) {
        try {
          Map<String, dynamic> data = json.decode(response.body);

          // Verificar si la clave 'newUser' está presente en el mapa
          if (data.containsKey('newUser')) {
            return User.fromJson(data['newUser']);
          } else {
            throw Exception('La respuesta no contiene datos de usuario');
          }
        } catch (e) {
          throw Exception('Error al procesar los datos JSON: $e');
        }
      } else {
        throw Exception('Respuesta vacía del servidor');
      }
    } else {
      throw Exception(
        'Error al obtener los datos del usuario: ${response.statusCode}',
      );
    }
  }
}
