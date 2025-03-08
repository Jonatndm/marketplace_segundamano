import 'package:flutter/material.dart';
import 'package:marketplace/core/utils/validations.dart';
import 'package:marketplace/repository/auth_repository.dart';
import 'package:marketplace/views/auth/verify_code_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      setState(() => _isLoading = true);

      try {
        final response = await _authRepository.register(name, email, password);

        if (response != null) {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerifyCodeScreen(email: email),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error en el registro')));
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $error')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registrarse")),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Imagen al inicio
            Container(
              height: MediaQuery.of(context).size.height / 3,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Image.asset('assets/images/signup.jpg'),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 10,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Campo para el nombre completo
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        icon: const Icon(
                          Icons.person_outline,
                          color: Colors.grey,
                        ),
                        labelText: 'Nombre completo',
                      ),
                      validator:
                          (value) => Validators.validateRequired(
                            value,
                            'nombre completo',
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Campo para el correo electrónico
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        icon: const Icon(
                          Icons.alternate_email_outlined,
                          color: Colors.grey,
                        ),
                        labelText: 'Email',
                      ),
                      validator: (value) => Validators.validateEmail(value),
                    ),
                    const SizedBox(height: 16),

                    // Campo para la contraseña
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        icon: const Icon(
                          Icons.lock_outline_rounded,
                          color: Colors.grey,
                        ),
                        labelText: 'Contraseña',
                      ),
                      validator: (value) => Validators.validatePassword(value),
                    ),
                    const SizedBox(height: 16),

                    // Campo para confirmar la contraseña
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        icon: const Icon(
                          Icons.lock_outline_rounded,
                          color: Colors.grey,
                        ),
                        labelText: 'Confirmar contraseña',
                      ),
                      validator: (value) {
                        if (value != passwordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Términos y condiciones
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: GestureDetector(
                          child: const Text(
                            'Al registrarte, aceptas nuestros Términos y condiciones y Política de privacidad.',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          onTap: () {
                            // Navegar a la página de términos y condiciones
                          },
                        ),
                      ),
                    ),

                    // Botón de registro
                    ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.indigo
                      ),
                      child:
                          _isLoading
                              ? CircularProgressIndicator() // Indicador de carga
                              : const Center(
                                child: Text(
                                  "Registrarse",
                                  style: TextStyle(fontSize: 15, color: Colors.white),
                                ),
                              ),
                    ),

                    const SizedBox(height: 25),

                    // Enlace para volver al login
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Ya se ha unido antes? ",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          GestureDetector(
                            child: const Text(
                              "Ingresa",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.indigo,
                              ),
                            ),
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
