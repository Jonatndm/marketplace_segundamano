import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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

  Future<void> createProduct({
    required String name,
    required String description,
    required double price,
    required double latitude,
    required double longitude,
    required List<String> categories,
    required List<String> imagePaths, // Rutas de las imágenes
    required String token, // Token de autenticación
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/products'))
        ..headers['Authorization'] = 'Bearer $token';

      // Agregar campos del formulario
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['price'] = price.toString();
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      request.fields['categories'] = categories.join(',');

      // Agregar imágenes
      for (var imagePath in imagePaths) {
        var file = await http.MultipartFile.fromPath(
          'images', // Nombre del campo en el backend
          imagePath,
          contentType: MediaType('image', 'jpeg'), // Ajusta el tipo MIME según el formato de la imagen
        );
        request.files.add(file);
      }

      // Enviar la solicitud
      var response = await request.send();

      // Verificar la respuesta
      if (response.statusCode == 201) {
      } else {
        var responseBody = await response.stream.bytesToString();
        throw Exception('Error al crear el producto: ${response.statusCode} - $responseBody');
      }
    } catch (error) {
      throw Exception('Error al enviar la solicitud: $error');
    }
  }
}
