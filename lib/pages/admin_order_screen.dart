import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class AdminOrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagos Móviles'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pagosMoviles').snapshots(),
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

          final payments = snapshot.data!.docs.map((doc) {
            return Payment.fromFirestore(doc); // Asegúrate de tener un método para crear el modelo desde Firestore
          }).toList();

          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return ListTile(
                title: Text('Referencia: ${payment.referenceNumber}'),
                subtitle: Text('Método de pago: ${payment.selectedBank}'),
                trailing: Text('Fecha: ${payment.date}'),
                onTap: () {
                  // Aquí puedes mostrar más detalles del pago
                },
              );
            },
          );
        },
      ),
    );
  }
}