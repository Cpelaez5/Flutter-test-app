import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Asegúrate de tener este paquete en tu pubspec.yaml
import '../../models/cart.dart';
import '../payments/payment_screen.dart';

class CartScreen extends StatefulWidget {
  final Cart cart;

  CartScreen({required this.cart});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double? _totalAmount;

  @override
  void initState() {
    super.initState();
    _calculateTotalAmount();
  }

  void _calculateTotalAmount() {
    double total = 0.0;
    for (var product in widget.cart.products) {
      total += product.price * product.quantity;
    }
    setState(() {
      _totalAmount = total;
    });
  }

  void _handlePurchase() {
    if (_totalAmount != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            totalAmount: _totalAmount!,
            products: widget.cart.products,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Carrito'),
      ),
      body: widget.cart.products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.brown,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Tu carrito está vacío',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.cart.products.length,
                      itemBuilder: (context, index) {
                        final product = widget.cart.products[index];
                        final totalProductPrice = product.price * product.quantity;

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product.imageUrl,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('\$${product.price} x ${product.quantity}', style: TextStyle(color: Colors.grey[600])),
                                      const SizedBox(height: 4),
                                      Text('Total: \$${totalProductPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.grey), // Color neutro
                                  onPressed: () {
                                    setState(() {
                                      widget.cart.removeProduct(product);
                                      _calculateTotalAmount(); // Recalcular el total después de eliminar un producto
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut).slide(duration: 500.ms, curve: Curves.easeInOut); // Animación solo en la tarjeta
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: \$${_totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: _handlePurchase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[600],
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Comprar', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}