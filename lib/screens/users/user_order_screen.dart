import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/order_model.dart';
import '../../widgets/payment_card.dart';
import '../payments/payment_detail_screen.dart'; // Importa el nuevo widget

class UserOrdersScreen extends StatelessWidget {
  final String userId;

  UserOrdersScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('payments')
            .where('uid', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No has hecho pedidos todavía.'));
          }

          final orders = _getOrdersFromSnapshot(snapshot);

          return _buildOrdersList(orders, context);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Payment> _getOrdersFromSnapshot(AsyncSnapshot<QuerySnapshot> snapshot) {
    final orders = snapshot.data!.docs.map((doc) {
      return Payment.fromFirestore(doc);
    }).toList();

    orders.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return orders;
  }

  Widget _buildOrdersList(List<Payment> orders, BuildContext context) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return PaymentCard(
          payment: order,
          onTap: () => _navigateToOrderDetail(context, order),
        );
      },
    );
  }

  void _navigateToOrderDetail(BuildContext context, Payment order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentDetailScreen(payment: order),
      ),
    );
  }
}