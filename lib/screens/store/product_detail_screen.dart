import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart.dart';
import '../../models/product.dart';
import '../../services/my_app_state.dart'; 
import 'package:flutter_animate/flutter_animate.dart'; // Asegúrate de que esta importación esté presente
import 'package:cached_network_image/cached_network_image.dart'; // Importar el paquete

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final Cart cart;

  const ProductDetailScreen({required this.product, required this.cart, super.key});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final isFavorite = appState.isFavorite(widget.product); // Guardar en variable local

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey,
            ),
            onPressed: () {
              appState.toggleFavorite(widget.product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite
                        ? '${widget.product.name} eliminado de favoritos'
                        : '${widget.product.name} añadido a favoritos',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mostrar la imagen del producto con caché y animación
              Hero(
                tag: widget.product.id, // Asegúrate de que el ID del producto sea único
                child: CachedNetworkImage(
                  imageUrl: widget.product.imageUrl,
                  height: 250,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ).animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut),
              ),
              const SizedBox(height: 16),
              // Mostrar el nombre del producto
              Text(
                widget.product.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Mostrar el precio del producto
              Text(
                'Bs. ${widget.product.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Mostrar la descripción del producto
              Text(
                widget.product.description,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              // Selector de cantidad
              Row(
                children: [
                  const Text('Cantidad:', style: TextStyle(fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (quantity > 1) quantity--;
                      });
                    },
                  ),
                  Text(quantity.toString(), style: const TextStyle(fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        quantity++;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Mostrar subtotal
              Text(
                'Subtotal: Bs. ${(widget.product.price * quantity).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Corrección aquí
              ),
              const SizedBox(height: 16),
              // Botón para agregar al carrito
              ElevatedButton(
                onPressed: () {
                  for (int i = 0; i < quantity; i++) {
                    widget.cart.addProduct(widget.product);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$quantity ${widget.product.name} agregado(s) al carrito'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  textStyle: const TextStyle(fontSize: 18), // Color del botón
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Agregar al carrito'),
              ).animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut),
            ],
          ),
        ),
      ),
    );
  }
}