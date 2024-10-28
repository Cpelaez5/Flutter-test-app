import 'package:flutter/material.dart';

import '../widgets/auth_wrapper.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.coffee, size: 100, color: Colors.brown),
            SizedBox(height: 20),
            Text('Mi Cafetín', style: TextStyle(fontSize: 24)),
            Text('¡Bienvenido!', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  @override
  SplashScreenWrapperState createState() => SplashScreenWrapperState();
}

class SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AuthWrapper()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(); // Asegúrate de que esta clase esté definida en splash_screen.dart
  }
}