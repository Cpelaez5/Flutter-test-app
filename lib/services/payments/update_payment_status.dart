import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

final Uuid _uuid = Uuid();

Future<void> updatePaymentStatus(String paymentId, String newStatus) async {
  try {
    await FirebaseFirestore.instance.collection('payments').doc(paymentId).update({
      'paymentStatus': newStatus});
    await FirebaseFirestore.instance.collection('payments').doc(paymentId).update({
      'token': _uuid.v4()});

    print('Estado del pago actualizado a $newStatus');
  } catch (e) {
    print('Error al actualizar el estado del pago: $e');
  }
}