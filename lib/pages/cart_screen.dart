import 'package:flutter/material.dart';

import '../models/cart.dart';

class CartScreen extends StatefulWidget {
  final Cart cart;

  CartScreen({required this.cart});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrito'),
      ),
      body: widget.cart.products.isEmpty
          ? Center(child: Text('No hay nada en el carrito'))
          : ListView.builder(
              itemCount: widget.cart.products.length,
              itemBuilder: (context, index) {
                final product = widget.cart.products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text(product.description),
                  trailing: Text('\$${product.price}'),
                );
              },
            ),
    );
  }
}