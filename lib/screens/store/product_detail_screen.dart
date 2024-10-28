import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart.dart';
import '../../models/product.dart';
import '../../services/my_app_state.dart'; 
import 'package:flutter_animate/flutter_animate.dart'; // Asegúrate de que esta importación esté presente

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final Cart cart;

  ProductDetailScreen({required this.product, required this.cart});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          IconButton(
            icon: Icon(
              appState.isFavorite(widget.product) ? Icons.favorite : Icons.favorite_border,
              color: appState.isFavorite(widget.product) ? Colors.red : Colors.grey,
            ),
            onPressed: () {
              appState.toggleFavorite(widget.product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    appState.isFavorite(widget.product)
                        ? '${widget.product.name} añadido a favoritos'
                        : '${widget.product.name} eliminado de favoritos',
                  ),
                  duration: Duration(seconds: 2),
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
              // Mostrar la imagen del producto con animación
              Hero(
                tag: widget.product.id, // Asegúrate de que el ID del producto sea único
                child: Image.network(
                  widget.product.imageUrl,
                  height: 250,
                  fit: BoxFit.cover,
                ).animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut),
              ),
              SizedBox(height: 16),
              // Mostrar el nombre del producto
              Text(
                widget.product.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              // Mostrar el precio del producto
              Text(
                '\$${widget.product.price.toStringAsFixed(2)}', // Asegúrate de que price sea un double
                style: TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              // Mostrar la descripción del producto
              Text(
                widget.product.description,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              // Selector de cantidad
              Row(
                children: [
                  Text('Cantidad:', style: TextStyle(fontSize: 18)),
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (quantity > 1) quantity--;
                      });
                    },
                  ),
                  Text(quantity.toString(), style: TextStyle(fontSize: 18)),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        quantity++;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Mostrar subtotal
              Text(
                'Subtotal: \$${(widget.product.price * quantity).toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              // Botón para agregar al carrito
              ElevatedButton(
                onPressed: () {
                  for (int i = 0; i < quantity; i++) {
                    widget.cart.addProduct(widget.product);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$quantity ${widget.product.name} agregado(s) al carrito'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  textStyle: TextStyle(fontSize: 18), // Color del botón
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Agregar al carrito'),
              ).animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut),
            ],
          ),
        ),
      ),
    );
  }
}