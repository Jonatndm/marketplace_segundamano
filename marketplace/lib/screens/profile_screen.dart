import 'package:flutter/material.dart';
import 'package:marketplace/models/user.dart';
import 'package:marketplace/providers/auth_provider.dart';
import 'package:marketplace/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final String token;

  const ProfileScreen({super.key, required this.userId, required this.token});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  late Future<User> _userFuture;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _userFuture = _userService.getUser(widget.userId, widget.token);
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearAuthData();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No se encontraron datos'));
          }

          final user = snapshot.data!;

          return Column(
            children: [
              // Sección de la imagen y nombre
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Círculo con la imagen del usuario
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(user.avatar ?? ""),
                    ),
                    const SizedBox(width: 16),
                    // Nombre del usuario
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Línea horizontal
              const Divider(height: 1, thickness: 1),
              // Opciones de perfil
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar Perfil'),
                onTap: () {
                  Navigator.pushNamed(context, '/edit-profile');
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_bag),
                title: const Text('Mis Productos Publicados'),
                onTap: () {
                  Navigator.pushNamed(context, '/my-products');
                },
              ),
              const Spacer(),
              // Botón de desloguearse
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
