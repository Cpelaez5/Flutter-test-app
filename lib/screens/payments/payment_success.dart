import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/my_home_page.dart';
import 'package:flutter_application_1/screens/users/user_order_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:false,
      onPopInvokedWithResult: (didPop, result) => {
        Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MyHomePage()),
      (Route<dynamic> route) => false, // Elimina todas las rutas
    ),
        false // Esto indica que no se debe permitir el pop.
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Pago Exitoso'),
          centerTitle: true,
          automaticallyImplyLeading: false, // Oculta la flecha de retroceso
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.greenAccent, Colors.lightGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 100,
                    color: Colors.white,
                  ),
                  SizedBox(height: 20),
                  Text(
                    '¡Tu pago ha sido registrado con éxito!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Le enviaremos una notificación cuando el pedido sea confirmado.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => UserOrdersScreen(userId: user!.uid)),
                        (Route<dynamic> route) => true,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.green, backgroundColor: Colors.white, // Color del texto del botón
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Ver mi pedido',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}