import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/my_app_state.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Asegúrate de que esta importación esté presente

class FavoritesPage extends StatelessWidget {
  static const routeName = '/favorites'; // Define un nombre de ruta constante

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'), // Usa const aquí
      ),
      body: appState.favorites.isEmpty
          ? const Center( // Usa const aquí
              child: Text('No hay favoritos por aquí.'),
            )
          : ListView.builder(
              itemCount: appState.favorites.length,
              itemBuilder: (context, index) {
                final product = appState.favorites[index];

                return ListTile(
                  leading: const Icon(Icons.favorite), // Usa const aquí
                  title: Text(product.name)
                      .animate()
                      .fadeIn(duration: 500.ms, curve: Curves.easeInOut)
                      .slide(duration: 500.ms, curve: Curves.easeInOut),
                  subtitle: Text('Precio: Bs. ${(product.price).toStringAsFixed(2)}')
                      .animate()
                      .fadeIn(duration: 500.ms, curve: Curves.easeInOut)
                      .slide(duration: 500.ms, curve: Curves.easeInOut),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete), // Usa const aquí
                    onPressed: () {
                      appState.toggleFavorite(product);
                    },
                  ).animate()
                      .fadeIn(duration: 500.ms, curve: Curves.easeInOut)
                      .slide(duration: 500.ms, curve: Curves.easeInOut),
                ).animate()
                    .fadeIn(duration: 500.ms, curve: Curves.easeInOut)
                    .slide(duration: 500.ms, curve: Curves.easeInOut);
              },
            ),
    );
  }
}