import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeDisplayScreen extends StatelessWidget {
  final String token;

  QrCodeDisplayScreen({required this.token});

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
            // Asegúrate de que estás usando el constructor correcto
            QrImageView(
              data: token, // El token que se convertirá en código QR
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