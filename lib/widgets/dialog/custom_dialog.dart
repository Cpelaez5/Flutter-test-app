import 'package:flutter/material.dart';
import '../../screens/my_home_page.dart';

class CustomDialog {
  static void show(BuildContext context, String title, String message, ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            width: 300, // Puedes ajustar el ancho según sea necesario
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.grey[900],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Botón "Quiero verificarlo más tarde"
                SizedBox(
                  width: double.infinity, // Ocupa todo el ancho
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => MyHomePage()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.grey[900],
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      elevation: 2,
                    ),
                    child: const Text('Quiero verificarlo más tarde'),
                  ),
                ),
                const SizedBox(height: 8),
                // Botón "Verificar pago ahora"
                SizedBox(
                  width: double.infinity, // Ocupa todo el ancho
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra el diálogo
                      // Aquí puedes agregar la lógica para verificar el pago
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.grey[100],
                      backgroundColor: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      elevation: 2,
                    ),
                    child: const Text('Verificar pago ahora'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}