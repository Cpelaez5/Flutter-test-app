import 'package:flutter/material.dart';

class ConfirmationDialog {
  static Future<void> show(BuildContext context, String title, String content, Function onConfirm) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
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
                onConfirm(); // Llama a la función de confirmación
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}