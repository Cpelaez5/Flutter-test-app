import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'dart:async'; // Para usar StreamSubscription

class QrCodeDisplayScreen extends StatefulWidget {
  final String token;

  QrCodeDisplayScreen({required this.token});

  @override
  _QrCodeDisplayScreenState createState() => _QrCodeDisplayScreenState();
}

class _QrCodeDisplayScreenState extends State<QrCodeDisplayScreen> {
  late StreamSubscription _subscription; // Para manejar la suscripción

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
            // Emitir sonido o feedback al usuario
            playRandomSound();
            // Mostrar el diálogo de pago completado
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
    int soundIndex = random.nextInt(3) + 1; // Genera un número aleatorio entre 1 y 3

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
          title: Text('Pago completado'),
          content: Text('Su pago ha sido canjeado exitosamente.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                Navigator.of(context).pop(); // Cierra la pantalla del QR
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel(); // Cancela el listener al salir de la pantalla
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Código QR'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: widget.token, // El token que se convertirá en código QR
              version: QrVersions.auto,
              size: 200.0, // Tamaño del código QR
              gapless: false,
            ),
            SizedBox(height: 20),
            Text(
              'Este es su código QR. No lo comparta con nadie.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}