import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String referenceNumber;
  final String phoneNumber;
  final String selectedBank;
  final bool isCaptureUploaded;
  final String user;
  final DateTime date;

  Payment({
    required this.referenceNumber,
    required this.phoneNumber,
    required this.selectedBank,
    required this.isCaptureUploaded,
    required this.user,
    required this.date,
  });

  factory Payment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    DateTime parsedDate;
    if (data['date'] is Timestamp) {
      // Si el campo es un Timestamp, conviértelo a DateTime
      parsedDate = (data['date'] as Timestamp).toDate();
    } else if (data['date'] is String) {
      // Si el campo es un String, intenta parsearlo
      parsedDate = _parseCustomDate(data['date']);
    } else {
      // Manejo de error o valor predeterminado
      parsedDate = DateTime.now(); // O puedes lanzar una excepción
    }

    return Payment(
      referenceNumber: data['referenceNumber'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      selectedBank: data['selectedBank'] ?? '',
      isCaptureUploaded: data['isCaptureUploaded'] ?? false,
      user: data['user'] ?? '',
      date: parsedDate,
    );
  }

  static DateTime _parseCustomDate(String dateString) {
    // Manejo del formato YY-MM-DD
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
      // Manejo del formato sin guiones (ejemplo: 102030)
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