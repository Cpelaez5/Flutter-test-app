import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> updatePaymentStatus(String paymentId, String newStatus) async {
  try {
    await FirebaseFirestore.instance.collection('payments').doc(paymentId).update({
      'paymentStatus': newStatus,
    });
    print('Estado del pago actualizado a $newStatus');
  } catch (e) {
    print('Error al actualizar el estado del pago: $e');
  }
}