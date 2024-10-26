import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/square_button.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  // Variable de instancia para el rol del usuario
  String? userRole;

  @override
  void initState() {
    super.initState();
    // Verificar si el usuario tiene un rol
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.getRole(authService.currentUser?.uid ?? '').then((role) {
      if (role == null) {
        Navigator.of(context).pushReplacementNamed('/');
      } else {
        // Actualizar el rol del usuario
        setState(() {
          userRole = role;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Dos botones por fila
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            if (userRole == 'cliente')
            buildSquareButton('Mis Pedidos', Icons.list, () {
              // Navegar a la pantalla de gestión de usuarios
            }),
            buildSquareButton('Mis Datos', Icons.person, () {
              Navigator.pushNamed(context, '/profile'); // Navegar a la pantalla de pedidos
            }),
            buildSquareButton('Reportes', Icons.report, () {
              // Navegar a la pantalla de reportes
            }),
            buildSquareButton('Configuraciones', Icons.settings, () {
              // Navegar a la pantalla de configuraciones
            }),
          ],
        ),
      ),
    );
  }
}