import 'package:flutter/material.dart';
import 'package:marketplace/models/product.dart';
import 'package:marketplace/widgets/product_card.dart';

class ProductSearchDelegate extends SearchDelegate<String> {
  final ValueNotifier<String> searchNotifier;
  final List<Product> products;

  ProductSearchDelegate({required this.searchNotifier, required this.products});

  List<Product> _filterProducts(String query) {
    final productos = products
        .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return productos;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredProducts = _filterProducts(query);
    return _buildProductList(filteredProducts);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text('Presiona "Enter" para buscar'),
    );
  }

  // Método para construir la lista de productos
  Widget _buildProductList(List<Product> products) {
    if (products.isEmpty) {
      return const Center(
        child: Text('No se encontraron productos'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Número de columnas
        crossAxisSpacing: 3.0, // Espaciado horizontal entre elementos
        mainAxisSpacing: 0.3, // Espaciado vertical entre elementos
        childAspectRatio: 0.57, // Relación de aspecto (ancho/alto)
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}