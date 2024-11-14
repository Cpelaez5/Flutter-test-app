import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/order_model.dart';
import '../../widgets/info/payment_card.dart';
import '../payments/payment_detail_screen.dart'; // Importa el nuevo widget

class UserOrdersScreen extends StatelessWidget {
  final String userId;
  final bool? fromAdmin;

  UserOrdersScreen({
    required this.userId,
    this.fromAdmin,
    });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          fromAdmin == true ? 'Pedidos del Usuario' : 'Mis Pedidos'
          ),
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
            return Center(child: Text(
              fromAdmin == true ? 'Este usuario no ha hecho pedidos' : 'No has hecho pedidos todavía.'
              ));
          }

          final orders = _getOrdersFromSnapshot(snapshot);

          return _buildOrdersList(orders, context);
        },
      ),
      // floatingActionButton: ElevatedButton(
      //     onPressed: () {
      //       Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => PaymentScreen(
      //           totalAmount: 0.0,
      //           products: [], // Pasar la lista de productos
      //         ),
      //       ),
      //     );
      //       print('Botón presionado');
      //     },
      //     child: Row(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         const Icon(Icons.add), // Ícono
      //         const SizedBox(width: 8), // Espacio entre el ícono y el texto
      //         const Text('Registrar Pago'), // Texto
      //       ],
      //     ),
      //   ),
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
    print(order);
    print(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentDetailScreen(payment: order),
      ),
    );
  }
}