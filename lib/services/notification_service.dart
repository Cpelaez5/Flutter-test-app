import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationService {
  static Future<void> sendNotification(String title, String message, String? userRole, String? userId) async {
    Set<String> tokens = {}; // Usar un Set para evitar duplicados

    if (userId != null ) {
      // Obtener el documento del usuario específico
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?; 
        if (data != null && data.containsKey('tokens') && data['tokens'] is List) {
          // Agregar los tokens al Set
          tokens.addAll(List<String>.from(data['tokens']));
        } else {
          print('El documento del usuario $userId no contiene el campo "tokens" o no es una lista.');
        }
      } else {
        print('El documento del usuario $userId no existe.');
      }
    } else {
      // Obtener los usuarios por rol
      QuerySnapshot roleUsers = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: userRole)
          .get();

      for (var doc in roleUsers.docs) {
        final data = doc.data() as Map<String, dynamic>?; 
        if (data != null && data.containsKey('tokens') && data['tokens'] is List) {
          // Agregar los tokens al Set
          tokens.addAll(List<String>.from(data['tokens']));
        } else {
          print('El documento ${doc.id} no contiene el campo "tokens" o no es una lista.');
        }
      }
    }

    // Enviar la notificación a cada token
    for (String token in tokens) {
      final response = await http.post(
        Uri.parse(dotenv.env['API_URL']!),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
          'data': {
            'title': title,
            'body': message,
          },
        }),
      );

      if (response.statusCode != 200) {
        print('Error al enviar la notificación a $token: ${response.body}');
      }
    }
  }
}