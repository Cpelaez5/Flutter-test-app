import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_model.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para crear un nuevo usuario
  Future<User?> createUser (String name, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

       await _auth.currentUser!.sendEmailVerification();
       print("Correo de verificación enviado a ${result.user?.email}");

      // Crear un nuevo UserModel
      UserModel newUser  = UserModel(
        uid: result.user!.uid,
        name: name,
        email: email,
        role: 'cliente', // Asignar rol por defecto
      );

      // Guardar el usuario en Firestore
      await FirebaseFirestore.instance.collection('users').doc(newUser .uid).set(newUser.toMap());

      return result.user;
    } catch (e) {
      print('Error al crear usuario: $e');
      return null;
    }
  }

  // Método para iniciar sesión
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error al iniciar sesión: $e');
      return null;
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