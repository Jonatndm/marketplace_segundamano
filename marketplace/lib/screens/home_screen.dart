import 'package:flutter/material.dart';
import 'package:marketplace/screens/chat_list_screen.dart';
import 'package:marketplace/screens/product_publish.dart';
import 'package:marketplace/screens/profile_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _userIdFuture = _getUserId();
    _tokenFuture = _getToken();
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
      appBar: AppBar(
        title: const Text('Productos de Segunda Mano'),
        automaticallyImplyLeading: false,
      ),
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

          final List<Widget> _screens = [
            HomeContent(),
            PublishProductScreen(),
            ChatListScreen(),
            ProfileScreen(userId: userId, token: token), // Pasa los parámetros
          ];

          return _screens[_currentIndex];
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
