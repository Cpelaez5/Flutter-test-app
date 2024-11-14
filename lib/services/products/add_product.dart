import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addProduct({
  required String name,
  required double price,
  required String description,
  required String imageUrl,
  required String category,
  required int stock,
  required String status,
}) async {
  CollectionReference products = FirebaseFirestore.instance.collection('products');

  // Crea un nuevo documento con un ID único
  await products.add({
    'name': name,
    'price': price,
    'description': description,
    'imageUrl': imageUrl,
    'category': category,
    'stock': stock,
    'createdAt': FieldValue.serverTimestamp(), // Guarda la fecha y hora del servidor
    'status': status,
  });
}