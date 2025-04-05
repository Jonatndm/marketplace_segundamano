import 'package:flutter/material.dart';
import 'package:marketplace/models/user.dart';
import 'package:marketplace/providers/auth_provider.dart';
import 'package:marketplace/repository/user_repository.dart';
import 'package:marketplace/routes.dart';
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
  final UserRepository _userRepository = UserRepository();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    setState(() {
      _userFuture = _userRepository.getUser(widget.userId, widget.token);
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('tokenTimestamp');

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
      body: Column(
        children: [
          // Sección de la imagen y nombre (cargada dinámicamente)
          FutureBuilder<User>(
            future: _userFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(width: 16),
                      Container(
                        height: 20,
                        width: 100,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('No se encontraron datos'));
              }

              final user = snapshot.data!;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
                              ? NetworkImage(user.avatar!)
                              : const AssetImage('assets/images/avatar-default.jpg') as ImageProvider,
                        ),
                        const SizedBox(width: 16),
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
                  const Divider(height: 1, thickness: 1),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Editar Perfil'),
                    onTap: () async {
                      // Esperar el resultado de la navegación
                      final result = await Navigator.pushNamed(
                        context,
                        Routes.perfilEdit,
                        arguments: {
                          'user': user,
                          'token': widget.token,
                        },
                      );
                      
                      // Si se actualizó el perfil, recargar los datos
                      if (result == true) {
                        _loadUserData();
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.shopping_bag),
                    title: const Text('Mis Productos Publicados'),
                    onTap: () {
                      Navigator.pushNamed(context, '/my-products');
                    },
                  ),
                ],
              );
            },
          ),
          const Spacer(),
          // Botón de cerrar sesión (siempre visible)
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
                  backgroundColor: Colors.red
                ),
                child: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}