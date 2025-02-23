import 'package:flutter/material.dart';
import 'package:marketplace/providers/auth_provider.dart';
import 'package:provider/provider.dart'; // Importa el paquete provider
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/chat_screen.dart';
import 'routes.dart';
import './models/product.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Marketplace de Segunda Mano',
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          Routes.register: (context) => RegisterScreen(),
          Routes.home: (context) => HomeScreen(),
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
      ),
    );
  }
}