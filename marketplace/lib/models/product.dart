class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> images;
  final Map<String, dynamic> location;
  final String seller;
  final List<String> categories;
  final bool sold;
  final String? chat; 

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
    seller: json['seller'] is String ? json['seller'] : json['seller']['_id'],
    categories: List<String>.from(json['categories'] ?? []),
    sold: json['sold'] ?? false,
    chat: json['chat'] is String ? json['chat'] : json['chat']?['_id'],
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
      'seller': seller,
      'categories': categories,
      'sold': sold,
      'chat': chat,
    };
  }
}