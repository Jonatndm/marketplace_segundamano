import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:marketplace/models/product.dart';
import 'package:mime/mime.dart';

class ProductService {
  // static const String baseUrl = 'http://localhost:5000/api';
  static const String baseUrl = 'http://192.168.4.21:5000/api';

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

  Future<List<Product>> fetchNearbyProducts(double long, double lat) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/Nearby?longitude=$long&latitude=$lat'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> productsData = data['products'];
      return productsData.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Fallo al obtener productos cercanos');
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
    required List<String> imagePaths,
    required String token,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/products'),
      )..headers['Authorization'] = 'Bearer $token';

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
          'images',
          imagePath,
          contentType: MediaType(
            'image',
            'jpeg',
          ), // Ajusta el tipo MIME según el formato de la imagen
        );
        request.files.add(file);
      }

      var response = await request.send();

      if (response.statusCode == 201) {
      } else {
        var responseBody = await response.stream.bytesToString();
        throw Exception(
          'Error al crear el producto: ${response.statusCode} - $responseBody',
        );
      }
    } catch (error) {
      throw Exception('Error al enviar la solicitud: $error');
    }
  }

  Future<List<Product>> fetchUserProducts(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/user/$userId'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> productsData = data['products'];
      return productsData.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load user products');
    }
  }

  Future<Product> getProductById(String productId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/$productId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      dynamic productsData = data['products'];
      return Product.fromJson(productsData);
    } else {
      throw Exception('Failed to load user products');
    }
  }

  Future<void> markProductAsSold(String productId, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$productId/sold'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Producto marcado como vendido exitosamente
      return;
    } else {
      throw Exception('Failed to mark product as sold: ${response.statusCode}');
    }
  }

  Future<void> deleteProduct(String productId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$productId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // Producto eliminado exitosamente
      return;
    } else {
      throw Exception('Failed to delete product: ${response.statusCode}');
    }
  }

  Future<void> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required List<String> categories,
    required List<String>
    imagePaths, // Contiene imágenes nuevas y URLs de imágenes que se mantienen
    required String token,
  }) async {
    try {
      // 1️⃣ Filtrar imágenes nuevas y URLs
      List<String> newImages =
          imagePaths.where((path) => !path.startsWith('http')).toList();
      List<String> existingImageUrls =
          imagePaths.where((path) => path.startsWith('http')).toList();

      // 2️⃣ Crear la solicitud
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/products/$productId'),
      )..headers['Authorization'] = 'Bearer $token';

      // 3️⃣ Agregar datos del formulario
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['price'] = price.toString();
      request.fields['categories'] = categories.join(',');

      // 4️⃣ Agregar imágenes nuevas
      for (var imagePath in newImages) {
        var mimeType = lookupMimeType(imagePath) ?? 'image/jpeg';
        var file = await http.MultipartFile.fromPath(
          'images',
          imagePath,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(file);
      }

      // 5️⃣ Enviar las imágenes existentes como URLs
      request.fields['existingImages'] = existingImageUrls.join(',');

      // 6️⃣ Enviar la solicitud
      var response = await request.send();

      if (response.statusCode == 200) {
        print("✅ Producto actualizado con éxito");
      } else {
        var responseBody = await response.stream.bytesToString();
        throw Exception(
          '❌ Error al actualizar: ${response.statusCode} - $responseBody',
        );
      }
    } catch (error) {
      throw Exception('❌ Error al actualizar producto: $error');
    }
  }
}
