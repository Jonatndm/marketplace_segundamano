import 'package:flutter/material.dart';
import 'package:marketplace/repository/auth_repository.dart';
import 'reset_password_screen.dart';

class EnterResetCodeScreen extends StatefulWidget {
  final String email;

  const EnterResetCodeScreen({super.key, required this.email});

  @override
  EnterResetCodeScreenState createState() => EnterResetCodeScreenState();
}

class EnterResetCodeScreenState extends State<EnterResetCodeScreen> {
  final TextEditingController codeController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;

  Future<void> verifyResetCode() async {
    final code = codeController.text.trim();

    if (code.isEmpty || code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un código válido')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isValid = await _authRepository.verifyResetCode(widget.email, code);
      if (isValid) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    ResetPasswordScreen(email: widget.email, code: code),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código inválido o expirado')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $error')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 90),
            SizedBox(width: 300, child: Image.asset('assets/images/otp.jpg')),
            const SizedBox(height: 40),
            Container(
              alignment: Alignment.centerLeft,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Enter OTP',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Un código de 6 dígitos ha sido enviado a \n${widget.email}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                controller: codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromRGBO(247, 247, 247, 1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Ingresa el código',
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: verifyResetCode,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Verificar código'),
                ),
          ],
        ),
      ),
    );
  }
}
