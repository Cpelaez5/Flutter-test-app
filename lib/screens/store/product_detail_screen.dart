import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart.dart';
import '../../models/product.dart';
import '../../main.dart'; // Asegúrate de importar donde está definido MyAppState

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
              Image.network(widget.product.imageUrl, height: 200, fit: BoxFit.cover),
              SizedBox(height: 16),
              Text(widget.product.description),
              SizedBox(height: 16),
              Row(
                children: [
                  Text('Cantidad:'),
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (quantity > 1) quantity--;
                      });
                    },
                  ),
                  Text(quantity.toString()),
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
                child: Text('Agregar al carrito'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}