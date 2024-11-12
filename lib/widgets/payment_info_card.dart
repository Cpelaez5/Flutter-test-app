import 'package:flutter/material.dart';
import '../../models/order_model.dart';

class PaymentInfoCard extends StatelessWidget {
  final Payment payment;

  PaymentInfoCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    DateTime paymentDateTime = payment.timestamp;
    String paymentStatusName;

    switch (payment.paymentStatus) {
      case 'pending':
        paymentStatusName = payment.paymentMethod != 'pago_movil' ? 'Pendiente por pagar' : 'Pendiente por verificar';
        break;
      case 'finished':
        paymentStatusName = 'Finalizado';
        break;
      case 'checked':
        paymentStatusName = 'Verificado';
        break;
      default:
        paymentStatusName = 'Desconocido';
        break;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información de Pedido N°${payment.orderNumber}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (payment.paymentDate != null) Text('Fecha del pago: ${payment.paymentDate}'),
            if (payment.referenceNumber != null) Text('Referencia: ${payment.referenceNumber}'),
            if (payment.paymentAmount.isNotEmpty)
              Text(
                'Monto: ${payment.paymentMethod == 'divisas' ? '\$${payment.paymentAmount}' : 'Bs. ${payment.paymentAmount}'}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
              ),
            Text('Estado: $paymentStatusName', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Registrado: ${paymentDateTime.day}/${paymentDateTime.month}/${paymentDateTime.year} ${paymentDateTime.hour}:${paymentDateTime.minute}'),
          ],
        ),
      ),
    );
  }
}