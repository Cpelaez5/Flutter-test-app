class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  int quantity; // Agregamos la propiedad quantity

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.quantity = 1, // Valor por defecto para quantity
  });

  // Método para convertir a mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  // Método para crear un producto a partir de un mapa (opcional)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      imageUrl: map['imageUrl'],
      quantity: map['quantity'] ?? 1, // Valor por defecto si no se proporciona
    );
  }
}