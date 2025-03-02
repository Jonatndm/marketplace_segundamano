import 'package:flutter/material.dart';
import 'package:marketplace/core/utils/validations.dart';
import 'package:marketplace/repository/auth_repository.dart';
import 'package:marketplace/routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>(); // Clave para el formulario

  void _register() async {
    if (_formKey.currentState!.validate()) { // Validar el formulario
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      setState(() => _isLoading = true); // Activar el estado de carga

      try {
        final authData = await _authRepository.register(name, email, password);
        if (authData != null) {
          // Navegar a la pantalla de inicio
          if (mounted) {
            Navigator.pushReplacementNamed(context, Routes.home);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error en el registro')),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error en el registro: $error')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false); // Desactivar el estado de carga
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registrarse")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo para el nombre
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) => Validators.validateRequired(value, 'nombre'),
              ),
              SizedBox(height: 16),

              // Campo para el correo electrónico
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => Validators.validateEmail(value),
              ),
              SizedBox(height: 16),

              // Campo para la contraseña
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => Validators.validatePassword(value),
              ),
              SizedBox(height: 20),

              // Botón de registro
              _isLoading
                  ? CircularProgressIndicator() // Mostrar indicador de carga
                  : ElevatedButton(
                      onPressed: _register,
                      child: Text('Registrarse'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}