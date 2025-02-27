class User {
  final String id;
  final String name;
  final String email;
  final String password;

  final String? phone;
  final String? address;
  final String? avatar;
  final String? bio;

  final String? resetPasswordToken;
  final DateTime? resetPasswordExpire;

  final List<String> favorites; // Lista de IDs de productos favoritos
  final List<String> purchases; // Lista de IDs de productos comprados
  final List<String> sales; // Lista de IDs de productos vendidos

  final List<String> chats; // Lista de IDs de chats
  final List<Notification> notifications; // Lista de notificaciones

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.address,
    this.avatar,
    this.bio,
    this.resetPasswordToken,
    this.resetPasswordExpire,
    this.favorites = const [],
    this.purchases = const [],
    this.sales = const [],
    this.chats = const [],
    this.notifications = const [],
  });

  // Método para convertir de JSON a objeto User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      phone: json['phone'],
      address: json['address'],
      avatar: json['avatar'],
      bio: json['bio'],
      resetPasswordToken: json['resetPasswordToken'],
      resetPasswordExpire:
          json['resetPasswordExpire'] != null
              ? DateTime.parse(json['resetPasswordExpire'])
              : null,
      favorites: List<String>.from(json['favoritesSales'] ?? []),
      purchases: List<String>.from(json['purchases'] ?? []),
      sales: List<String>.from(
        json['salesPublish'] ?? [],
      ), // Usa salesPublish en lugar de sales
      chats: List<String>.from(json['chats'] ?? []),
      notifications: List<Notification>.from(
        json['notifications']?.map((x) => Notification.fromJson(x)) ?? [],
      ),
    );
  }

  // Método para convertir de objeto User a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
      'avatar': avatar,
      'bio': bio,
      'resetPasswordToken': resetPasswordToken,
      'resetPasswordExpire': resetPasswordExpire?.toIso8601String(),
      'favorites': favorites,
      'purchases': purchases,
      'sales': sales,
      'chats': chats,
      'notifications': notifications.map((x) => x.toJson()).toList(),
    };
  }
}

class Notification {
  final String message;
  final bool isRead;
  final DateTime createdAt;

  Notification({
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  // Método para convertir de JSON a objeto Notification
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      message: json['message'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Método para convertir de objeto Notification a JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
