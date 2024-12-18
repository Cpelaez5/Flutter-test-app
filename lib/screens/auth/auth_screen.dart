import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Asegúrate de importar Firestore
import 'reset_password_screen.dart'; // Asegúrate de importar la pantalla de restablecimiento
import 'register_screen.dart'; // Asegúrate de importar la pantalla de registro

class AuthScreen extends StatefulWidget {
  final String? verificationMessage; // Agregar el parámetro opcional

  AuthScreen({this.verificationMessage}); // Constructor

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _emailError = false;
  bool _passwordError = false;

 Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _emailError = email.isEmpty;
      _passwordError = password.isEmpty;
    });

    if (_emailError || _passwordError) {
      _showSnackBar('Por favor, completa todos los campos.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      User? user = await authService.signIn(email, password);
      if (user != null) {
        // Verificar si el correo electrónico está verificado
        if (!user.emailVerified) {
          _showSnackBar('Por favor, verifica tu correo electrónico antes de iniciar sesión.');
          return;
        }

        // Verificar el estado del usuario en Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        
        if (userDoc.exists && userDoc.data() != null) {
          var userData = userDoc.data() as Map<String, dynamic>;
          print("User  data: $userData"); // Imprimir los datos del usuario para depuración
          
          // Manejo del campo 'status'
          String userStatus = userData['status']?.toString().trim() ?? ''; // Asegúrate de que no sea nulo y quita espacios
          print("User  status: $userStatus"); // Imprimir el estado del usuario para depuración

          // Verificar si el estado es "blocked"
          if (userStatus.toLowerCase() == 'blocked' || userStatus.toLowerCase() != 'active') { // Comparar en minúsculas para evitar problemas de capitalización
            _showSnackBar('Tu cuenta está bloqueada. Contacta al soporte.');
            return; // Asegúrate de que el flujo se detenga aquí
          }
        } else {
          _showSnackBar('No se encontró información del usuario.');
          return;
        }

        // Si el correo está verificado y el estado no es "blocked", navega a la pantalla principal
        if (mounted) { // Verifica si el widget aún está montado
          Navigator.of(context).pushReplacementNamed('/home'); // Cambia '/home' por la ruta de tu pantalla principal
        }
      }
    } catch (error) {
      print('Error: $error');
      String message = 'Error al autenticar. Por favor, verifica tus credenciales.';
      
      if (error is FirebaseAuthException) {
        switch (error.code) {
          case 'user-not-found':
            message = 'No hay ningún usuario registrado con este correo.';
            break;
          case 'wrong-password':
            message = 'La contraseña es incorrecta.';
            break;
          case 'invalid-email':
            message = 'El correo electrónico no es válido.';
            break;
          default:
            message = 'Error desconocido. Intenta de nuevo.';
        }
      }

      if (mounted) { // Verifica si el widget aún está montado
        _showSnackBar(message);
      }
    } finally {
      if (mounted) { // Verifica si el widget aún está montado
        setState(() {
          _isLoading = false;
        });
      }
    }
}

  void _showSnackBar(String message) {
    if (mounted) { // Verifica si el widget aún está montado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Navegar a la pantalla de restablecimiento de contraseña
  void _navigateToResetPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
    );
  }

  // Navegar a la pantalla de registro
  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false; // Evitar que el usuario regrese a la pantalla anterior
      },
      child: Scaffold(
        body: Container(
                    decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.brown[300]!, Colors.brown[100]!],
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
                          'Iniciar sesión',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        if (widget.verificationMessage != null) // Mostrar el mensaje de verificación si existe
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                            child: Text(
                              widget.verificationMessage!,
                              style: TextStyle(color: Colors.red, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: Icon(Icons.email),
                            errorText: _emailError ? 'Campo requerido' : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: Icon(Icons.lock),
                            errorText: _passwordError ? 'Campo requerido' : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submit, // Deshabilitar el botón si está cargando
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.brown[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator() // Mostrar indicador de carga
                              : Text('Iniciar sesión'),
                        ),
                        TextButton(
                          onPressed: _navigateToRegister, // Navegar directamente a la pantalla de registro
                          child: Text(
                            '¿No tienes una cuenta? Crear cuenta',
                            style: TextStyle(color: Colors.brown),
                          ),
                        ),
                        TextButton(
                          onPressed: _navigateToResetPassword,
                          child: Text('Olvidé mi contraseña', style: TextStyle(color: Colors.brown)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}