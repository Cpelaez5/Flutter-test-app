import 'package:flutter/material.dart';
import '../screens/payments/qr_code_display_screen.dart';

void showQrConfirmationDialog(BuildContext context, String token, int orderNumber) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmación de QR'),
        content: Text('No comparta su código QR con nadie más. ¿Desea mostrar su código QR?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
              showQrCode(context, token, orderNumber); // Llama a la función para mostrar el código QR
            },
            child: Text('Mostrar QR'),
          ),
        ],
      );
    },
  );
}

void showQrCode(BuildContext context, String token, int orderNumber) {
  // Aquí llamas a la función que generará y mostrará el código QR
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => QrCodeDisplayScreen(token: token, orderNumber: orderNumber), // Asegúrate de tener esta pantalla
    ),
  );
}