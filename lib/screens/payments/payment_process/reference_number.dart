import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Asegúrate de tener esta dependencia
import '../../../widgets/custom_dialog.dart';
import '../../../widgets/error_dialog.dart';
import 'bank_selection.dart'; // Para acceder al portapapeles

class ReferenceNumberScreen extends StatefulWidget {
  final String confirmedPhone;
  final double totalAmount;
  final List<Map<String, dynamic>> products;
  final String? action;

  const ReferenceNumberScreen({
    super.key,
    required this.confirmedPhone,
    required this.totalAmount,
    required this.products,
    this.action,
  });

  @override
  State<ReferenceNumberScreen> createState() => _ReferenceNumberScreenState();
}

class _ReferenceNumberScreenState extends State<ReferenceNumberScreen> {
  final TextEditingController referenceController = TextEditingController();

  Future<bool> checkReferenceNumberExists(String referenceNumber) async {
    // Consulta Firestore para verificar si el número de referencia ya existe
    final querySnapshot = await FirebaseFirestore.instance
        .collection('payments')
        .where('referenceNumber', isEqualTo: referenceNumber)
        .get();

    return querySnapshot.docs.isNotEmpty; // Retorna true si hay documentos que coinciden
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación de pago'),
        centerTitle: true,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Ingresa el Número de referencia',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                const Icon(Icons.info, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Asegúrate de escribir todos los dígitos.',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: referenceController,
                    decoration: const InputDecoration(
                      labelText: 'Número de referencia',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.paste),
                  onPressed: () async {
                    // Pegar el número de referencia desde el portapapeles
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data != null) {
                      referenceController.text = data.text ?? '';
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Está en el comprobante de pago y puede llamarse Número de operación.',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                String referenceNumber = referenceController.text.trim();

                // Validar que el campo no esté vacío
                if (referenceNumber.isEmpty) {
                  ErrorDialog.show(context, 'Error', 'El número de referencia no puede estar vacío.', null);
                  return;
                }

                // Validar que el número de referencia sea numérico y tenga la longitud correcta
                if (!RegExp(r'^\d{12}$').hasMatch(referenceNumber)) {
                  ErrorDialog.show(context, 'Error', 'El número de referencia debe ser numérico y tener 12 dígitos.', null);
                  return;
                }

                // Verificar si el número de referencia ya existe en Firestore
                bool exists = await checkReferenceNumberExists(referenceNumber);
                if (exists) {
                  ErrorDialog.show(context, 'Error', 'El número de referencia ya ha sido registrado.', null);
                  return;
                }

                if (widget.action == 'edit') {
                  return Navigator.of(context).pop(referenceNumber);
                }

                // Navegar a la siguiente pantalla pasando los datos necesarios
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BankSelectionScreen(
                      confirmedPhone: widget.confirmedPhone,
                      totalAmount: widget.totalAmount,
                      products: widget.products,
                      referenceNumber: referenceNumber,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.deepOrangeAccent,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                textStyle: const TextStyle(fontSize: 18), // Color del texto del botón
              ),
              child: Text(
                widget.action == 'edit' ? 'Editar' : 'Confirmar número',
              ),
            ),
          ],
        ),
      ),
    );
  }
}