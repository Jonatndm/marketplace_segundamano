import 'package:flutter/material.dart';
import 'package:marketplace/repository/opencage_repository.dart';
import '../models/product.dart';
import '../routes.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});
  static final Map<String, String> _addressCache = {};

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
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.productDetail, arguments: product);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16), // Margen inferior para separar los productos
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto (ocupa todo el ancho)
            product.images.isNotEmpty
                ? Image.network(
                    product.images[0],
                    height: 200, // Altura fija para la imagen
                    width: double.infinity, // Ocupa todo el ancho disponible
                    fit: BoxFit.cover, // Ajusta la imagen para cubrir el espacio
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 40,
                        ),
                      );
                    },
                  )
                : Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
            // Detalles del producto
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiempo desde la creación
                  Text(
                    product.timeSinceCreation,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Nombre del producto
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1, // Limita el nombre a una línea
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Precio del producto
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
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
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                snapshot.data ?? 'Ubicación no disponible',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 2, // Limita la ubicación a dos líneas
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}