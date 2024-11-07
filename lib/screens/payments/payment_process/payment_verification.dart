import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener esta dependencia en tu pubspec.yaml
import '../../../widgets/custom_dialog.dart';
import 'bank_selection.dart';
import 'confirm_amount.dart';
import 'payment_confirmation.dart';
import 'payment_date.dart';
import 'phone_verification.dart';
import 'reference_number.dart'; // Asegúrate de importar la nueva pantalla

class PaymentVerificationScreen extends StatefulWidget {
  final String confirmedPhone;
  final double totalAmount;
  final List<Map<String, dynamic>> products;
  final String referenceNumber;
  final String selectedBank;
  final DateTime selectedDate;
  final double enteredAmount;

  const PaymentVerificationScreen({
    super.key,
    required this.confirmedPhone,
    required this.totalAmount,
    required this.products,
    required this.referenceNumber,
    required this.selectedBank,
    required this.selectedDate,
    required this.enteredAmount,
  });

  @override
  _PaymentVerificationScreenState createState() => _PaymentVerificationScreenState();
}

class _PaymentVerificationScreenState extends State<PaymentVerificationScreen> {
  late String confirmedPhone;
  late DateTime selectedDate;
  late String selectedBank;
  late double enteredAmount;
  late String referenceNumber;

  @override
  void initState() {
    super.initState();
    confirmedPhone = widget.confirmedPhone; 
    selectedDate = widget.selectedDate;
    selectedBank = widget.selectedBank;
    enteredAmount = widget.enteredAmount;
    referenceNumber = widget.referenceNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación de Pago'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
         actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              String title = 'No olvides registrar tu pago';
              String message;

              if (widget.products.isNotEmpty) {
                message = 'Si te retrasas en el pago de ${widget.products.length > 1 ? "los artículos" : "una orden"}, podrías perder la reserva del artículo.';
              } else {
                message = 'Si hiciste un pago, no olvides registrarlo.';
              }

              // Usa el CustomSnackbar para mostrar el Snackbar
              CustomDialog.show(context, title, message);
            }, // Muestra el Snackbar al presionar el icono
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Confirma los datos y sube el comprobante',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Para validar automáticamente, los datos deben ser correctos.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildDataCard(context),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Mostrar diálogo de confirmación
                  _showConfirmationDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Color oscuro
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  textStyle: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                child: Text('Confirmar pago', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Pago'),
          content: const Text('¿Estás seguro de que los datos proporcionados son correctos?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
                
                Navigator.pushAndRemoveUntil( // Navegar a la pantalla de confirmación de pago y borrar el historial
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentConfirmationScreen(
                      confirmedPhone: confirmedPhone,
                      selectedDate: selectedDate,
                      selectedBank: selectedBank,
                      enteredAmount: enteredAmount,
                      referenceNumber: referenceNumber,
                      totalAmount: widget.totalAmount,
                      products: widget.products,
                    ),
                  ),
                  (Route<dynamic> route) => false, // Borrar el historial
                );
              },
              child: const Text('Confirmar'),
            ),
                    ],
        );
      },
    );
  }

  Widget _buildDataCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDataRow('Número de Teléfono', confirmedPhone, context, 'phone'),
            const SizedBox(height: 24),
            _buildDataRow('Fecha', formatDate(selectedDate), context, 'date'),
            const SizedBox(height: 24),
            _buildDataRow('Banco', selectedBank, context, 'bank'),
            const SizedBox(height: 24),
            _buildDataRow('Monto', NumberFormat.currency(locale: 'es', symbol: 'Bs ').format(enteredAmount), context, 'amount'),
            const SizedBox(height: 24),
            _buildDataRow('Número de Referencia', referenceNumber, context, 'reference'),
          ],
        ),
      ),
    );
  }

 Widget _buildDataRow(String title, String value, BuildContext context, String field) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded( // Usar Expanded para que el texto ocupe el espacio disponible
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis, // Agregar esto para truncar el texto si es demasiado largo
              maxLines: 1, // Limitar a una línea
            ),
          ],
        ),
      ),
      IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          // Navegar a la pantalla de edición correspondiente
          _navigateToEditScreen(context, field, value, 'edit');
        },
      ),
    ],
  );
}

  void _navigateToEditScreen(BuildContext context, String field, String currentValue, String action) {
    Widget editScreen;

    switch (field) {
      case 'phone':
        String userId = FirebaseAuth.instance.currentUser ?.uid ?? '';
        editScreen = PhoneVerificationScreen(
          userId: userId,
          totalAmount: widget.totalAmount,
          products: widget.products,
          action: action,
        );
        break;
      case 'date':
        editScreen = PaymentDateScreen(
          confirmedPhone: widget.confirmedPhone,
          totalAmount: widget.totalAmount,
          products: widget.products,
          referenceNumber: widget.referenceNumber,
          selectedBank: widget.selectedBank,
          action: action,
        );
        break;
      case 'bank':
        editScreen = BankSelectionScreen(
          confirmedPhone: widget.confirmedPhone,
          totalAmount: widget.totalAmount,
          products: widget.products,
          referenceNumber: widget.referenceNumber,
          action: action,
        );
        break;
      case 'amount':
        editScreen = ConfirmAmountScreen(
          confirmedPhone: widget.confirmedPhone,
          totalAmount: widget.totalAmount,
          products: widget.products,
          referenceNumber: widget.referenceNumber,
          selectedBank: widget.selectedBank,
          selectedDate: widget.selectedDate,
          action: action,
        );
        break;
      case 'reference':
        editScreen = ReferenceNumberScreen(
          confirmedPhone: widget.confirmedPhone,
          totalAmount: widget.totalAmount,
          products: widget.products,
          action: action,
        );
        break;
      default:
        return; // Si el campo no es válido, no hacemos nada
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => editScreen)).then((newValue) {
      if (newValue != null) {
        // Actualizar el valor en la pantalla de verificación de pago
        setState(() {
          switch (field) {
            case 'phone':
              confirmedPhone = newValue; // Actualiza el número de teléfono
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Número de teléfono actualizado a: $newValue')),
              );
              break;
            case 'date':
              // Actualiza la fecha
              selectedDate = newValue;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fecha actualizada a: ${formatDate(selectedDate)}')),
              );
              break;
            case 'bank':
              selectedBank = newValue; // Actualiza el banco
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Banco actualizado a: $newValue')),
              );
              break;
            case 'amount':
              enteredAmount = newValue; // Actualiza el monto
                            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Monto actualizado a: $newValue')),
              );
              break;
            case 'reference':
              referenceNumber = newValue; // Actualiza el número de referencia
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Número de referencia actualizado a: $newValue')),
              );
              break;
            default:
              return;
          }
        });
      }
    });
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
       