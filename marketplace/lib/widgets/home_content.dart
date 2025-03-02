import 'package:flutter/material.dart';
import 'package:marketplace/models/product.dart';
import 'package:marketplace/repository/product_repository.dart';
import 'package:marketplace/widgets/product_card.dart';

class HomeContent extends StatelessWidget {
  HomeContent({super.key});
  
  final ProductRepository _productRepository = ProductRepository();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _productRepository.fetchProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar productos'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No hay productos disponibles'));
        }
        final products = snapshot.data!;

        return GridView.builder(
          padding: EdgeInsets.all(8.0), // Espaciado alrededor de la cuadrícula
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Número de columnas
            crossAxisSpacing: 8.0, // Espaciado horizontal entre elementos
            mainAxisSpacing: 8.0, // Espaciado vertical entre elementos
            childAspectRatio: 0.7, // Relación de aspecto (ancho/alto)
          ),
          itemCount: products.length,
          itemBuilder: (context, index) => ProductCard(product: products[index]),
        );
      },
    );
  }
}