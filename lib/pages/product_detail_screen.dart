

import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../models/product.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: SingleChildScrollView( // Envuelve la Column en un SingleChildScrollView
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
                  Navigator.pop(context);
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