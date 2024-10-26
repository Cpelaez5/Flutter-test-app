import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> getCedulaByUid(String uid) async {
    if (uid.isEmpty) {
      return null; // Retorna null si el UID está vacío
    }

    DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
    return userDoc.exists ? userDoc['Cédula'] : null; // Retorna la cédula o null si no existe
  }
}