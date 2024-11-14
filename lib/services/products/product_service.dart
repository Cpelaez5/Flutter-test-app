import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Asegúrate de importar Firebase Auth

class ProductService {
  // Función para obtener productos desde Firestore
  Future<List<Product>> fetchProducts() async {
    List<Product> products = [];
    
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('products').get();
      String userRole = await getUserRole(); // Obtener el rol del usuario actual

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        Product product = Product.fromMap(data, doc.id); // Usar el método fromMap

        // Filtrar productos si el rol no es 'administrador'
        if (userRole == 'administrador' || 
            (product.status != 'inactive' && product.stock > 0)) {
          products.add(product);
        }
      }
    } catch (e) {
      print('Error al obtener productos: $e');
    }
    
    return products;
  }

  // Método para obtener el rol del usuario actual
  Future<String> getUserRole() async {
    String role = 'usuario'; // Valor por defecto en caso de que no se encuentre el rol
    try {
      User? user = FirebaseAuth.instance.currentUser ;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        role = userDoc['role'] ?? role; // Obtener el rol del documento del usuario
      }
    } catch (e) {
      print('Error al obtener el rol del usuario: $e');
    }
    return role;
  }
}