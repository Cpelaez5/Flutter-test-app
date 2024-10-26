import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/products.dart'; // Importa la lista de productos
import '../../models/cart.dart';
import '../../services/my_app_state.dart';
import 'product_detail_screen.dart';
import 'search_page.dart'; // Importa la página de búsqueda
import 'package:flutter_animate/flutter_animate.dart'; // Asegúrate de que esta importación esté presente

class ProductScreen extends StatelessWidget {
  final Cart cart;

  ProductScreen({required this.cart});

  @override
  Widget build(BuildContext context) {
    // Accede al estado de la aplicación
    final appState = Provider.of<MyAppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Productos'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Navegar a la página de búsqueda y pasar la lista de productos
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductSearchPage(products: products, cart: cart),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Número de columnas
            childAspectRatio: 1.9 / 2, // Relación de aspecto de cada tarjeta
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final isFavorite = appState.isFavorite(product);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(product: product, cart: cart),
                  ),
                );
              },
              child: Card(
                child: Column(
                  children: [
                    // Animar la imagen
                    Expanded(
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ).animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut).slide(duration: 500.ms, curve: Curves.easeInOut),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Animar el nombre del producto
                                Text(
                                  product.name,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ).animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut).slide(duration: 500.ms, curve: Curves.easeInOut),
                                // Animar el precio del producto
                                Text(
                                  '\$${product.price}',
                                ).animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut).slide(duration: 500.ms, curve: Curves.easeInOut),
                              ],
                            ),
                          ),
                          // Animar el icono de favorito
                          IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                            ),
                            onPressed: () {
                              appState.toggleFavorite(product);
                            },
                          ).animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut).slide(duration: 500.ms, curve: Curves.easeInOut),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut).slide(duration: 500.ms, curve: Curves.easeInOut),
            );
          },
        ),
      ),
    );
  }
}