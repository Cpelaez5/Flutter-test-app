import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/order_model.dart';
import '../payments/payment_detail_screen.dart';

class AdminOrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagos Móviles'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('payments').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay pagos disponibles'));
          }

          // Obtener los pagos y ordenarlos por fecha de llegada (timestamp)
          final payments = snapshot.data!.docs.map((doc) {
            return Payment.fromFirestore(doc);
          }).toList();

          // Ordenar los pagos por timestamp (más recientes primero)
          payments.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              DateTime paymentDateTime = payment.timestamp;
              final timeAgo = timeago.format(paymentDateTime, locale: 'es');

              IconData icon;
              String paymentName = '';
              String paymentStatus = '';
              Color cardColor = const Color.fromARGB(0, 255, 255, 255);
              Color textColor = const Color.fromARGB(178, 0, 0, 0);

              switch (payment.paymentMethod) {
                case 'pago_movil':
                  paymentName = 'Pago Móvil';
                  icon = Icons.mobile_friendly;
                  break;
                case 'divisas':
                  paymentName = 'Divisas';
                  icon = Icons.attach_money;
                  break;
                case 'transferencia':
                  icon = Icons.swap_horiz_sharp;
                  paymentName = 'Transferencia';
                  break;
                case 'bolivares':
                  icon = Icons.payments_outlined;
                  paymentName = 'Bolívares';
                  break;
                default:
                  icon = Icons.error_outline_rounded;
                  paymentName = 'Pago erróneo';
                  break;
              }

              if (payment.paymentStatus == 'pending') {
                paymentStatus = 'Pendiente';
                cardColor = Colors.green.withOpacity(0.5);
                textColor = const Color.fromARGB(255, 0, 0, 0);
              } else if (payment.paymentStatus == 'finished') {
                paymentStatus = 'Finalizado';
              }

              return ListTile(
                leading: Icon(icon),
                title: Text(paymentName),
                subtitle: Text('Monto: ${payment.paymentAmount} Bs.\n$paymentStatus',
                style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text(timeAgo),
                tileColor: cardColor, textColor: textColor, iconColor: textColor,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PaymentDetailScreen(payment: payment),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}