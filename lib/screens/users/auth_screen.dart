import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // Agregar un controlador para el nombre
  bool _isLogin = true;
  bool _isLoading = false;
  bool _emailError = false;
  bool _passwordError = false;
  bool _nameError = false; // Agregar una variable para el error del nombre

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _submit() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  final name = _nameController.text.trim(); // Obtener el texto del campo de nombre

  setState(() {
    _emailError = email.isEmpty;
    _passwordError = password.isEmpty;
    if (!_isLogin) {
      _nameError = name.isEmpty; // Verificar si el nombre está vacío
    }
  });

  if (_emailError || _passwordError || (!_isLogin && _nameError)) {
    _showSnackBar('Por favor, completa todos los campos.');
    return;
  }

  setState(() {
    _isLoading = true;
  });

  final authService = Provider.of<AuthService>(context, listen: false);
  try {
    User? user;
    if (_isLogin) {
      user = await authService.signIn(email, password);
    } else {
      user = await authService.createUser (name, email, password); // Pasar el nombre, correo electrónico y contraseña
    }

    if (mounted) { // Verificar si el widget está montado
      if (user != null) {
        // Verificar si el usuario tiene el rol de administrador
        // final role = await authService.getRole(user.uid);
          Navigator.of(context).pushReplacementNamed('/home');
      } else {
        _showSnackBar('Error al autenticar. Por favor, verifica tus credenciales.');
      }
    }
  } catch (error) {
    print('Error: $error');
    if (mounted) { // Verificar si el widget está montado
      _showSnackBar('Error al autenticar. Por favor, verifica tus credenciales.');
    }
  } finally {
    if (mounted) { // Verificar si el widget está montado
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  void _showSnackBar(String message) {
    if (mounted) { // Verificar si el widget está montado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
void dispose() {
  _emailController.dispose();
  _passwordController.dispose();
  _nameController.dispose(); // Disponer del controlador del nombre
  super.dispose();
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(_isLogin ? 'Iniciar sesión' : 'Registrarse'),
      backgroundColor: _isLogin ? Colors.blue : Colors.green,
    ),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isLogin ? Icons.login : Icons.app_registration,
              size: 100,
              color: _isLogin ? Colors.blue : Colors.green,
            ),
            SizedBox(height: 20),
            Text(
              _isLogin
                  ? 'Por favor, ingresa tus credenciales para iniciar sesión.'
                  : 'Crea una cuenta nueva para comenzar.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            if (!_isLogin)
              TextField(
                controller: _nameController, // Agregar el campo de texto para el nombre
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  errorText: _nameError ? 'El campo no puede estar vacío' : null,
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _nameError ? Colors.red : Colors.blue),
                  ),
                ),
              ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: _emailError ? 'El campo no puede estar vacío' : null,
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _emailError ? Colors.red : Colors.blue),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                errorText: _passwordError ? 'El campo no puede estar vacío' : null,
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _passwordError ? Colors.red : Colors.blue),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            if (_isLoading)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: _isLogin ? Colors.blue : Colors.green,
                ),
                child: Text(_isLogin ? 'Iniciar sesión' : 'Registrarse'),
              ),
            SizedBox(height: 10),
            TextButton(
              onPressed: _toggleAuthMode,
              style: TextButton.styleFrom(
                foregroundColor: _isLogin ? Colors.blue : Colors.green,
              ),
              child: Text(_isLogin ? 'Crear cuenta' : 'Iniciar sesión'),
            ),
          ],
        ),
      ),
    ),
  );
} 
}