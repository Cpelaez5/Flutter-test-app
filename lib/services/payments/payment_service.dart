import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/product.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> fetchUserRole() async {
    User? currentUser  = FirebaseAuth.instance.currentUser ;
    if (currentUser  != null) {
      // Implementa la lógica para obtener el rol del usuario
      // Por ejemplo:
      return 'cliente'; // Cambia esto por la lógica real
    }
    return 'cliente';
  }

  Future<List<Product>> loadProducts() async {
    final snapshot = await _firestore.collection('products').get();
    return snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList();
  }

  Future<Map<String, dynamic>?> fetchPaymentData(String paymentId) async {
    DocumentSnapshot paymentDoc = await _firestore.collection('payments').doc(paymentId).get();
    return paymentDoc.data() as Map<String, dynamic>?;
  }

  Future<void> updatePaymentStatus(String paymentId, String status) async {
    await _firestore.collection('payments').doc(paymentId).update({
      'paymentStatus': status,
      'finishedAt': FieldValue.serverTimestamp(),
    });
  }
}

