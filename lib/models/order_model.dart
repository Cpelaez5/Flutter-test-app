import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id; // ID del documento en Firestore
  final int orderNumber;
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
  final DateTime? checkedAt; // Campo opcional
  final DateTime? finishedAt; // Campo opcional
  final List<dynamic> products;

  Payment({
    required this.id,
    required this.orderNumber,
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
    this.checkedAt,
    this.finishedAt,
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

    DateTime? checkedAtDate;
    if (data['checkedAt'] is Timestamp) {
      checkedAtDate = (data['checkedAt'] as Timestamp).toDate();
    }

    DateTime? finishedAtDate;
    if (data['finishedAt'] is Timestamp) {
      finishedAtDate = (data['finishedAt'] as Timestamp).toDate();
    }

    return Payment(
      id: doc.id,
      orderNumber: data['orderNumber'] as int,
      referenceNumber: data['referenceNumber'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      paymentMethod: data['paymentMethod'] ?? '',
      selectedBank: data['selectedBank'] as String?,
      paymentAmount: (data['paymentAmount'] ?? 0).toString(),
      uid: data['uid'] ?? '',
      paymentStatus: data['paymentStatus'] ?? '',
      timestamp: parsedDate,
      paymentDate: data['paymentDate'] as String?,
      products: data['products'] ?? [],
      token: data['token'] as String?,
      checkedAt: checkedAtDate, // Asignar el valor de checkedAt
      finishedAt: finishedAtDate, // Asignar el valor de finishedAt
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