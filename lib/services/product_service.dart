import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  // Función para obtener productos desde Firestore
  Future<List<Product>> fetchProducts() async {
    List<Product> products = [];
    
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('products').get();
      
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        products.add(Product.fromMap(data, doc.id)); // Usar el método fromMap
      }
    } catch (e) {
      print('Error al obtener productos: $e');
    }
    
    return products;
  }
}