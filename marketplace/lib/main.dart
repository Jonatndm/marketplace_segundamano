import 'package:flutter/material.dart';
import 'package:marketplace/providers/auth_provider.dart';
import 'package:marketplace/views/product/my_products.dart';
import 'package:marketplace/views/profile/profile_edit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/auth/login_screen.dart';
import 'views/home/home_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/product/product_detail_screen.dart';
import 'views/chat/chat_screen.dart';
import 'routes.dart';
import './models/product.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final userId = prefs.getString('userId');
  // await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MainApp(
        isLoggedIn: token != null && userId != null,
        authData:
            token != null && userId != null
                ? {'token': token, 'userId': userId}
                : null,
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;
  final Map<String, String>? authData;

  const MainApp({super.key, required this.isLoggedIn, this.authData});

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn && authData != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.setAuthData(authData!['token']!, authData!['userId']!);
    }

    return MaterialApp(
      title: 'Marketplace de Segunda Mano',
      debugShowCheckedModeBanner: false,
      initialRoute: isLoggedIn ? Routes.home : '/',
      routes: {
        '/': (context) => LoginScreen(),
        Routes.register: (context) => RegisterScreen(),
        Routes.home: (context) => HomeScreen(),
        Routes.myProducts: (context) => MyProductsScreen(),
        Routes.perfilEdit: (context) => ProfileEdit(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == Routes.productDetail) {
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          );
        } else if (settings.name == Routes.chat) {
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (context) => ChatScreen(product: product),
          );
        }
        return null;
      },
    );
  }
}
