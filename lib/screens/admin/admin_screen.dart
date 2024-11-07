import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth/auth_service.dart';
import '../../widgets/qr_scanner.dart';
import '../../widgets/square_button.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
   String? userRole;

  @override
  void initState() {
    super.initState();
    // Verificar si el usuario tiene un rol
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.getRole(authService.currentUser?.uid ?? '').then((role) {
      if (role != 'administrador') {
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
        title: Text('Panel de Administrador'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Dos botones por fila
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            buildSquareButton('Escanear QR', Icons.qr_code, () {
                  Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QRScanner(),
                ),
              );
            }),
            buildSquareButton('Ver Pedidos', Icons.list, () {
              Navigator.pushNamed(context, '/orders'); // Navegar a la pantalla de pedidos
            }),
            buildSquareButton('Usuarios', Icons.people, () {
              // Navegar a la pantalla de gestión de usuarios
            }),
          ],
        ),
      ),
    );
  }
}