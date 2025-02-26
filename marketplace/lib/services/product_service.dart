import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:marketplace/models/product.dart';

class ProductService {
  static const String baseUrl = 'http://192.168.4.30:5000/api';

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> productsData = data['products'];
      return productsData.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<List<Map<String, dynamic>>> getChatMessages(String productId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/$productId/chat'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['chat']);
    } else {
      throw Exception('Error al cargar los mensajes');
    }
  }

  Future<String> getNameSeller(String sellerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/seller/$sellerId'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('user') && data['user'] != null) {
        // Extrae el nombre del vendedor del objeto 'user'
        String sellerName = data['user']['name'];
        return sellerName;
      } else {
        throw Exception('User data not found in response');
      }
    } else {
      throw Exception('Failed to load seller data');
    }
  }
}
