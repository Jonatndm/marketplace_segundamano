import 'package:flutter/material.dart';
import 'package:marketplace/repository/auth_repository.dart';
import 'package:marketplace/routes.dart';
import 'package:pin_code_fields/pin_code_fields.dart'; // Importar el paquete OTP Field

class VerifyCodeScreen extends StatefulWidget {
  final String email;

  const VerifyCodeScreen({super.key, required this.email});

  @override
  VerifyCodeScreenState createState() => VerifyCodeScreenState();
}

class VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final TextEditingController codeController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;

  void _verifyCode() async {
    final code = codeController.text.trim();

    if (code.isEmpty || code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un código válido')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authRepository.verifyCode(widget.email, code);

      if (response != null) {
        Navigator.pushReplacementNamed(context, Routes.home);
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
            SizedBox(
              width: 300,
              child: Image.asset('assets/images/otp.jpg'),
            ),
            const SizedBox(height: 40),
            Container(
              alignment: Alignment.centerLeft,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Verificar Código',
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: PinCodeTextField(
                appContext: context,
                length: 6,
                controller: codeController,
                keyboardType: TextInputType.number,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10), 
                  fieldHeight: 50,
                  fieldWidth: 50,
                  activeFillColor: Colors.white,
                  inactiveFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  activeColor: Colors.black,
                  inactiveColor: Colors.grey,
                  selectedColor: Colors.blue, 
                ),
                onChanged: (value) {},
                onCompleted: (value) {
                  _verifyCode(); 
                },
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _verifyCode,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Verificar Código'),
                  ),
          ],
        ),
      ),
    );
  }
}