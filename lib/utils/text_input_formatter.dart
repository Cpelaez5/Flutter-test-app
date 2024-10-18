import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    // Solo permitir números y guiones
    newText = newText.replaceAll(RegExp(r'[^0-9-]'), '');

    // Limitar la longitud a 8 caracteres (DD-MM-AA)
    if (newText.length > 8) {
      newText = newText.substring(0, 8);
    }

    // Formato DD-MM-AA
    if (newText.length >= 2) {
      if (newText.length > 2 && newText[2] != '-') {
        newText = '${newText.substring(0, 2)}-${newText.substring(2)}';
      }
    }
    
    if (newText.length >= 5) {
      if (newText.length > 5 && newText[5] != '-') {
        newText = '${newText.substring(0, 5)}-${newText.substring(5)}';
      }
    }

    // Asegurarse de que no se intente acceder a índices fuera de rango
    if (newText.length > 2 && newText[2] == '-') {
      // Si hay un guion en la posición correcta, asegurarse de que el día no exceda 31
      String day = newText.substring(0, 2);
      if (int.tryParse(day) != null && int.parse(day) > 31) {
        newText = '31${newText.substring(2)}';
      }
    }

    if (newText.length > 5 && newText[5] == '-') {
      // Si hay un guion en la posición correcta, asegurarse de que el mes no exceda 12
      String month = newText.substring(3, 5);
      if (int.tryParse(month) != null && int.parse(month) > 12) {
        newText = '${newText.substring(0, 3)}12${newText.substring(5)}';
      }
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}