import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/product.dart';
import '../../models/order_model.dart';
import '../../services/get_user_role.dart';
import '../../services/update_payment_status.dart';
import 'package:collection/collection.dart'; // Importar la biblioteca collection

class PaymentDetailScreen extends StatefulWidget {
  final Payment payment;

  PaymentDetailScreen({required this.payment});
  
  @override
  _PaymentDetailScreenState createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  String userRole = 'cliente'; // Valor por defecto
  List<Product> allProducts = []; // Lista para almacenar todos los productos
  bool isLoading = true; // Variable para manejar el estado de carga

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
    _loadProducts().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> _fetchUserRole() async {
    User? currentUser  = FirebaseAuth.instance.currentUser ;
    if (currentUser  != null) {
      String role = await getUserRole(currentUser .uid);
      if (mounted) {
        setState(() {
          userRole = role;
        });
      }
    }
  }

  Future<void> _loadProducts() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    allProducts = snapshot.docs.map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    
    // Imprimir los IDs de los productos cargados
    print("Productos cargados:");
    for (var product in allProducts) {
      print("ID: ${product.id}, Nombre: ${product.name}");
    }

    setState(() {}); // Actualiza el estado para reflejar los productos cargados
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar'),
          content: Text('¿Estás seguro de que deseas finalizar el pago?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await updatePaymentStatus(widget.payment.id, 'finished');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Pago marcado como finalizado')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al marcar el pago: $e')),
                    );
                  }
                } finally {
                  Navigator.of(context).pop(); // Cierra el diálogo
                }
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Pago'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  _buildPaymentInfoCard(widget.payment),
                  const SizedBox(height: 16),
                  const Text(
                    'Productos:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildProductsList(widget.payment.products),
                  const SizedBox(height: 16),
                  if (userRole == 'administrador')
                    ElevatedButton(
                      onPressed: _showConfirmationDialog,
                      child: const Text('Marcar como Finalizado'),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildPaymentInfoCard(Payment payment) {
    DateTime paymentDateTime = payment.timestamp;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ' Información del Pago',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Fecha del pago: ${payment.paymentDate }'),
            Text('Referencia: ${payment.referenceNumber}'),
            Text('Monto: ${payment.paymentAmount} Bs.'),
            Text('Estado: ${ payment.paymentStatus}'),
            Text('Banco: ${payment.selectedBank}'),
            Text('Usuario: ${payment.uid}'),
            Text('Registrado: ${paymentDateTime.day}/${paymentDateTime.month}/${paymentDateTime.year} ${paymentDateTime.hour}:${paymentDateTime.minute}'),
            if (payment.paymentMethod == 'pago_movil')
              Text('Teléfono: ${payment.phoneNumber}'),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList(List<dynamic> productDataList) {
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
            final productPrice = productData['price'] ?? 0.0; // Obtener el precio de Firebase

            if (productId == null) {
              return ListTile(
                title: Text('Error: ID de producto no válido'),
              );
            }

            // Imprimir el ID del producto que se está buscando
            print("Buscando producto con ID: $productId");

            // Busca el producto correspondiente en la lista de productos
            final product = allProducts.firstWhereOrNull((p) => p.id == productId);

            if (product == null) {
              print("Producto no encontrado para ID: $productId");
              return ListTile(
                title: Text('Producto no encontrado'),
              );
            }

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
                    Text('Precio unitario: ${(productPrice).toStringAsFixed(2)} Bs.'), // Precio de Firebase
                    Text('Subtotal: ${(subtotal).toStringAsFixed(2)} Bs.'), // Subtotal calculado
                  ],
                ),
              ),
            );
          } else {
            return ListTile(
              title: Text('Error al procesar producto'),
            );
          }
        }).toList(),
        // Mostrar el total
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          child: ListTile(
            title: Text('Total: ${total.toStringAsFixed(2)} Bs.'),
            subtitle: Text('Monto total del pago'),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Cancelar operaciones asincrónicas aquí
    super.dispose();
  }
}