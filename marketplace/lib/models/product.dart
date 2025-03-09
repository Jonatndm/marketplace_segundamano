import 'package:marketplace/models/seller.dart';
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> images;
  final Map<String, dynamic> location;
  final Seller? seller;
  final List<String> categories;
  final bool sold;
  final String? chat;
  final DateTime createdAt;

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
      seller: json['seller'] != null ? Seller.fromJson(json['seller']) : null,
      categories: List<String>.from(json['categories'] ?? []),
      sold: json['sold'] ?? false,
      chat: json['chat'] is String ? json['chat'] : json['chat']?['_id'],
      createdAt: DateTime.parse(json['createdAt']),
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
      'seller': seller?.toJson(),
      'categories': categories,
      'sold': sold,
      'chat': chat,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get timeSinceCreation {
  final DateTime now = DateTime.now();
  final Duration difference = now.difference(createdAt);

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