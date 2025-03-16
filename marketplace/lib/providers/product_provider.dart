import 'package:flutter/material.dart';
import 'package:marketplace/models/product.dart';
import 'package:marketplace/repository/product_repository.dart';

class ProductProvider with ChangeNotifier {
  final ProductRepository _productRepository = ProductRepository();
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar productos desde la API
  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _productRepository.fetchProducts();
    } catch (e) {
      _error = 'Error al cargar productos: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Agregar un nuevo producto (Corregido para evitar error de 'void')
  Future<void> addProduct(Product product) async {
    try {
      final newProduct = await _productRepository.createProduct(
        name: product.name,
        description: product.description,
        price: product.price,
        latitude: product.location['coordinates'][1],
        longitude: product.location['coordinates'][0],
        categories: product.categories,
        imagePaths: product.images,
        token: '', // Asegúrate de pasar el token correcto aquí
      );

      //_products.add(newProduct);
      notifyListeners();
    } catch (e) {
      _error = 'Error al agregar producto: ${e.toString()}';
      notifyListeners();
    }
  }

  // Actualizar un producto existente
  Future<void> updateProduct(Product product) async {
    try {
      await _productRepository.updateProduct(
        productId: product.id!,
        name: product.name,
        description: product.description,
        price: product.price,
        categories: product.categories,
        imagePaths: product.images,
        token: '', // Asegúrate de pasar el token correcto aquí
      );

      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error al actualizar producto: ${e.toString()}';
      notifyListeners();
    }
  }

  // Eliminar un producto
  Future<void> deleteProduct(String productId, String token) async {
    try {
      await _productRepository.deleteProduct(productId, token);
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar producto: ${e.toString()}';
      notifyListeners();
    }
  }
}
