import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text('Aquí puedes ver y editar tu perfil.'),
      ),
    );
  }
}