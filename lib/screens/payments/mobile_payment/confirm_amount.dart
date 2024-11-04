import 'package:flutter/material.dart';
import '../../../utils/currency_input_formatter.dart';
import 'payment_verification.dart'; // Asegúrate de que la ruta sea correcta

class ConfirmAmountScreen extends StatefulWidget {
  final String confirmedPhone;
  final double totalAmount;
  final List<Map<String, dynamic>> products;
  final String referenceNumber;
  final String selectedBank;
  final DateTime selectedDate;
  final String? action;

  const ConfirmAmountScreen({
    super.key,
    required this.confirmedPhone,
    required this.totalAmount,
    required this.products,
    required this.referenceNumber,
    required this.selectedBank,
    required this.selectedDate,
    this.action
  });

  @override
  _ConfirmAmountScreenState createState() => _ConfirmAmountScreenState();
}

class _ConfirmAmountScreenState extends State<ConfirmAmountScreen> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.text = '0,00'; // Inicializa el campo con 0.00
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación de Pago'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Confirma el monto en bolívares',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            Center( // Centrar el Row
              child: Row(
                mainAxisSize: MainAxisSize.min, // Ajustar el tamaño del Row
                children: [
                  Flexible( // Hacer que "Bs" sea responsive
                    child: Text(
                      'Bs',
                      style: TextStyle(
                        fontSize: 24, // Tamaño de letra más grande
                        fontWeight: FontWeight.bold, // Texto en negrita
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8), // Espacio entre "Bs" y el campo de texto
                  Expanded( // Permitir que el TextField use el espacio restante
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      textAlign: TextAlign.center, // Centrar el texto
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, // Texto en negrita
                        color: Colors.grey, // Color más suave
                        fontSize: 28, // Tamaño de fuente
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none, // Sin bordes
                        hintText: '0,00',
                        hintStyle: const TextStyle(color: Colors.grey), // Color del texto de ayuda
                        filled: true,
                        fillColor: Colors.transparent, // Fondo transparente
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.totalAmount > 0
                  ? 'Debe ser de al menos Bs ${widget.totalAmount.toStringAsFixed(2)}'
                  : 'Asegúrate de ingresar el mismo monto de tu pago',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Convertir el monto ingresado a double
                  double enteredAmount = double.tryParse(_amountController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0;

                  // Validar que el monto ingresado sea mayor que 0
                  if (enteredAmount <= 0.99) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor, ingresa un monto válido para continuar.')),
                    );
                    return; // No continuar si el monto es inválido
                  }

                  if(widget.action == 'edit'){
                    enteredAmount = enteredAmount;
                    return Navigator.of(context).pop(enteredAmount);
                  }
                  // Navegar a la siguiente pantalla pasando los datos necesarios
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentVerificationScreen(
                        confirmedPhone: widget.confirmedPhone,
                                                totalAmount: widget.totalAmount,
                        products: widget.products,
                        referenceNumber: widget.referenceNumber,
                        selectedBank: widget.selectedBank,
                        selectedDate: widget.selectedDate,
                        enteredAmount: enteredAmount, // Pasar el monto ingresado
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: Text(
                  widget.action == 'edit' ? 'Actualizar monto' : 'Confirmar monto'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}