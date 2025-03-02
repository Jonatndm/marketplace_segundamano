import 'package:flutter/material.dart';
import 'package:marketplace/repository/auth_repository.dart';
import 'package:marketplace/routes.dart';
import 'package:marketplace/views/auth/forgot_password_screen.dart';
import 'package:marketplace/views/auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;

  void _login() async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authData = await _authRepository.login(email, password);
      if (authData != null) {
        // Navegar a la pantalla de inicio
        if (mounted) {
          Navigator.pushReplacementNamed(context, Routes.home);
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error en el login')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error en el login: $error')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MarketPlace de Segunda Mano"),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Topmost image
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Image.asset('assets/images/login.jpg'),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30.0,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    // Login Text
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Email and Password Fields
                    Form(
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              icon: const Icon(
                                Icons.alternate_email_outlined,
                                color: Colors.grey,
                              ),
                              labelText: 'Email',
                            ),
                            controller: emailController,
                          ),
                          TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
                              icon: const Icon(
                                Icons.lock_outline_rounded,
                                color: Colors.grey,
                              ),
                              labelText: 'Password',
                            ),
                            controller: passwordController,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 13),

                    // Forgot Password
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.indigo,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ForgotPasswordScreen();
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Login Button
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child:
                          _isLoading
                              ? CircularProgressIndicator()
                              : const Text(
                                "Login",
                                style: TextStyle(fontSize: 15),
                              ),
                    ),
                    const SizedBox(height: 15),
                    // Register button
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "New to the App? ",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          GestureDetector(
                            child: const Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.indigo,
                              ),
                            ),
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return RegisterScreen();
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
