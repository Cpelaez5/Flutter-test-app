import 'package:flutter/material.dart';
import '../../models/cart.dart';
import 'payment_screen.dart';

class CartScreen extends StatefulWidget {
  final Cart cart;

  CartScreen({required this.cart});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double getTotalAmount() {
    double total = 0.0;
    for (var product in widget.cart.products) {
      total += product.price * product.quantity;
    }
    return total;
  }

  void _handlePurchase() {
  final totalAmount = getTotalAmount();
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PaymentScreen(
        totalAmount: totalAmount,
        products: widget.cart.products, // Pasar la lista de productos
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrito'),
      ),
      body: widget.cart.products.isEmpty
          ? Center(child: Text('No hay nada en el carrito'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.cart.products.length,
                    itemBuilder: (context, index) {
                      final product = widget.cart.products[index];
                      final totalProductPrice = product.price * product.quantity;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Image.network(
                              product.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
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
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: \$${getTotalAmount().toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: _handlePurchase,
                        child: Text('Comprar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}