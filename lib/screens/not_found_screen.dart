import 'package:flutter/material.dart';

class NotFoundScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('No Encontrado'),
      ),
      body: Center(
        child: Text('La página que buscas no existe.'),
      ),
    );
  }
}