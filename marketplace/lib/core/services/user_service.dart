import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:marketplace/models/user.dart';

class UserService {
  static const String baseUrl = 'http://192.168.100.4:5000/api/profile';
  // static const String baseUrl = 'http://localhost:5000/api/profile';

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

  Future<void> updateProfile(
    String userId,
    String name,
    String phone,
    String address,
    String bio,
    XFile? avatarFile,
    String token,
  ) async {
    final uri = Uri.parse('$baseUrl/$userId');
    Map<String, String> headers = {"Authorization": "Bearer $token"};
    final request = http.MultipartRequest('PUT', uri);

    request.headers.addAll(headers);
    // Agregar campos de texto
    request.fields['name'] = name;
    request.fields['phone'] = phone;
    request.fields['address'] = address;
    request.fields['bio'] = bio;

    // Agregar archivo de imagen si existe
    if (avatarFile != null) {
      final file = await http.MultipartFile.fromPath('avatar', avatarFile.path);
      request.files.add(file);
    }

    // Enviar la solicitud
    final response = await request.send();

    if (response.statusCode == 200) {
      print('Perfil actualizado correctamente');
    } else {
      print(response.statusCode);
      print('Error al actualizar el perfil');
    }
  }
}
