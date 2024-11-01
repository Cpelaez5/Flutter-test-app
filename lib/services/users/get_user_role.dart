import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> getUserRole(String uid) async {
  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      return userDoc['role'] ?? 'cliente'; // Retorna 'cliente' si no se encuentra el rol
    }
  } catch (e) {
    print('Error al obtener el rol del usuario: $e');
  }
  return 'cliente'; // Valor por defecto
}