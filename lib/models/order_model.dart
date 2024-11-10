import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id; // ID del documento en Firestore
  final String? referenceNumber; // Hacerlo opcional
  final String? phoneNumber; // Hacerlo opcional
  final String? paymentMethod;
  final String? selectedBank; // Hacerlo opcional
  final String uid;
  final DateTime timestamp;
  final String paymentAmount;
  final String paymentStatus;
  final String? paymentDate; // Hacerlo opcional
  final String? token; // Hacerlo opcional
  final List<dynamic> products;

  Payment({
    required this.id, // Agregar el ID en el constructor
    this.referenceNumber,
    this.phoneNumber,
    required this.paymentMethod,
    this.selectedBank,
    required this.uid,
    required this.timestamp, 
    required this.paymentAmount, 
    required this.paymentStatus, 
    this.paymentDate, 
    required this.products,
    this.token,
  });

  factory Payment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    DateTime parsedDate;
    if (data['timestamp'] is Timestamp) {
      parsedDate = (data['timestamp'] as Timestamp).toDate();
    } else if (data['timestamp'] is String) {
      parsedDate = _parseCustomDate(data['timestamp']);
    } else {
      parsedDate = DateTime.now(); // O puedes lanzar una excepción
    }

    return Payment(
      id: doc.id, // Aquí obtienes el ID del documento
      referenceNumber: data['referenceNumber'] as String?, // Asegúrate de que sea nullable
      phoneNumber: data['phoneNumber'] as String?, // Asegúrate de que sea nullable
      paymentMethod: data['paymentMethod'] ?? '', // Valor por defecto si es nulo
      selectedBank: data['selectedBank'] as String?, // Asegúrate de que sea nullable
      paymentAmount: (data['paymentAmount'] ?? 0).toString(), // Convertir a String
      uid: data['uid'] ?? '', // Valor por defecto si es nulo
      paymentStatus: data['paymentStatus'] ?? '', // Valor por defecto si es nulo
      timestamp: parsedDate,
      paymentDate: data['paymentDate'] as String?, // Asegúrate de que sea nullable
      products: data['products'] ?? [], // Valor por defecto si es nulo
      token: data['token'] as String?, // Asegúrate de que sea nullable
    );
  }

  static DateTime _parseCustomDate(String dateString) {
    if (dateString.contains('-')) {
      List<String> parts = dateString.split('-');
      if (parts.length != 3) {
        throw FormatException('Invalid date format: $dateString');
      }

      int year = int.parse(parts[0]) + 2000; // Asumiendo que es en el siglo 21
      int month = int.parse(parts[1]);
      int day = int.parse(parts[2]);

      return DateTime(year, month, day);
    } else {
      if (dateString.length == 6) {
        int year = int.parse(dateString.substring(0, 2)) + 2000;
        int month = int.parse(dateString.substring(2, 4));
        int day = int.parse(dateString.substring(4, 6));

        return DateTime(year, month, day);
      } else {
        throw FormatException('Invalid date format: $dateString');
      }
    }
  }
}