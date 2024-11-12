import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../../models/product.dart';

class ProductList extends StatelessWidget {
  final List<dynamic> productDataList;
  final List<Product> allProducts;

  ProductList({required this.productDataList, required this.allProducts});

  @override
  Widget build(BuildContext context) {
    if (productDataList.isEmpty) {
      return const Center(
        child: Text(
          'No hay productos en este pago.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    double total = 0.0; // Inicializa el total

    return Column(
      children: [
        ...productDataList.map((productData) {
          if (productData is Map<String, dynamic>) {
            final productId = productData['productId'];
            final productQuantity = productData['quantity'] ?? 1;

            // Busca el producto correspondiente en la lista de productos
            final product = allProducts.firstWhereOrNull((p) => p.id == productId);

            if (product == null) {
              return ListTile(
                title: Text('Producto no encontrado'),
              );
            }

            double productPrice = product.price; // Obtener el precio del producto
            double subtotal = productPrice * productQuantity; // Calcular subtotal
            total += subtotal; // Sumar al total

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              child: ListTile(
                leading: Image.network(
                  product.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(product.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cantidad: $productQuantity'),
                    Text('Precio unitario: ${productPrice.toStringAsFixed(2)}'),
                    if (productQuantity > 1)
                      Text('Subtotal: ${subtotal.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            );
          } else {
            return ListTile(
              title: Text('Error al procesar producto'),
            );
          }
        }),
        // Mostrar el total
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          child: ListTile(
            title: Text('Total: ${total.toStringAsFixed(2)}'),
            subtitle: Text('Monto total del pago'),
          ),
        ),
      ],
    );
  }
}