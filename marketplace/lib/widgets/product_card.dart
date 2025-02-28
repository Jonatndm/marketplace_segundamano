import 'package:flutter/material.dart';
import '../models/product.dart';
import '../routes.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  final String baseUrl = 'http://192.168.100.3:5000';

  // Método para formatear las coordenadas
  String _formatCoordinates(List<double> coordinates) {
    if (coordinates.length >= 2) {
      return '${coordinates[1].toStringAsFixed(4)}, ${coordinates[0].toStringAsFixed(4)}';
    }
    return 'Ubicación no disponible';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.productDetail, arguments: product);
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child:
                  product.images.isNotEmpty
                      ? Image.network(
                        '$baseUrl/${product.images[0].replaceAll('\\', '/')}', // Usa la primera imagen
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
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
                        height: 120,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons
                              .image_not_supported, // Placeholder si no hay imágenes
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
            ),
            // Detalles del producto
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del producto
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 1,
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
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatCoordinates(product.location['coordinates']),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Categorías del producto
                  if (product.categories.isNotEmpty)
                    Wrap(
                      spacing: 4.0,
                      children:
                          product.categories.map((category) {
                            return Chip(
                              label: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 10,
                                ), // Tamaño de fuente reducido
                              ),
                              backgroundColor: Color.fromRGBO(6, 130, 255, 0.2),
                              materialTapTargetSize:
                                  MaterialTapTargetSize
                                      .shrinkWrap, // Reducir el tamaño del Chip
                              padding: EdgeInsets.symmetric(
                                horizontal: 4,
                              ), // Padding reducido
                            );
                          }).toList(),
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
