import '../models/product.dart';

List<Product> products = [
  Product(
    id: 1,
    name: 'Cachito',
    price: 44.08,
    description: '¡Prueba nuestros únicos y deliciosos cachitos! De sabor auténtico, nuestros cachitos recién horneados, son el complemento perfecto para cualquier hora del día.',
    imageUrl: 'https://le-petit.labrioche.com.ve/wp-content/uploads/2024/05/cachito.png', // Asegúrate de usar URLs válidas
  ),
  Product(
    id: 2,
    name: 'Empanada',
    price: 35.26,
    description: 'La empanada, el clásico alimento que combina sabor, portabilidad y calidad. Estas delicias fritas y rellenas son la comida perfecta cuando se trata de versatilidad y sabor.',
    imageUrl: 'https://le-petit.labrioche.com.ve/wp-content/uploads/2024/05/Empanada-1.png',
  ),
  // Agrega más productos según sea necesario
];

class ProductData {
  final int id;
  final int quantity;
  final double price;

  ProductData({
    required this.id,
    required this.quantity,
    required this.price,
  });
}