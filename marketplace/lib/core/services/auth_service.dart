import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:5000/api/auth';
  // static const String baseUrl = 'http://192.168.100.3:5000/api/auth';

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];

        final userId = data['userId']; // Obtener el userId desde la respuesta
        return {'token': token, 'userId': userId};
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> register(String name, String email, String password,) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'email': email, 'password': password}),
      );
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'token': data['token'],
          'userId': data['userId'],
        };
      } 
      else {
        // Si hay un error, lanza una excepción con el mensaje de error
        throw Exception();
      }
    } 
    catch (error) {
      // Maneja errores de conexión o del servidor
      throw Exception('Error de conexión: $error');
    }
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
