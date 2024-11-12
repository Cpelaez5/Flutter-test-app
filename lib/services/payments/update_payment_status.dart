import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

final Uuid _uuid = Uuid();

Future<void> updatePaymentStatus(String paymentId, String newStatus, Timestamp? checkedAt) async {
  try {
    // Actualiza el estado del pago y el token en un solo update
    await FirebaseFirestore.instance.collection('payments').doc(paymentId).update({
      'paymentStatus': newStatus,
      if (checkedAt != null) 'checkedAt': checkedAt,
      'token': _uuid.v4(), // Generar un nuevo token
    });

    print('Estado del pago actualizado a $newStatus y checkedAt establecido.');
  } catch (e) {
    print('Error al actualizar el estado del pago: $e');
  }
}