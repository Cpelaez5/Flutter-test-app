import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/product.dart';
import '../../models/order_model.dart';
import '../../services/notification_service.dart';
import '../../services/payments/payment_service.dart';
import '../../widgets/payment_info_card.dart';
import '../../widgets/product_list.dart';
import '../../widgets/confirmation_dialog.dart';

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
  String? imageUrl; // Variable para almacenar la URL de la imagen
  String? token; // Declarar la variable token
  String userName = '';
  String userIdCard = '';
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    userRole = await PaymentService().fetchUserRole();
    allProducts = await PaymentService().loadProducts();
 var paymentData = await PaymentService().fetchPaymentData(widget.payment.id);
    if (paymentData != null) {
      imageUrl = paymentData['imageUrl'];
      token = paymentData['token'];
      userName = paymentData['userName'] ?? 'Nombre no disponible';
      userIdCard = paymentData['idCard'] ?? 'ID no disponible';
    }
    setState(() {
      isLoading = false;
    });
  }

  void _showConfirmationDialog() {
    ConfirmationDialog.show(
      context,
      'Confirmar',
      '¿Estás seguro de que quieres marcar este pago como verificado?',
      () async {
        try {
          await PaymentService().updatePaymentStatus(widget.payment.id, 'checked');
          // Envía la notificación usando el uid obtenido
          await NotificationService.sendNotification(
            'Pago verificado',
            'Su pago de Bs. ${widget.payment.paymentAmount} de referencia ${widget.payment.referenceNumber} ha sido verificado exitosamente.',
            null,
            widget.payment.uid,
          );
          _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text('Pago marcado como finalizado')));
        } catch (e) {
          _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text('Error al marcar el pago: $e')));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalles del Pago'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    PaymentInfoCard(payment: widget.payment),
                    const SizedBox(height: 16),
                    const Text(
                      'Productos:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ProductList(productDataList: widget.payment.products, allProducts: allProducts),
                    const SizedBox(height: 16),
                    if (userRole == 'administrador' && widget.payment.paymentStatus == 'pending' && widget.payment.paymentMethod == 'pago_movil')
                      ElevatedButton(
                        onPressed: _showConfirmationDialog,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black54),
                        child: const Text('Marcar como verificado', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}