import 'package:flutter/material.dart';
import 'mobile_payment_screen.dart'; // Asegúrate de que la ruta sea correcta

class PaymentScreen extends StatefulWidget {
  final double totalAmount;

  PaymentScreen({required this.totalAmount});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? selectedPaymentMethod;
  String? referenceNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Método de Pago'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total a Pagar: \$${widget.totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            Text('Selecciona un método de pago:'),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // Dos botones por fila
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildPaymentButton('Bolívares en efectivo', Icons.money, 'bolivares'),
                  _buildPaymentButton('Dólares en efectivo', Icons.attach_money, 'dolares'),
                  _buildPaymentButton('Pago Móvil', Icons.mobile_friendly, 'pago_movil'),
                  _buildPaymentButton('Transferencia', Icons.transfer_within_a_station, 'transferencia'),
                ],
              ),
            ),
            if (selectedPaymentMethod == 'transferencia') 
              TextField(
                decoration: InputDecoration(
                  labelText: 'Número de referencia',
                ),
                onChanged: (value) {
                  referenceNumber = value;
                },
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (selectedPaymentMethod == 'pago_movil') {
                  // Navegar a la pantalla de Pago Móvil
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MobilePaymentScreen()),
                  );
                } else if (selectedPaymentMethod != null) {
                  // Aquí puedes manejar la lógica de pago
                  Navigator.pop(context); // Regresar a la pantalla anterior
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Compra realizada con éxito!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Por favor, selecciona un método de pago.')),
                  );
                }
              },
              child: Text('Confirmar Pago'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton(String title, IconData icon, String value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = value;
          referenceNumber = null; // Limpiar referencia si cambia el método
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedPaymentMethod == value ? Colors.blue : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: selectedPaymentMethod == value ? Colors.blue : Colors.black),
                SizedBox(height: 10),
                Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: selectedPaymentMethod == value ? Colors.blue : Colors.black)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}