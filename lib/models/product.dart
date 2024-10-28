import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int stock;
  final Timestamp createdAt;
  final String status;
  int quantity; // Este campo se puede modificar

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock,
    required this.createdAt,
    required this.status,
    this.quantity = 0, // Inicializa la cantidad a 0
  });

  // Método para crear un producto desde un mapa
  factory Product.fromMap(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      stock: data['stock'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      status: data['status'] ?? '',
      quantity: 0, // Inicializa la cantidad a 0
    );
  }

  // Método para convertir el producto a un mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'stock': stock,
      'createdAt': createdAt,
      'status': status,
      'quantity': quantity,
    };
  }
}