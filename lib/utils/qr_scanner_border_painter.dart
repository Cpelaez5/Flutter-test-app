import 'package:flutter/material.dart';

class QRScannerBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepOrangeAccent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Dibujar las esquinas
    canvas.drawLine(Offset(0, 0), Offset(40, 0), paint); // Top left horizontal
    canvas.drawLine(Offset(0, 0), Offset(0, 40), paint); // Top left vertical

    canvas.drawLine(Offset(size.width, 0), Offset(size.width - 40, 0), paint); // Top right horizontal
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, 40), paint); // Top right vertical

    canvas.drawLine(Offset(0, size.height), Offset(40, size.height), paint); // Bottom left horizontal
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - 40), paint); // Bottom left vertical

    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - 40, size.height), paint); // Bottom right horizontal
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - 40), paint); // Bottom right vertical
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }  
}