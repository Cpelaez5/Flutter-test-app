
import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../models/product.dart';
import 'cart_screen.dart';

class ProductScreen extends StatelessWidget {
  final Cart cart;

  ProductScreen({required this.cart});

  @override
  Widget build(BuildContext context) {
    final products = [
      Product(id:1, name: 'Producto 1', description: 'Descripción 1', price: 10.0),
      Product(id:2,name: 'Producto 2', description: 'Descripción 2', price: 20.0),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Productos'),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(products[index].name),
            subtitle: Text(products[index].description),
            trailing: ElevatedButton(
              onPressed: () {
                cart.addProduct(products[index]);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartScreen(cart: cart),
                  ),
                );
              },
              child: Text('Agregar al carrito'),
            ),
          );
        },
      ),
    );
  }
}