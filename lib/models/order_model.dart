import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id; // ID del documento en Firestore
  final String referenceNumber;
  final String phoneNumber;
  final String paymentMethod;
  final String selectedBank;
  final bool isCaptureUploaded;
  final String uid;
  final DateTime timestamp;
  final String paymentAmount;
  final String paymentStatus;
  final String paymentDate;
  final String token;
  final List<dynamic> products;

  Payment({
    required this.id, // Agregar el ID en el constructor
    required this.referenceNumber,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.selectedBank,
    required this.isCaptureUploaded,
    required this.uid,
    required this.timestamp, 
    required this.paymentAmount, 
    required this.paymentStatus, 
    required this.paymentDate, 
    required this.products,
    required this.token,
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
      referenceNumber: data['referenceNumber'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
      selectedBank: data['selectedBank'] ?? '',
      paymentAmount: data['paymentAmount'] ?? '',
      isCaptureUploaded: data['isCaptureUploaded'] ?? false,
      uid: data['user'] ?? '',
      paymentStatus: data['paymentStatus'] ?? '',
      timestamp: parsedDate,
      paymentDate: data['paymentDate'] ?? '',
      products: data['products'] ?? [],
      token: data['token'] ?? '',
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