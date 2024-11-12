import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'dart:async'; // Para usar StreamSubscription

class QrCodeDisplayScreen extends StatefulWidget {
  final String token;
  final int orderNumber;

  QrCodeDisplayScreen({
    required this.token,
    required this.orderNumber,
  });

  @override
  QrCodeDisplayScreenState createState() => QrCodeDisplayScreenState();
}

class QrCodeDisplayScreenState extends State<QrCodeDisplayScreen> {
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = listenToPaymentStatus(widget.token);
  }

  StreamSubscription listenToPaymentStatus(String token) {
    return FirebaseFirestore.instance
        .collection('payments')
        .where('token', isEqualTo: token)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          var paymentData = change.doc.data();
          if (paymentData != null && paymentData['paymentStatus'] == 'finished') {
            playRandomSound();
            if (mounted) {
              showPaymentCompletedDialog(context);
            }
          }
        }
      }
    });
  }

  Future<void> playRandomSound() async {
    final player = AudioPlayer();
    final random = Random();
    int soundIndex = random.nextInt(3) + 1;

    try {
      await player.play(AssetSource('media/sounds/payment_success_$soundIndex.mp3'));
    } catch (e) {
      print('Error al reproducir el sonido: $e');
    }
  }

  void showPaymentCompletedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30), // Icono de éxito
            SizedBox(width: 10), // Espaciado entre el icono y el texto
            Text(
              'Pago completado',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        content: Text(
          'Su pago ha sido canjeado exitosamente.',
          style: TextStyle(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
              Navigator.of(context).pop(); // Cierra la pantalla del QR
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.green, // Color del texto
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Aceptar',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      );
    },
  );
}

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Código QR'),
        backgroundColor: Colors.deepOrange, // Cambiar el color de la AppBar
      ),
      body: Container(
        color: Colors.grey[100], // Fondo suave
        padding: EdgeInsets.all(16.0), // Espaciado alrededor del contenido
        child: Center(
          child: Card(
            elevation: 8, // Sombra para darle profundidad
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // Bordes redondeados
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0), // Espaciado interno
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pedido N°${widget.orderNumber}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent), // Color destacado
                  ),
                  SizedBox(height: 20),
                  PrettyQrView.data(
                        data: widget.token,
                        errorCorrectLevel: QrErrorCorrectLevel.H,
                        decoration: const PrettyQrDecoration(
                          shape: PrettyQrSmoothSymbol(),
                          image: PrettyQrDecorationImage( // Aquí se usa const
                            image: AssetImage('assets/media/images/logo.png'), // Imagen embebida en el centro
                          ),
                        ),
                      ),
                  SizedBox(height: 20),
                  Text(
                    'Este es su código QR. No lo comparta con nadie.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54), // Color de texto más suave
                  ),
                  SizedBox(height: 20),
                  Icon(
                    Icons.info_outline,
                    size: 32,
                    color: Colors.deepOrangeAccent, // Color del ícono
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}