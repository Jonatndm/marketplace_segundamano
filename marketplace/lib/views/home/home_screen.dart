import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:marketplace/models/product.dart';
import 'package:marketplace/repository/product_repository.dart';
import 'package:marketplace/views/chat/chat_list_screen.dart';
import 'package:marketplace/views/product/product_publish.dart';
import 'package:marketplace/views/profile/profile_screen.dart';
import 'package:marketplace/widgets/home_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late Future<String?> _userIdFuture;
  late Future<String?> _tokenFuture;
  final ValueNotifier<String> _searchNotifier = ValueNotifier('');
  List<Product> _combinedProducts = [];

  Future<void> _loadProducts() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Los servicios de ubicación están desactivados.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Los permisos de ubicación fueron denegados.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Los permisos de ubicación están denegados permanentemente.');
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    );

    double lat = position.latitude;
    double long = position.longitude;
    final productRepository = ProductRepository();
    final nearbyProducts = await productRepository.fetchNearbyProducts(long, lat);

    final products = await productRepository.fetchProducts();

    final combinedProducts = [...{...nearbyProducts, ...products}];

    setState(() {
      _combinedProducts = combinedProducts;
    });
  }

  @override
  void initState() {
    super.initState();
    _userIdFuture = _getUserId();
    _tokenFuture = _getToken();
    _loadProducts();
  }

  // Método para obtener el userId desde SharedPreferences
  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Método para obtener el token desde SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar eliminado del Scaffold principal
      body: FutureBuilder(
        future: Future.wait([_userIdFuture, _tokenFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData ||
              snapshot.data![0] == null ||
              snapshot.data![1] == null) {
            return const Center(
              child: Text('No se encontraron datos de usuario'),
            );
          }

          final userId = snapshot.data![0]!;
          final token = snapshot.data![1]!;

          final List<Widget> screens = [
            HomeContent(searchQuery: _searchNotifier.value, products: _combinedProducts), // Pasa searchQuery
            PublishProductScreen(),
            ChatListScreen(),
            ProfileScreen(userId: userId, token: token),
          ];

          return screens[_currentIndex];
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Vender'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}