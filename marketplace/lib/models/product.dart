import 'package:marketplace/models/seller.dart';
import 'package:intl/intl.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> images;
  final Map<String, dynamic> location;
  final Seller seller;
  final List<String> categories;
  final bool sold;
  final String? chat;
  final String createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.location,
    required this.seller,
    required this.categories,
    this.sold = false,
    this.chat,
    required this.createdAt
  });

  // Método para convertir de JSON a objeto Product
  factory Product.fromJson(Map<String, dynamic> json) {

      // Formatear la fecha a dd/MM/yyyy
      final DateTime parsedDate = DateTime.parse(json['createdAt']);
      final String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);

    return Product(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      location: {
        'type': json['location']['type'] ?? 'Point',
        'coordinates': List<double>.from(json['location']['coordinates']?.map((e) => e.toDouble()) ?? [0.0, 0.0]),
      },
      seller: Seller.fromJson(json['seller']),
      categories: List<String>.from(json['categories'] ?? []),
      sold: json['sold'] ?? false,
      chat: json['chat'] is String ? json['chat'] : json['chat']?['_id'],
      createdAt: formattedDate,
    );
  }
  // Método para convertir de objeto Product a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'images': images,
      'location': location,
      'seller': seller.toJson(),
      'categories': categories,
      'sold': sold,
      'chat': chat,
      'createdAt': createdAt,
    };
  }

  String get timeSinceCreation {
    // Convertir createdAt a DateTime
    final DateFormat format = DateFormat('dd/MM/yyyy');
    final DateTime creationDate = format.parse(createdAt);

    // Obtener la fecha actual
    final DateTime now = DateTime.now();

    // Calcular la diferencia
    final Duration difference = now.difference(creationDate);

    // Formatear la diferencia
    if (difference.inDays > 0) {
      return 'Publicado hace: ${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return 'Publicado hace: ${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return 'Publicado hace: ${difference.inMinutes} minutos';
    } else {
      return 'Publicado hace: unos segundos';
    }
  }

  // Sobrescribir el método ==
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  // Sobrescribir el método hashCode
  @override
  int get hashCode => id.hashCode;
}