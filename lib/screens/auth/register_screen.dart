import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/phone_validation.dart';
import '../../utils/id_card_validation.dart'; // Importa la función de validación
import 'auth_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idCardController = TextEditingController(text: "V-"); // Valor predeterminado
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = false;

  Future<void> _register() async {
    String name = _nameController.text.trim();
    String idCard = _idCardController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String phone = _phoneController.text.trim();
    String address = _addressController.text.trim();

    if (password != confirmPassword) {
      _showErrorMessage('Las contraseñas no coinciden.');
      return;
    }

    // Validar el número de teléfono
    if (!validatePhoneNumber(phone)) {
      _showErrorMessage('Por favor, ingrese un número de teléfono válido.');
      return;
    }

    // Validar el idCard
    if (!validateIdCard(idCard)) {
      _showErrorMessage('Por favor, ingrese un número de cédula válido (V-12345678 o E-12345678).');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Guardar el usuario en Firestore
        await _saveUserToFirestore(user.uid, idCard, name, email, phone, address);

        // Enviar correo de verificación
        await user.sendEmailVerification();

        // Mostrar mensaje de éxito y esperar a que el usuario lo cierre
        await _showVerificationMessage();

        // Redirigir a AuthScreen después de que el usuario cierre el diálogo
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AuthScreen()),
        );
      }
    } catch (e) {
      _showErrorMessage(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserToFirestore(String uid, String idCard, String name, String email, String phone, String address) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'idCard': idCard,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'role': 'cliente', // cliente por defecto
    });
  }

  Future<void> _showErrorMessage(String message) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Aceptar'),
              ),
            ],
          );
        },
      );
    }

    Future<void> _showVerificationMessage() {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Verificación de correo'),
            content: Text('Se ha enviado un correo de verificación a tu dirección de correo electrónico. Por favor, verifica tu correo antes de iniciar sesión.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Aceptar'),
              ),
            ],
          );
        },
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Registro', style: TextStyle(color: Colors.white)),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.brown[600] ?? Colors.brown,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.brown[300] ?? Colors.brown, Colors.brown[100] ?? Colors.brown],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Crear cuenta',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildTextField(
                          controller: _nameController,
                          label: 'Nombre',
                          icon: Icons.person,
                        ),
                        SizedBox(height: 10),
                        _buildTextField(
                          controller: _idCardController,
                          label: 'Número de Identificación',
                          icon: Icons.credit_card,
                        ),
                        SizedBox(height: 10),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Correo Electrónico',
                          icon: Icons.email,
                        ),
                        SizedBox(height: 10),
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Contraseña',
                          icon: Icons.lock,
                          obscureText: true,
                        ),
                        SizedBox(height: 10),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirmar Contraseña',
                          icon: Icons.lock,
                          obscureText: true,
                        ),
                        SizedBox(height: 10),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Teléfono',
                          icon: Icons.phone,
                        ),
                        SizedBox(height: 10),
                        _buildTextField(
                          controller: _addressController,
                          label: 'Dirección',
                          icon: Icons.home,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.brown[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text('Crear cuenta'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Volver a la pantalla anterior
                          },
                          child: Text('Cancelar', style: TextStyle(color: Colors.brown[800])),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget _buildTextField({
      required TextEditingController controller,
      required String label,
      required IconData icon,
      bool obscureText = false,
    }) {
      return TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[300],
          prefixIcon: Icon(icon, color: Colors.brown[700]),
        ),
      );
    }
}
