import 'package:flutter/material.dart';

class MyProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Productos'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text('Aquí puedes ver los productos que has publicado.'),
      ),
    );
  }
}