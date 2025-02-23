import 'package:flutter/material.dart';
import 'package:marketplace/screens/product_publish.dart';
import 'package:marketplace/screens/profile_screen.dart';
import 'package:marketplace/widgets/home_content.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeContent(),
    PublishProductScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos de Segunda Mano'),
        automaticallyImplyLeading: false,
      ),
      body: _screens[_currentIndex], // Muestra la pantalla actual
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Índice seleccionado
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Cambia la pantalla al tocar un ícono
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Vender',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}