import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import 'error_dialog.dart';

class PaymentInfoCard extends StatefulWidget {
  final Payment payment;

  PaymentInfoCard({required this.payment});

  @override
  _PaymentInfoCardState createState() => _PaymentInfoCardState();
}

class _PaymentInfoCardState extends State<PaymentInfoCard> {
  String userName = 'Cargando...';
  String userIdCard = 'Cargando...';
  String userRole = 'administrador'; // Cambia esto según tu lógica de usuario

  @override
  void initState() {
    super.initState();
    _fetchUserData(); 
  }

  Future<void> _fetchUserData() async {
    try {
      // Obtén el uid directamente del documento de pago
      String uid = (await FirebaseFirestore.instance
          .collection('payments')
          .doc(widget.payment.id)
          .get())
          .data()!['uid'];

      // Busca el usuario en la colección 'users'
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = (userDoc.data() as Map<String, dynamic>)['name'] ?? 'Nombre no disponible';
          userIdCard = (userDoc.data() as Map<String, dynamic>)['idCard'] ?? 'ID no disponible';
        });
      }
    } catch (e) {
      print("Error al obtener los datos del usuario: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    DateTime paymentDateTime = widget.payment.timestamp;
    DateTime? checkedDateTime = widget.payment.checkedAt;
    String paymentStatusName;
    String paymentMethodName;
    IconData paymentIcon;

    switch (widget.payment.paymentMethod) {
      case 'divisas':
        paymentMethodName = 'Divisas';
        paymentIcon = Icons.attach_money;
        break;
      case 'transferencia':
        paymentMethodName = 'Transferencia';
        paymentIcon = Icons.swap_horiz_sharp;
        break;
      case 'bolivares':
        paymentMethodName = 'Bolivares en efectivo';
        paymentIcon = Icons.payments;
        break;
      case 'tarjeta':
        paymentMethodName = 'Tarjeta';
        paymentIcon = Icons.credit_card;
        break;
      case 'pago_movil':
        paymentMethodName = 'Pago Móvil';
        paymentIcon = Icons.mobile_friendly;
        break;
      default:
        paymentMethodName = 'Desconocido';
        paymentIcon = Icons.error;
        break;
    }

    switch (widget.payment.paymentStatus) {
      case 'pending':
        paymentStatusName = widget.payment.paymentMethod != 'pago_movil' ? 'Pendiente por pagar' : 'Pendiente por verificar';
        break;
      case 'finished':
        paymentStatusName = 'Finalizado';
        break;
      case 'checked':
        paymentStatusName = 'Verificado';
        break;
      default:
        paymentStatusName = 'Desconocido';
        break;
    }

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
              ' Pedido N°${widget.payment.orderNumber}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  paymentMethodName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Icon(paymentIcon, color: Colors.deepOrange, size: 24),
              ],
            ),
            if (widget.payment.paymentAmount.isNotEmpty)
              Text(
                'Monto: ${widget.payment.paymentMethod == 'divisas' ? '\$${widget.payment.paymentAmount}' : 'Bs. ${widget.payment.paymentAmount}'}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
              ),
            if (widget.payment.referenceNumber != null) Text('Referencia: ${widget.payment.referenceNumber}'),
            if (widget.payment.phoneNumber != null) Text('Teléfono: ${widget.payment.phoneNumber}'),
            Text('ID: $userIdCard'), // Muestra el ID del usuario
            Text('Usuario: $userName'), // Muestra el nombre del usuario    
            if (widget.payment.paymentDate != null) Text('Fecha del pago: ${widget.payment.paymentDate}'),
              Text('Estado: $paymentStatusName', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Registrado: ${paymentDateTime.day}/${paymentDateTime.month}/${paymentDateTime.year} ${paymentDateTime.hour}:${paymentDateTime.minute}'),
            if (checkedDateTime != null)
              Text('Verificado: ${checkedDateTime.day}/${checkedDateTime.month}/${checkedDateTime.year} ${checkedDateTime.hour}:${checkedDateTime.minute}'),
             Row(
            mainAxisAlignment: MainAxisAlignment.end, // Alinear los botones a la derecha
            children: [
                if (widget.payment.paymentStatus == 'checked')
                IconButton(
                  icon: Icon(Icons.done, size: 30, color: Colors.blueAccent),
                  tooltip: 'Verificado',
                  onPressed: () {
                    ErrorDialog.show(context, 'Verificado', 'Este pago fue verificado y puede canjearse', Colors.blueAccent);
                  },
                ) 
            ],
          ),
          ],
        ),
      ),
      
    );
  }
}