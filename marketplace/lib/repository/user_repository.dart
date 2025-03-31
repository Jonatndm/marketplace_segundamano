import 'package:image_picker/image_picker.dart';
import 'package:marketplace/models/user.dart';
import 'package:marketplace/core/services/user_service.dart';

class UserRepository {
  final UserService _userService = UserService();

  // Método para obtener los datos del usuario
  Future<User> getUser(String userId, String token) async {
    try {
      return await _userService.getUser(userId, token);
    } catch (error) {
      throw Exception('Error al obtener los datos del usuario: $error');
    }
  }

  Future<void> updateProfile(String userId, String name, String phone, String address, String bio, 
  XFile? avatarFile, String token) async {
    try {
      await _userService.updateProfile(userId, name, phone, address, bio, avatarFile, token);
    } catch (error) {
      throw Exception('Failed to update product: $error');
    }
  }
}