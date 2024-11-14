import 'package:flutter/material.dart';
import '../../../widgets/users/square_button.dart';
import 'create_product_screen.dart';

class ProductOptionsScreen extends StatelessWidget {
  const ProductOptionsScreen({Key? key}) : super(key: key);

  void _navigateToCreateProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateProductScreen(),
      ),
    );
  }

  void _navigateToImportProducts(BuildContext context) {
    // Asegúrate de tener la pantalla de importar productos implementada
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => const CreateProductScreen(), // Cambia esto a la pantalla correcta
    //   ),
    // );
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cargar Productos', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepOrange,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepOrange[100]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ' ¿Qué deseas hacer?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),
                // Botón de Producto Individual
                SizedBox(
                  width: double.infinity,
                  child: buildSquareButton(
                    'Producto Individual',
                    Icons.add_circle_outline,
                    () => _navigateToCreateProduct(context),
                  ),
                ),
                const SizedBox(height: 20),
                // Botón de Importar Productos
                SizedBox(
                  width: double.infinity,
                  child: buildSquareButton(
                    'Importar Productos',
                    Icons.file_upload,
                    () => _navigateToImportProducts(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}