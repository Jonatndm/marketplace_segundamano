import 'package:flutter/material.dart';
import 'package:marketplace/models/product.dart';
import 'package:marketplace/views/product/product_search_delegate.dart';
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

    return Scaffold(
      // AppBar movido aquí
      appBar: AppBar(
        title: const Text('Productos', style: TextStyle(fontSize: 26)),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(
                  searchNotifier: ValueNotifier(searchQuery),
                  products: products,
                ),
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Número de columnas
          crossAxisSpacing: 3.0, // Espaciado horizontal entre elementos
          mainAxisSpacing: 0.3, // Espaciado vertical entre elementos
          childAspectRatio: 0.57, // Relación de aspecto (ancho/alto)
        ),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) => ProductCard(product: filteredProducts[index]),
      ),
    );
  }
}