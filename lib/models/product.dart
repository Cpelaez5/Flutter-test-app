class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  int quantity = 1; // Agregamos la propiedad quantity

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}