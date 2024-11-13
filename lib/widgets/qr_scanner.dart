import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../screens/payments/payment_process/admin_payment_detail_screen.dart';
import '../utils/qr_scanner_border_painter.dart';
import '../widgets/error_dialog.dart';

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

  bool isLoading = false; // Estado de carga
  bool hasScanned = false; // Estado para controlar si ya se ha escaneado un código

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
    WidgetsBinding.instance.addObserver(this);
    _startScanning();
  }

  void _startScanning() {
    _subscription = controller.barcodes.listen((barcodeCapture) {
      if (hasScanned) return; // Si ya se ha escaneado, no hacer nada

      for (var barcode in barcodeCapture.barcodes) {
        final String code = barcode.rawValue ?? '';
        if (uuidRegExp.hasMatch(code)) {
          hasScanned = true; // Marcar que ya se ha escaneado un código
          _fetchPaymentDetails(code); // Busca los detalles del pago
          break; // Salir del bucle después de encontrar un código válido
        }
      }
    });
    controller.start();
  }
  
  bool isErrorDialogShown = false; // Nueva variable para controlar el estado del diálogo de error

Future<void> _fetchPaymentDetails(String token) async {
  setState(() {
    isLoading = true; // Mostrar indicador de carga
  });

  try {
    QuerySnapshot paymentSnapshot = await FirebaseFirestore.instance
        .collection('payments')
        .where('token', isEqualTo: token)
        .limit(1)
        .get();

    if (paymentSnapshot.docs.isNotEmpty) {
      DocumentSnapshot paymentDoc = paymentSnapshot.docs.first;
      Payment payment = Payment.fromFirestore(paymentDoc); // Crear Payment desde Firestore

      // Verificar si el pago ya está finalizado
      if (payment.paymentStatus == 'finished') {
        // Detener el escáner
        controller.stop(); // Detener el escáner

        // Mostrar error si el pedido ya ha sido finalizado
        await ErrorScannerDialog.show(context, 'Pedido Finalizado', 'Este pedido ya ha sido marcado como finalizado.', Colors.red);
        
        // Reiniciar el escáner después de que el diálogo se cierre
        setState(() {
          hasScanned = false; // Reiniciar el estado de escaneo
        });
        _startScanning(); // Reiniciar el escáner
      } else {
        // Navegar a la nueva pantalla de detalles del pago para el administrador
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AdminPaymentDetailScreen(
              payment: payment,
            ),
          ),
        ).then((_) {
          // Reiniciar el escáner al volver
          setState(() {
            hasScanned = false; // Reiniciar el estado de escaneo
          });
          _startScanning(); // Reiniciar el escáner
        });
      }
    } else {
      // Mostrar error si no se encuentra el pago
      await ErrorScannerDialog.show(context, 'No encontrado', 'Este código QR no corresponde a ningun pago.', Colors.red);
      
      // Reiniciar el escáner después de que el diálogo se cierre
      setState(() {
        hasScanned = false; // Reiniciar el estado de escaneo
      });
      _startScanning(); // Reiniciar el escáner
    }
  } catch (e) {
    // Mostrar error en caso de excepción
    await ErrorScannerDialog.show(context, 'Error', 'Error al buscar el pago: $e', Colors.red);
    
    // Reiniciar el escá ner después de que el diálogo se cierre
    setState(() {
      hasScanned = false; // Reiniciar el estado de escaneo
    });
    _startScanning(); // Reiniciar el escáner
  } finally {
    setState(() {
      isLoading = false; // Ocultar indicador de carga
    });
  }
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
      body: Stack(
        children: [
          MobileScanner(controller: controller),
          if (isLoading)
            Center(child: CircularProgressIndicator()), // Indicador de carga
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: CustomPaint(
                painter: QRScannerBorderPainter(),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 12,
            right: 12,
            child: Column(
              children: [
                Text(
                  'Apunta la cámara hacia el código QR',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color.fromARGB(220, 255, 255, 255)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Asegúrate de que el código esté bien iluminado y visible.',
                  style: TextStyle(fontSize: 16, color: const Color.fromARGB(160, 255, 255, 255)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}