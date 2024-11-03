import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../payments/mobile_payment/mobile_payment_info.dart';
// Asegúrate de que la ruta sea correcta

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final List<Product> products;

  PaymentScreen({required this.totalAmount, required this.products});

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
            _buildTotalAmount(),
            SizedBox(height: 20),
            _buildPaymentMethodTitle(),
            _buildPaymentMethodGrid(),
            if (selectedPaymentMethod == 'transferencia') _buildReferenceNumberField(),
            SizedBox(height: 20),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAmount() {
    return Text(
      widget.totalAmount > 0 
        ? 'Total a Pagar: \$${widget.totalAmount.toStringAsFixed(2)}' 
        : 'Registrar pago',
      style: TextStyle(fontSize: 20),
    );
  }

    Widget _buildPaymentMethodTitle() {
      return Text('Selecciona un método de pago:');
    }

    Widget _buildPaymentMethodGrid() {
      return Expanded(
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildPaymentButton('Efectivo', Icons.payments_outlined, 'bolivares'),
            _buildPaymentButton('Divisas', Icons.attach_money, 'divisas'),
            _buildPaymentButton('Pago Móvil', Icons.mobile_friendly, 'pago_movil'),
            _buildPaymentButton('Transferencia', Icons.swap_horiz_sharp, 'transferencia'),
          ],
        ),
      );
    }

    Widget _buildReferenceNumberField() {
      return TextField(
        decoration: InputDecoration(
          labelText: 'Número de referencia',
        ),
        onChanged: (value) {
          referenceNumber = value;
        },
      );
    }

    Widget _buildConfirmButton() {
      return ElevatedButton(
        onPressed: _onConfirmPayment,
        child: Text('Confirmar Pago'),
      );
    }

    void _onConfirmPayment() {
      if (selectedPaymentMethod == 'transferencia' && (referenceNumber == null || referenceNumber!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, ingresa el número de referencia.')),
        );
        return;
      }

      if (selectedPaymentMethod == 'pago_movil') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MobilePaymentInfoScreen(
              totalAmount: widget.totalAmount,
              products: widget.products.map((product) => product.toMap()).toList(), // Convertir a lista de mapas
            ),
          ),
        );
      } else if (selectedPaymentMethod != null) {
        Navigator.pop(context); // Regresar a la pantalla anterior
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Compra realizada con éxito!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, selecciona un método de pago.')),
        );
      }
    }

    Widget _buildPaymentButton(String title, IconData icon, String value) {
    bool isSelected = selectedPaymentMethod == value;

    return InkWell(
      onTap: () {
        setState(() {
          selectedPaymentMethod = value;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[100] : Colors.white, // Color de fondo cambia al seleccionar
          border: Border.all(
            color: isSelected ? Colors.deepOrangeAccent : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Card(
          elevation: isSelected ? 8 : 4, // Aumentar la elevación al seleccionar
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: isSelected ? Colors.deepOrangeAccent : Colors.blueGrey,
                ),
                SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected ? Colors.deepOrangeAccent : Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } 
}