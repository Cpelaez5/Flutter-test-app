import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/product.dart';
import '../../../models/order_model.dart';
import '../../../widgets/show_qr.dart';
import '../../my_home_page.dart';

class SuccessPaymentDetailScreen extends StatefulWidget {
  final Payment payment;
  final double? dolarPrice;

  SuccessPaymentDetailScreen({
    required this.dolarPrice, 
    required this.payment});
  
  @override
  _SuccessPaymentDetailScreenState createState() => _SuccessPaymentDetailScreenState();
}

class _SuccessPaymentDetailScreenState extends State<SuccessPaymentDetailScreen> {
  List<Product> allProducts = []; // Lista para almacenar todos los productos
  bool isLoading = true; // Variable para manejar el estado de carga
  String? imageUrl; // Variable para almacenar la URL de la imagen
  String? token; // Declarar la variable token
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  
  @override
  void initState() {
    super.initState();
    _loadProducts().then((_) {
      setState(() {
        isLoading = false;
      });
    }); 
    _fetchToken(); // Llamar a la función para obtener el token
  }

  Future<void> _fetchToken() async {
    try {
      DocumentSnapshot paymentDoc = await FirebaseFirestore.instance
          .collection('payments')
          .doc(widget.payment.id)
          .get();

      if (paymentDoc.exists) {
        setState(() {
          // Asegúrate de hacer un cast adecuado
          token = (paymentDoc.data() as Map<String, dynamic>)['token']; // Asegúrate de que 'token' existe en tu documento
        });
      }
    } catch (e) {
      print("Error al obtener el token: $e");
    }
  }

  Future<void> _loadProducts() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    allProducts = snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList();
    
    // Imprimir los IDs de los productos cargados
    print("Productos cargados:");
    for (var product in allProducts) {
      print("ID: ${product.id}, Nombre: ${product.name}");
    }

    setState(() {}); // Actualiza el estado para reflejar los productos cargados
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        // Redirigir a MyHomePage al presionar el botón de retroceso
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MyHomePage()),
          (Route<dynamic> route) => false,
        );
        return false; // Evitar que se cierre la pantalla actual
      },
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
        appBar: AppBar(
          title: const Text('Pedido registrado'),
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
                    const Text(
                      'Pedido registrado exitosamente.',
                      style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 54, 54, 54), fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Recuerda que al momento de ir a la cantina y cancelar, debes proporcionar el QR para poder retirar el pedido.',
                      style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 116, 116, 116)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: Size(double.infinity, 50), // Ancho completo
                      ),
                      child: const Text(
                        'Ir al inicio',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    )
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
            Text( 'Monto: ${payment.paymentMethod == 'divisas' ? '\$${(double.parse(payment.paymentAmount) / (widget.dolarPrice ?? 1)).toStringAsFixed(2)}' : 'Bs. ${payment.paymentAmount}'}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              payment.paymentStatus == 'pendiente' ? 'Estado: ${payment.paymentStatus}' : 'Estado: Pendiente por pagar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Registrado: ${paymentDateTime.day}/${paymentDateTime.month}/${paymentDateTime.year} ${paymentDateTime.hour}:${paymentDateTime.minute}'),
            const SizedBox(height: 16), // Espacio entre la información y los botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // Alinear los botones a la derecha
              children: [
                if (token != null) // Mostrar el botón QR solo si el token no es nulo
                  IconButton(
                    tooltip: 'Mostrar QR',
                    icon: Icon(Icons.qr_code, size: 30),
                    onPressed: () {
                      showQrConfirmationDialog(context, token!);
                    },
                  ),
              ],
            ),
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
                     Text( 'Precio unitario: ${widget.payment.paymentMethod == 'divisas' ? '\$${((product.price) / (widget.dolarPrice ?? 1)).toStringAsFixed(2)}' : 'Bs. ${product.price}'}',
                      ),
                      if (productQuantity > 1)
                    Text('Subtotal: ${widget.payment.paymentMethod == 'divisas' ? '\$${(subtotal / (widget.dolarPrice ?? 1)).toStringAsFixed(2)}' : 'Bs. $subtotal'}'),
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
            title: Text('Total: ${widget.payment.paymentMethod == 'divisas' ? '\$${(total / (widget.dolarPrice ?? 1)).toStringAsFixed(2)}' : 'Bs. $total'}'),
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