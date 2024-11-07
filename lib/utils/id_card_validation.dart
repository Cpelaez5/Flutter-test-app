bool validateIdCard(String idCard) {
  // Expresión regular para validar el formato de la cédula
  final RegExp idCardRegex = RegExp(r'^(V|E)-?\d{7,8}$');
  return idCardRegex.hasMatch(idCard);
}