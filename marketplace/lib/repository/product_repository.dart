import 'dart:async';

import 'package:marketplace/models/product.dart';
import 'package:marketplace/core/services/product_service.dart';

class ProductRepository {
  final ProductService _productService = ProductService();

  // Obtener la lista de productos
  Future<List<Product>> fetchProducts() async {
    try {
      return await _productService.fetchProducts();
    } catch (error) {
      print('Error al obtener productos: $error');
      return [];
    }
  }

  Future<List<Product>> fetchNearbyProducts(double long, double lat) async {
    try {
      return await _productService.fetchNearbyProducts(long, lat);
    } catch (error) {
      throw Exception('Fallo al obtener los productos cercanos: $error');
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

  Future<List<Product>> fetchUserProducts(String userId) async {
    try {
      return await _productService.fetchUserProducts(userId);
    } catch (error) {
      throw Exception('Failed to fetch user products: $error');
    }
  }

  Future<void> markProductAsSold(String productId, String token) async {
    try {
      await _productService.markProductAsSold(productId, token);
    } catch (error) {
      throw Exception('Failed to mark product as sold: $error');
    }
  }

  Future<void> deleteProduct(String productId, String token) async {
    try {
      await _productService.deleteProduct(productId, token);
    } catch (error) {
      throw Exception('Failed to delete product: $error');
    }
  }

  Future<void> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required List<String> categories,
    required List<String> imagePaths,
    required String token,
  }) async {
    try {
      await _productService.updateProduct(
        productId: productId,
        name: name,
        description: description,
        price: price,
        categories: categories,
        imagePaths: imagePaths,
        token: token,
      );
    } catch (error) {
      throw Exception('Failed to update product: $error');
    }
  }

   Future<String> getOrCreateChat(
    String productId,
    String sellerId,
    String token,
  ) async
  {
    try{
      return await _productService.getOrCreateChat(productId, sellerId, token);
    }
    catch(error){
      throw Exception('Error al crear o obtener chat');
    }
  }
}
