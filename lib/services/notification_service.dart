import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  static Future<void> sendNotificationToAdmins(String message) async {
    // Obtener los usuarios administradores
    QuerySnapshot adminUsers = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'cliente')
        .get();

    for (var doc in adminUsers.docs) {
      String? token = doc['token']; // Asegúrate de que el campo 'token' exista en tu documento

      if (token != null) {
        // Enviar la notificación
        await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'key=YAK33uM5elGYz00eXHoY9XaTcMRZPNgKV5MH2zK4JGM', // Reemplaza con tu clave de servidor
          },
          body: jsonEncode({
            'to': token,
            'notification': {
              'title': 'Nuevo Pago Registrado',
              'body': message,
            },
          }),
        );
      }
    }
  }
}