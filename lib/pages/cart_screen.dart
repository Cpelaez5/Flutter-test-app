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
              shrinkWrap: true,
              itemCount: widget.cart.products.length,
              itemBuilder: (context, index) {
                final product = widget.cart.products[index];
                final totalProductPrice = product.price * product.quantity;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      if (product.imageUrl != null)
                        Image.network(
                          product.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      else
                        Icon(Icons.image_not_supported, size: 50),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name, style: TextStyle(fontSize: 16)),
                            Text('\$${product.price} x ${product.quantity}'),
                            Text('Total: \$${totalProductPrice.toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            widget.cart.removeProduct(product);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}