import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/my_app_state.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Asegúrate de que esta importación esté presente

class FavoritesPage extends StatelessWidget {
  static var routeName;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Favoritos'),
      ),
      body: appState.favorites.isEmpty
          ? Center(
              child: Text('No hay favoritos por aquí.'),
            )
          : ListView.builder(
              itemCount: appState.favorites.length,
              itemBuilder: (context, index) {
                final product = appState.favorites[index];

                return ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text(product.name).animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut).slide(duration: 500.ms, curve: Curves.easeInOut),
                  subtitle: Text('Precio: \$${product.price}').animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut).slide(duration: 500.ms, curve: Curves.easeInOut),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      appState.toggleFavorite(product);
                    },
                  ).animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut).slide(duration: 500.ms, curve: Curves.easeInOut),
                ).animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut).slide(duration: 500.ms, curve: Curves.easeInOut);
              },
            ),
    );
  }
}