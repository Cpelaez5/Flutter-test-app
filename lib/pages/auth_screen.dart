import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  int _reintentos = 0;
  Timer? _timer;
  bool _emailError = false;
  bool _passwordError = false;

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

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
    User? user;
    if (_isLogin) {
      user = await authService.signIn(email, password);
    } else {
      user = await authService.createUser (email, password);
    }

    if (user != null) {
      _showSnackBar(_isLogin ? 'Inicio de sesión exitoso' : 'Registro exitoso');
      // Navega a la pantalla principal de tu aplicación
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      _showSnackBar('Error al autenticar. Por favor, verifica tus credenciales.');
    }
  } catch (error) {
    print('Error: $error');
    _showSnackBar('Error al autenticar. Por favor, verifica tus credenciales.');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
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
                    backgroundColor: _isLogin ? Colors.lightBlueAccent : Colors.greenAccent,
                  ),
                  child: Text(_isLogin ? 'Iniciar sesión' : 'Registrarse'),
                ),
              TextButton(
                onPressed: _toggleAuthMode,
                child: Text(_isLogin ? 'Crear una cuenta' : 'Ya tengo una cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}