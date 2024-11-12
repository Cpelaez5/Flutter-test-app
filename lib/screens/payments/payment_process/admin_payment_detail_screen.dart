import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/product.dart';
import '../../../models/order_model.dart';
import '../../../services/payments/payment_service.dart';
import '../../../widgets/payment_info_card.dart';
import '../../../widgets/product_list.dart';

class AdminPaymentDetailScreen extends StatefulWidget {
  final Payment payment;

  AdminPaymentDetailScreen({required this.payment});

  @override
  _AdminPaymentDetailScreenState createState() => _AdminPaymentDetailScreenState();
}

class _AdminPaymentDetailScreenState extends State<AdminPaymentDetailScreen> {
  bool isLoading = true; // Variable para manejar el estado de carga
  List<Product> allProducts = []; // Lista para almacenar todos los productos

  @override
  void initState() {
    super.initState();
    _initializeData(); // Cargar los datos al iniciar
  }

  Future<void> _initializeData() async {
    allProducts = await PaymentService().loadProducts();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _finalizePayment() async {
    setState(() {
      isLoading = true; // Mostrar indicador de carga
    });

    try {
      await PaymentService().updatePaymentStatus(widget.payment.id, 'finished');

      // Mostrar un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pago marcado como finalizado.')));

      // Regresar a la pantalla anterior
      Navigator.of(context).pop(); // Volver a la pantalla de escaneo
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al finalizar el pago: $e')));
    } finally {
      setState(() {
        isLoading = false; // Ocultar indicador de carga
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Pedido'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  PaymentInfoCard(payment: widget.payment), // Usar el widget de información de pago
                  const SizedBox(height: 16),
                  const Text(
                    'Productos:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ProductList(productDataList: widget.payment.products, allProducts: allProducts), // Usar el widget de lista de productos
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _finalizePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: Size(double.infinity, 50), // Ancho completo
                    ),
                    child: const Text(
                      'Marcar como Finalizado',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}