import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para validar el formato del correo electrónico
  bool isEmailValid(String email) { // Cambiado a público
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  // Método para crear un nuevo usuario
  Future<User?> createUser (String idCard, String phone, String address, String name, String email, String password) async {
  try {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (result.user != null) {
      // Guardar los datos del usuario en Firestore
      await FirebaseFirestore.instance.collection('users').doc(result.user!.uid).set({
        'idCard': idCard,
        'phone': phone,
        'address': address,
        'name': name,
        'email': email,
        'role': 'cliente', // Asignar un rol por defecto
        'tokens': [] // Inicializar un arreglo para los tokens
      });

      return result.user;
    }
  } catch (error) {
    print('Error en create:User  $error');
    rethrow; // Lanza la excepción para manejarla en la UI
  }
  return null;
}

  // Método para iniciar sesión
  Future<User?> signIn(String email, String password) async {
  try {
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    notifyListeners(); // Notifica a los oyentes que el estado ha cambiado
    return result.user;
  } catch (e) {
    print('Error al iniciar sesión: $e');
    rethrow; // Lanza la excepción para manejarla en el UI
  }
}

  // Método para cerrar sesión
  Future<void> signOut() async {
  try {
    await _auth.signOut();
    notifyListeners(); // Notificar a los oyentes que el usuario ha cerrado sesión
  } catch (e) {
    print('Error al cerrar sesión: $e');
    throw Exception('Error al cerrar sesión: $e');
  }
}

  // Método para obtener el rol del usuario
  Future<String> getRole(String uid) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return userDoc.data()?['role'] ?? 'cliente'; // Retorna 'cliente' si no se encuentra el rol
    } catch (e) {
      print('Error al obtener rol: $e');
      return 'cliente'; // Valor por defecto en caso de error
    }
  }

  // Getter para el usuario actual
  User? get currentUser  => _auth.currentUser ;

  // Stream para cambios en el estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}