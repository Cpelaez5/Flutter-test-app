import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/admin/admin_screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRScanner extends StatefulWidget {
  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> with WidgetsBindingObserver {
  late MobileScannerController controller;
  StreamSubscription<BarcodeCapture>? _subscription;
  final RegExp uuidRegExp = RegExp(
    r'^[{(]?([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})[)}]?$',
  );

  Map<String, dynamic>? paymentData; // Para almacenar los datos del pago
  String? documentId; // Para almacenar el ID del documento

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
    WidgetsBinding.instance.addObserver(this);
    _subscription = controller.barcodes.listen((barcodeCapture) {
      for (var barcode in barcodeCapture.barcodes) {
        final String code = barcode.rawValue ?? '';
        print("Código escaneado: $code"); // Agrega esto para depuración
        if (uuidRegExp.hasMatch(code)) {
          _fetchPaymentDetails(code); // Busca los detalles del pago
          break; // Salir del bucle después de encontrar un código válido
        }
      }
    });
    controller.start();
  }

  Future<void> _fetchPaymentDetails(String token) async {
    try {
      // Realiza la consulta a Firestore
      QuerySnapshot paymentSnapshot = await FirebaseFirestore.instance
          .collection('payments')
          .where('token', isEqualTo: token)
          .limit(1)
          .get();

      print("Documentos encontrados: ${paymentSnapshot.docs.length}");

      // Verifica si hay documentos en el snapshot
      if (paymentSnapshot.docs.isNotEmpty) {
        // Accede al primer documento
        DocumentSnapshot paymentDoc = paymentSnapshot.docs.first;
        setState(() {
          paymentData = paymentDoc.data() as Map<String, dynamic>;
          documentId = paymentDoc.id; // Almacena el ID del documento
        });
      } else {
        _showSnackBar('No se encontró ningún pago con ese token.');
      }
    } catch (e) {
      _showSnackBar('Error al buscar el pago: $e');
    }
  }

  void _finalizePayment() async {
    if (paymentData != null && documentId != null) {
      print("Datos del pago: $paymentData");
      try {
        await FirebaseFirestore.instance
            .collection('payments')
            .doc(documentId) // Usa el ID del documento almacenado
            .update({'paymentStatus': 'finished'});

        _showSnackBar('Pago finalizado exitosamente.');
        setState(() {
          paymentData = null; // Limpiar los datos del pago después de finalizar
          documentId = null; // Limpiar el ID del documento
        });

        Navigator.pushAndRemoveUntil( // Navegar a la pantalla de confirmación de pago y borrar el historial
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminScreen(),
                  ),
                  (Route<dynamic> route) => false, // Borrar el historial
                );

      } catch (e) {
        _showSnackBar('Error al finalizar el pago: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escanear Código QR'),
      ),
      body: paymentData == null
          ? MobileScanner(controller: controller)
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detalles del Pago:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('Referencia: ${paymentData!['referenceNumber']}'),
                  Text('Monto: ${paymentData!['paymentAmount']} Bs.'),
                  Text('Estado: ${paymentData!['paymentStatus']}'),
                  Text('Banco: ${paymentData!['selectedBank']}'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _finalizePayment,
                    child: Text('Finalizar Pedido'),
                  ),
                ],
              ),
            ),
    );
  }
}