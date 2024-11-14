import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategorySelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Categoría'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('products').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No hay categorías disponibles.',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            );
          }

          // Obtener categorías únicas
          Set<String> categories = {};
          for (var doc in snapshot.data!.docs) {
            categories.add(doc['category']);
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: categories.map((category) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(
                    category,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context, category);
                  },
                ),
              );
            }).toList()
             ..add(Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepOrange, // Color de fondo del botón
                  borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
                ),
                child: ListTile(
                  title: Text(
                    'Crear nueva categoría',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white), // Cambiar el color del texto
                    textAlign: TextAlign.center,
                  ),
                  onTap: () {
                    _showCreateCategoryDialog(context);
                  },
                ),
              ),
            )),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.white, // Color de fondo del contenedor
        child: Text(
          'Las categorías se actualizan automáticamente a medida que se añaden nuevas.',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center, // Centrar el texto
        ),
      ),
    );
  }

  void _showCreateCategoryDialog(BuildContext context) {
  final TextEditingController controller = TextEditingController();
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0), // Bordes redondeados
        ),
        title: Row(
          children: [
            Icon(Icons.category, color: Colors.deepOrange),
            SizedBox(width: 8.0),
            Expanded( // Usar Expanded para evitar desbordamiento
              child: Text('Nueva Categoría'),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Nombre de la categoría',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.deepOrange),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            ),
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.deepOrange,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: () {
              final newCategory = controller.text.trim();
              if (newCategory.isNotEmpty) {
                Navigator.pop(context);
                Navigator.pop(context, newCategory);
              }
            },
            child: Text('Crear', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}
}