import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

Widget buildSquareButton(String title, IconData icon, VoidCallback onPressed) {
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
        Icon(icon, size: 40).animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut).slide(duration: 500.ms, curve: Curves.easeInOut),
        SizedBox(height: 10),
        Text(title, style: TextStyle(fontSize: 16)).animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut).slide(duration: 500.ms, curve: Curves.easeInOut),
      ],
    ),
  ).animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut).slide(duration: 500.ms, curve: Curves.easeInOut);
}
