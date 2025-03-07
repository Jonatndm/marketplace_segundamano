import 'package:flutter/material.dart';
import 'package:marketplace/models/product.dart';
import 'package:marketplace/widgets/product_card.dart';

class HomeContent extends StatelessWidget {
  final String searchQuery;
  final List<Product> products;

  const HomeContent({super.key, required this.searchQuery, required this.products});

  @override
  Widget build(BuildContext context) {
    // Filtrar productos basados en searchQuery
    final filteredProducts = products
        .where((product) =>
            product.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    if (filteredProducts.isEmpty) {
      return const Center(child: Text('No se encontraron productos'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Número de columnas
        crossAxisSpacing: 8.0, // Espaciado horizontal entre elementos
        mainAxisSpacing: 8.0, // Espaciado vertical entre elementos
        childAspectRatio: 0.7, // Relación de aspecto (ancho/alto)
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) => ProductCard(product: filteredProducts[index]),
    );
  }
}