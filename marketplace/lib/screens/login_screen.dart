import 'package:flutter/material.dart';
import 'package:marketplace/providers/auth_provider.dart';
import 'package:marketplace/services/auth_service.dart';
import 'package:marketplace/routes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  void _login() async {
    final email = emailController.text;
    final password = passwordController.text;

    final authData = await _authService.login(email, password);
    if (authData != null) {
      final token = authData['token'];
      final userId = authData['userId'];

      // Guardar en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('userId', userId);

      // Guardar en el AuthProvider
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.setAuthData(token, userId);
      }

      // Navegar a la pantalla de inicio
      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.home);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context,).showSnackBar(SnackBar(content: Text('Error en el login')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login"), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text('Iniciar Sesión')),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, Routes.register),
              child: Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}
