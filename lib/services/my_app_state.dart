import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class MyAppState extends ChangeNotifier {
  List<Product> favorites = [];
  List<Product> allProducts = []; // Lista para almacenar todos los productos

  MyAppState() {
    loadProducts(); // Cargar productos al iniciar
    loadFavorites(); // Cargar favoritos al iniciar
  }

  bool isFavorite(Product product) => favorites.any((fav) => fav.id == product.id);

  Future<void> toggleFavorite(Product product) async {
    final user = FirebaseAuth.instance.currentUser ;
    if (user == null) return;

    final userFavoritesRef = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('favorites');

    if (isFavorite(product)) {
      favorites.removeWhere((fav) => fav.id == product.id);
      await userFavoritesRef.doc(product.id).delete();
    } else {
      favorites.add(product);
      await userFavoritesRef.doc(product.id).set({'id': product.id});
    }

    notifyListeners();
  }

  Future<void> loadFavorites() async {
  final user = FirebaseAuth.instance.currentUser ;
  if (user == null) return;

  final userFavoritesRef = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('favorites');

  userFavoritesRef.snapshots().listen((snapshot) {
    final favoriteIds = snapshot.docs.map((doc) => doc.id).toList();
    favorites = allProducts.where((product) => favoriteIds.contains(product.id)).toList();
    notifyListeners();
  });
}

  Future<void> loadProducts() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    allProducts = snapshot.docs.map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    
    // Cargar favoritos después de cargar todos los productos
    await loadFavorites();
    notifyListeners();
  }

  void clearFavorites() {
    favorites.clear();
    notifyListeners();
  }
}