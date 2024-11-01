import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_model.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para validar el formato del correo electrónico
  bool _isEmailValid(String email) {
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  // Método para crear un nuevo usuario
  Future<User?> createUser  (
  String idCard,
  String phone,
  String address,
  String name,
  String email,
  String password,
) async {
  // Validar el correo electrónico
  if (!_isEmailValid(email)) {
    throw FirebaseAuthException(
      code: 'invalid-email',
      message: 'El correo electrónico está mal formado.',
    );
  }

  print("Correo electrónico ingresado: ${email.trim()}");

  try {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email.trim(), // Asegúrate de usar trim() para eliminar espacios
      password: password,
    );

    // Enviar correo de verificación
    await result.user?.sendEmailVerification();
    print("Correo de verificación enviado a ${result.user?.email}");

    // Crear un nuevo UserModel
    UserModel newUser   = UserModel(
      uid: result.user!.uid,
      idCard: idCard,
      name: name,
      phone: phone,
      address: address,
      email: email,
      role: 'cliente', // Asignar rol por defecto
    );

    // Guardar el usuario en Firestore
    await FirebaseFirestore.instance.collection('users').doc(newUser .uid).set(newUser .toMap());

    return result.user;
  } catch (e) {
    print('Error al crear usuario: $e');
    rethrow; // Lanza la excepción para manejarla en el UI
  }
}

  // Método para iniciar sesión
  Future<User?> signIn(String email, String password) async {
    // Validar el correo electrónico
    if (!_isEmailValid(email)) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'El correo electrónico está mal formado.',
      );
    }

    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(), // Asegúrate de usar trim() para eliminar espacios
        password: password,
      );
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
    } catch (e) {
      print('Error al cerrar sesión: $e');
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