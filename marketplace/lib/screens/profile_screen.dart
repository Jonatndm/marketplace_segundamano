import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
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