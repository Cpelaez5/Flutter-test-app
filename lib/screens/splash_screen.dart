import 'package:flutter/material.dart';

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
            Text('Cafetín Ibero', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}