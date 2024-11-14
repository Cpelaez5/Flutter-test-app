// product_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/cart.dart';
import '../../models/product.dart';
import '../../screens/admin/products/product_admin_detail_screen.dart';
import '../../screens/store/product_detail_screen.dart';
import '../../services/my_app_state.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final Cart cart;
  final String userRole; // Agregar el rol del usuario

  const ProductCard({required this.product, required this.cart, required this.userRole, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MyAppState>(
      builder: (context, appState, child) {
        final isFavorite = appState.isFavorite(product);

        return GestureDetector(
          onTap: () {
            if (userRole == 'administrador') {
              Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminProductDetailScreen(product: product),
              ),
            );
            } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product, cart: cart),
              ),
            );
            }
          },
          child: Card(
            child: Column(
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Bs. ${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),
                // Mostrar el corazón de favorito solo si el rol es 'cliente'
                if (userRole == 'cliente') 
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      appState.toggleFavorite(product);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}