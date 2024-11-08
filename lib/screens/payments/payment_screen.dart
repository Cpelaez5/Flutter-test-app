import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../utils/get_dolar_price.dart';
import 'payment_process/local_payment_verification.dart';
import 'payment_process/payment_info.dart';

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
  String? dolarPrice; // Variable para almacenar el precio del dólar

  @override
  void initState() {
    super.initState();
    fetchDolarPrice(); // Llama a la función para obtener el precio del dólar
  }

  Future<void> fetchDolarPrice() async {
  try {
    String price = await getDolarPrice(); // Llama a la función asíncrona
    if (mounted) { // Verifica si el widget aún está montado
      setState(() {
        dolarPrice = price; // Actualiza el estado con el precio obtenido
      });
    }
  } catch (e) {
    // Manejo de errores
    if (mounted) { // Verifica si el widget aún está montado
      setState(() {
        dolarPrice = 'Error: $e'; // Actualiza el estado con el error
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Métodos de Pago'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalAmount(),
            SizedBox(height: 20),
            _buildPaymentMethodTitle(),
            SizedBox(height: 8),
            _buildPaymentMethodGrid(),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAmount() {
  // Convierte dolarPrice a double, si es posible
  double? price = dolarPrice != null ? double.tryParse(dolarPrice!) : null;

  return Text(
    widget.totalAmount > 0 
      ? 'Total a Pagar: Bs.${widget.totalAmount.toStringAsFixed(2)} / ( \$${price != null && widget.totalAmount > 0 ? (widget.totalAmount / price).toStringAsFixed(2) : '0.00'})' 
      : 'Registrar pago a mi Wallet',
    style: TextStyle(fontSize: 20),
  );
}

  Widget _buildPaymentMethodTitle() {
    return Text('Selecciona un método de pago:');
  }

  Widget _buildPaymentMethodGrid() {
    final List<Map<String, dynamic>> paymentMethods = [
      {'label': 'Pago Móvil', 'icon': Icons.mobile_friendly, 'key': 'pago_movil', 'showWhenZero': true},
      // {'label': 'Zelle', 'icon': Icons.payment, 'key': 'zelle', 'showWhenZero': true},
      // {'label': 'Transferencia', 'icon': Icons.payment, 'key': 'transferencia', 'showWhenZero': true},
      {'label': 'Efectivo', 'icon': Icons.payments_outlined, 'key': 'bolivares', 'showWhenZero': false},
      {'label': 'Divisas', 'icon': Icons.attach_money, 'key': 'divisas', 'showWhenZero': false},
      {'label': 'Tarjeta', 'icon': Icons.credit_card, 'key': 'tarjeta', 'showWhenZero': false},
    ];

    return Expanded(
      child: GridView.count(
        padding: EdgeInsets.all(16.0),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        children: paymentMethods.map((method) {
          bool shouldShow = method['showWhenZero'] || widget.totalAmount > 0;
          return shouldShow ? _buildPaymentButton(method['label'], method['icon'], method['key']) : Container();
        }).toList(),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: _onConfirmPayment,
      child: Text('Confirmar método de pago'),
    );
  }

  void _onConfirmPayment() {
    if (selectedPaymentMethod == 'pago_movil' || selectedPaymentMethod == 'transferencia') {
      Navigator.push(
        context,
          MaterialPageRoute(
            builder: (context) => PaymentInfoScreen(
              paymentMethod: selectedPaymentMethod,
              totalAmount: widget.totalAmount,
              products: widget.products.map((product) => product.toMap()).toList(),
            ),
          ),
        );
    } else if (selectedPaymentMethod != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocalPaymentVerificationScreen(
            paymentMethod: selectedPaymentMethod,
            totalAmount: widget.totalAmount,
            products: widget.products,
            dolarPrice: double.tryParse(dolarPrice ?? '0'), // Pasa el precio del dólar
          ),
        ),
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
          color: isSelected ? Colors.orange[100] : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.deepOrangeAccent : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Card(
          elevation: isSelected ? 8 : 4,
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