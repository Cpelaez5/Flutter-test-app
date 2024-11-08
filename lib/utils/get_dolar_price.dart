import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String> getDolarPrice() async {
  try {
    // Asegúrate de que dotenv esté cargado

    final response = await http.get(Uri.parse('https://api-dolar-vzla.vercel.app/dolar-venezuela'));

    if (response.statusCode == 200) {
      // Si la respuesta es exitosa, parseamos el JSON
      final data = json.decode(response.body);
      // Asegúrate de que 'price' esté en el nivel correcto
      String price = data['price'].toString();
      return price;
    } else {
      // Si la respuesta no fue exitosa, lanza una excepción
      throw Exception('Error al cargar el precio: ${response.statusCode}');
    }
  } catch (e) {
    // Manejo de errores
    return 'Error: $e';
  }
}