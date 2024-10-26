import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'auth_service.dart';
import '../data/products.dart';

class MyAppState extends ChangeNotifier {
  List<Product> favorites = [];

  bool isFavorite(Product product) => favorites.any((fav) => fav.id == product.id);

  Future<void> toggleFavorite(Product product) async {
    final user = FirebaseAuth.instance.currentUser ;
    if (user == null) return;

    final userFavoritesRef = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('favorites');

    if (isFavorite(product)) {
      favorites.removeWhere((fav) => fav.id == product.id);
      await userFavoritesRef.doc(product.id.toString()).delete();
    } else {
      favorites.add(product);
      await userFavoritesRef.doc(product.id.toString()).set({'id': product.id});
    }

    notifyListeners();
  }

  Future<void> loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser ;
    if (user == null) return;

    final userFavoritesRef = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('favorites');
    final snapshot = await userFavoritesRef.get();
    final favoriteIds = snapshot.docs.map((doc) => int.parse(doc.id)).toList();

    favorites = products.where((product) => favoriteIds.contains(product.id)).toList();
    notifyListeners();
  }

  void clearFavorites() {
    favorites.clear();
    notifyListeners();
  }
}