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
    } catch (error) {
      throw Exception('Error en el login: $error');
    }
  }

  Future<String?> register(String name, String email, String password) async {
    try {
      final response = await _authService.register(name, email, password);
      if (response) {
        return 'Registro exitoso. Verifica tu correo para completar el proceso.';
      }
      return null;
    } catch (error) {
      throw Exception('Error en el registro: $error');
    }
  }

  Future<Map<String, dynamic>?> verifyCode(String email, String code) async {
    try {
      final authData = await _authService.verifyCode(email, code);
      if (authData != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', authData['token']);
        await prefs.setString('userId', authData['userId']);
        return authData;
      }
      return null;
    } catch (error) {
      throw Exception('Error al verificar código: $error');
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    return await _authService.requestPasswordReset(email);
  }

  Future<bool> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    return await _authService.resetPassword(email, code, newPassword);
  }

  Future<bool> verifyResetCode(String email, String code) async {
    return await _authService.verifyResetCode(email, code);
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
