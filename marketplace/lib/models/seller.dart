class Seller {
  final String id;
  final String name;
  final String email;

  Seller({
    required this.id,
    required this.name,
    required this.email,
  });

  // Método para convertir de JSON a objeto Seller
  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
    );
  }

  // Método para convertir de objeto Seller a JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
    };
  }
}