import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';

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
                  title: Text(product.name),
                  subtitle: Text('Precio: \$${product.price}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      appState.toggleFavorite(product);
                    },
                  ),
                );
              },
            ),
    );
  }
}