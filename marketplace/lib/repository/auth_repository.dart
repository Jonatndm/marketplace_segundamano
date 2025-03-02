import 'package:marketplace/core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final authData = await _authService.login(email, password);
      if (authData != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', authData['token']);
        await prefs.setString('userId', authData['userId']);
        return authData;
      }
      return null;
    } 
    catch (error) {
      throw Exception('Error en el login: $error');
    }
  }

  Future<Map<String, dynamic>?> register(String name, String email, String password,) async {
    try {
      final authData = await _authService.register(name, email, password);
      if (authData != null) {
        // Guardar en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', authData['token']);
        await prefs.setString('userId', authData['userId']);
        return authData;
      }
      return null;
    } 
    catch (error) {
      throw Exception('Error al registrarse: $error');
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
  }
}