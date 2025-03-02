import 'package:marketplace/models/product.dart';
import 'package:marketplace/core/services/product_service.dart';

class ProductRepository {
  final ProductService _productService = ProductService();

  // Obtener la lista de productos
  Future<List<Product>> fetchProducts() async {
    try {
      return await _productService.fetchProducts();
    } catch (error) {
      throw Exception('Failed to fetch products: $error');
    }
  }

  // Obtener los mensajes de chat de un producto
  Future<List<Map<String, dynamic>>> getChatMessages(String productId) async {
    try {
      return await _productService.getChatMessages(productId);
    } catch (error) {
      throw Exception('Failed to load chat messages: $error');
    }
  }

  // Obtener el nombre del vendedor
  Future<String> getNameSeller(String sellerId) async {
    try {
      return await _productService.getNameSeller(sellerId);
    } catch (error) {
      throw Exception('Failed to load seller name: $error');
    }
  }

  // Crear un nuevo producto
  Future<void> createProduct({
    required String name,
    required String description,
    required double price,
    required double latitude,
    required double longitude,
    required List<String> categories,
    required List<String> imagePaths,
    required String token,
  }) async {
    try {
      await _productService.createProduct(
        name: name,
        description: description,
        price: price,
        latitude: latitude,
        longitude: longitude,
        categories: categories,
        imagePaths: imagePaths,
        token: token,
      );
    } catch (error) {
      throw Exception('Failed to create product: $error');
    }
  }
}