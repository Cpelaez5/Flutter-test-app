import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();

    // Verificar si el usuario tiene el rol de administrador
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.getRole(authService.currentUser ?.uid ?? '').then((role) {
      if (role != 'administrador') {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de Administrador'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Dos botones por fila
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildAdminButton('Ver Pedidos', Icons.list, () {
              Navigator.pushNamed(context, '/orders'); // Navegar a la pantalla de pedidos
            }),
            _buildAdminButton('Gestión de Usuarios', Icons.people, () {
              // Navegar a la pantalla de gestión de usuarios
            }),
            _buildAdminButton('Reportes', Icons.report, () {
              // Navegar a la pantalla de reportes
            }),
            _buildAdminButton('Configuraciones', Icons.settings, () {
              // Navegar a la pantalla de configuraciones
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminButton(String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40),
          SizedBox(height: 10),
          Text(title, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}