import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:marketplace/repository/opencage_repository.dart';
import '../../models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  // Mapa para almacenar en caché las direcciones
  static final Map<String, String> _addressCache = {};

  // Método para obtener la dirección desde el caché o hacer la solicitud
  Future<String> _getCachedAddress(double lat, double lng) async {
    final String cacheKey = '$lat,$lng';
    if (_addressCache.containsKey(cacheKey)) {
      return _addressCache[cacheKey]!;
    } else {
      final OpenCageRepository openCageRepository = OpenCageRepository();
      final address = await openCageRepository.getAddressFromCoordinates(lat, lng);
      _addressCache[cacheKey] = address;
      return address;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verifica si hay una sola imagen
            if (product.images.length == 1)
              Container(
                width: double.infinity,
                height: 250.0,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    product.images[0],
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                  ),
                ),
              )
            else
              carousel.CarouselSlider(
                options: carousel.CarouselOptions(
                  height: 250.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.9,
                  enableInfiniteScroll:
                      product.images.length >
                      1, // Deshabilita el desplazamiento infinito si hay una sola imagen
                ),
                items:
                    product.images.map((imageUrl) {
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
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image),
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
            Text(product.description, style: const TextStyle(fontSize: 16)),
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
                    children:
                        product.categories.map((category) {
                          return Chip(
                            label: Text(category),
                            backgroundColor: Color.fromRGBO(6, 130, 255, 0.2),
                          );
                        }).toList(),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Ubicación del producto
            FutureBuilder<String>(
              future: _getCachedAddress(
                product.location['coordinates'][1], // Latitud
                product.location['coordinates'][0], // Longitud
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ubicación:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              snapshot.data ?? 'Ubicación no disponible',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // Vendedor del producto
            Text(
              'Vendedor: ${product.seller?.name}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Botón para contactar al vendedor
            ElevatedButton(
              onPressed:
                  () =>
                      Navigator.pushNamed(context, '/chat', arguments: product),
              child: const Text('Contactar al Vendedor'),
            ),
          ],
        ),
      ),
    );
  }
}
