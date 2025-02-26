import 'package:flutter/material.dart';

class PublishProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Publicar Producto'),
      automaticallyImplyLeading: false,),
      body: Center(
        child: Text('Formulario para publicar un producto'),
      ),
    );
  }
}