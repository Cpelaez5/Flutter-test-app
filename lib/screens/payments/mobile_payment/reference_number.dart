import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  @override
  Widget build(BuildContext context) {
    final TextEditingController referenceController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación de pago'),
        centerTitle: true,
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
              onPressed: () {
                if(widget.action == 'edit'){
                    return Navigator.of(context).pop(referenceController.text);
                  }
                // Navegar a la siguiente pantalla pasando los datos necesarios
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BankSelectionScreen(
                      confirmedPhone: widget.confirmedPhone,
                      totalAmount: widget.totalAmount,
                      products: widget.products,
                      referenceNumber: referenceController.text,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.deepOrangeAccent, padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                textStyle: const TextStyle(fontSize: 18), // Color del texto del botón
              ),
              child: Text(
               widget.action == 'edit' ? 'Editar' : 'Confirmar número'
               ),
            ),
          ],
        ),
      ),
    );
  }
}
