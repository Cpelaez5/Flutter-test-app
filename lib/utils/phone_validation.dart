
import '../data/payment_data.dart';

bool validatePhoneNumber(String phone) {
  // Eliminar espacios en blanco
  phone = phone.replaceAll(RegExp(r'\s+'), '');

  // Expresión regular para validar el formato "0424-918.52.44" o "04249185244"
  final RegExp phoneRegex = RegExp(r'^(0424-\d{3}\.\d{2}\.\d{2}|\d{11})$');

  // Validar que no esté vacío
  if (phone.isEmpty) {
    return false; // El número no puede estar vacío
  }

  // Validar longitud y formato
  if (phone.length != 11 && !phoneRegex.hasMatch(phone)) {
    return false; // El número debe tener 11 dígitos o cumplir con el formato
  }

  // Validar que empiece con uno de los prefijos válidos
  String prefix = phone.substring(0, 4);
  if (!phonePrefixes.contains(prefix)) {
    return false; // El número no comienza con un prefijo válido
  }

  return true; // El número es válido
}