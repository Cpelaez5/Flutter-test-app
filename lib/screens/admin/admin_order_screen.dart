import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/widgets/payments/qr_scanner.dart';
import '../../models/order_model.dart';
import '../../widgets/info/payment_card.dart';
import '../payments/payment_detail_screen.dart'; // Importa el nuevo widget

class AdminOrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagos/Pedidos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('payments').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay pagos disponibles'));
          }

          final payments = _getPaymentsFromSnapshot(snapshot);

          return _buildPaymentsList(payments, context);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QRScanner(),
            ),
          );
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

  List<Payment> _getPaymentsFromSnapshot(AsyncSnapshot<QuerySnapshot> snapshot) {
    final payments = snapshot.data!.docs.map((doc) {
      return Payment.fromFirestore(doc);
    }).toList();

    payments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return payments;
  }

  Widget _buildPaymentsList(List<Payment> payments, BuildContext context) {
    return ListView.builder(
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return PaymentCard(
          payment: payment,
          onTap: () => _navigateToPaymentDetail(context, payment),
        );
      },
    );
  }

  void _navigateToPaymentDetail(BuildContext context, Payment payment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentDetailScreen(payment: payment),
      ),
    );
  }
}