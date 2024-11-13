import 'package:flutter/material.dart';

class UserDetailScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  UserDetailScreen({required this.user});

  @override
  void _confirmDelete(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar este usuario?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar el diálogo
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Implementar la lógica de eliminación aquí
              Navigator.of(context).pop(); // Cerrar el diálogo
            },
            child: Text('Eliminar'),
          ),
        ],
      );
    },
  );
}
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user['name'] ?? 'Nombre no disponible',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text('ID: ${user['idCard'] ?? 'ID no disponible'}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8.0),
            Text('Email: ${user['email'] ?? 'Email no disponible'}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8.0),
            // Agrega más detalles aquí si es necesario
            Spacer(),
            ElevatedButton(
              onPressed: () {
                // Implementar lógica para editar el usuario
                // Por ejemplo, navegar a una pantalla de edición
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text('Editar Usuario'),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                _confirmDelete(context);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.0), backgroundColor: Colors.red,
                textStyle: TextStyle(fontSize: 18), // Color rojo para el botón de eliminar
              ),
              child: Text('Eliminar Usuario'),
            ),
          ],
        ),
      ),
    );
  }
}