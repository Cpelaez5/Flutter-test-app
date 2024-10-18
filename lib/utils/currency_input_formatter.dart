import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    // Solo permitir números
    newText = newText.replaceAll(RegExp(r'[^0-9]'), '');

    // Si el texto está vacío, devolverlo tal cual
    if (newText.isEmpty) {
      return TextEditingValue(text: '');
    }

    // Convertir a un número
    double value = double.tryParse(newText) ?? 0.0;

    // Formatear el número como decimal con coma
    String formattedText = NumberFormat.decimalPattern('es_VE').format(value / 100);

    // Asegurarse de que el formato tenga siempre dos decimales
    if (formattedText.endsWith(',') || formattedText.endsWith('.')) {
      formattedText += '00'; // Agregar ceros si termina en coma o punto
    } else if (formattedText.split(',').length > 1) {
      // Si ya tiene decimales, asegurarse de que tenga dos
      List<String> parts = formattedText.split(',');
      if (parts[1].length < 2) {
        formattedText = '${parts[0]},${parts[1].padRight(2, '0')}';
      }
    } else {
      formattedText += ',00'; // Si no tiene decimales, agregar ',00'
    }

    // Calcular la posición del cursor
    int cursorOffset = formattedText.length;

    // Ajustar la posición del cursor
    if (oldValue.text.length > newText.length) {
      // Si se está borrando, ajustar la posición del cursor
      cursorOffset = cursorOffset.clamp(0, formattedText.length);
    } else {
      // Si se está escribiendo, mantener el cursor al final
      cursorOffset = formattedText.length;
    }

    // Devolver el nuevo valor formateado
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorOffset), // Colocar el cursor en la nueva posición
    );
  }
}