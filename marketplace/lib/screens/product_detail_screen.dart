import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:marketplace/services/product_service.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final ProductService _productService = ProductService();

  ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  Widget _buildSellerWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vendedor:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        FutureBuilder<String>(
          future: _productService.getNameSeller(product.seller),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return Text(
                snapshot.data!,
                style: const TextStyle(fontSize: 16),
              );
            } else {
              return const Text('No se encontró el vendedor');
            }
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        automaticallyImplyLeading: false,
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            carousel.CarouselSlider(
              options: carousel.CarouselOptions(
                height: 250.0,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                viewportFraction: 0.9,
              ),
              items: product.images.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Nombre del producto
            Text(
              product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Precio del producto
            Text(
              'Precio: \$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
            const SizedBox(height: 8),

            // Descripción del producto
            Text(
              product.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Categorías del producto
            if (product.categories.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categorías:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8.0,
                    children: product.categories.map((category) {
                      return Chip(
                        label: Text(category),
                        backgroundColor: Colors.blue.withOpacity(0.2),
                      );
                    }).toList(),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            // Vendedor del producto
            _buildSellerWidget(),

            // Botón para contactar al vendedor
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/chat', arguments: product),
              child: const Text('Contactar al Vendedor'),
            ),
          ],
        ),
      ),
    );
  }
}