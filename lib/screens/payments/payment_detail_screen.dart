import 'package:flutter/material.dart';
import '../../data/products.dart'; // Asegúrate de que la ruta sea correcta
import '../../models/order_model.dart'; // Asegúrate de que la ruta sea correcta

class PaymentDetailScreen extends StatelessWidget {
  final Payment payment;

  PaymentDetailScreen({required this.payment});

  @override
  Widget build(BuildContext context) {
    DateTime paymentDateTime = payment.timestamp;

    String paymentDetails = 
    'Fecha del pago: ${payment.paymentDate}\n'
    'Referencia: ${payment.referenceNumber}\n'
      'Monto: ${payment.paymentAmount} Bs.\n'
      'Estado: ${payment.paymentStatus}\n'
      'Banco: ${payment.selectedBank}\n'
      'Usuario: ${payment.uid}\n'
      'Registrado: ${paymentDateTime.day}/${paymentDateTime.month}/${paymentDateTime.year} ${paymentDateTime.hour}:${paymentDateTime.minute}';
       
    if (payment.paymentMethod == 'pago_movil') {
      paymentDetails += '\nTeléfono: ${payment.phoneNumber}';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Pago'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(paymentDetails, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Text('Productos:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          // ListView de productos
          if (payment.products.isEmpty)
            ListTile(
              title: Text('No hay productos en el pago'),
            )
          else
            ...payment.products.map((product) {
              final productData = products.firstWhere((p) => p.id == product['productId']);
              return ListTile(
                title: Text(productData.name),
                subtitle: Text(
                  'Cantidad: ${product['quantity']}'
                  '\nPrecio unitario: ${(product['price']).toStringAsFixed(2)} Bs.'
                  '\nSubtotal: ${(product['price'] * product['quantity']).toStringAsFixed(2)} Bs.',
                ),
              );
            }).toList(),
        ],
      ),
    );  
  }
}