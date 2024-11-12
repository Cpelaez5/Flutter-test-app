import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Asegúrate de importar Firestore
import 'package:timeago/timeago.dart' as timeago;
import '../../models/order_model.dart';
import 'error_dialog.dart';
import 'show_qr.dart';

class PaymentCard extends StatefulWidget {
  final Payment payment;
  final Function onTap;

  const PaymentCard({
    super.key,
    required this.payment,
    required this.onTap,
  });

  @override
  _PaymentCardState createState() => _PaymentCardState();
}

class _PaymentCardState extends State<PaymentCard> {
  String userRole = ''; // Variable para almacenar el rol del usuario

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    // Obtén el uid del usuario actual (esto puede variar según tu implementación)
    String uid = FirebaseAuth.instance.currentUser ?.uid ?? '';

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userRole = (userDoc.data() as Map<String, dynamic>)['role'] ?? '';
        });
      }
    } catch (e) {
      print("Error al obtener el rol del usuario: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
     DateTime? lastActionDateTime;

  // Determinar cuál fecha usar para mostrar el tiempo transcurrido
  if (widget.payment.checkedAt != null && widget.payment.finishedAt == null) {
    lastActionDateTime = widget.payment.checkedAt;
  } else if (widget.payment.finishedAt != null) {
    lastActionDateTime = widget.payment.finishedAt;
  } else {
    lastActionDateTime = widget.payment.timestamp; // Si no hay checkedAt ni finishedAt, usar timestamp
  }

  // Formatear el tiempo transcurrido
  final timeAgo = lastActionDateTime != null ? timeago.format(lastActionDateTime, locale: 'es') : 'Desconocido';
    final paymentStatus = _getPaymentStatus(widget.payment.paymentStatus);
    final paymentDetails = _getPaymentDetails(widget.payment);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      color: paymentStatus.cardColor,
      child: InkWell(
        onTap: () => widget.onTap(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(paymentDetails.icon, color: paymentDetails.textColor, size: 32),
              const SizedBox(width: 16), // Espaciado entre icono y texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paymentDetails.paymentMethodString,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Pedido N°${widget.payment.orderNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    if (widget.payment.referenceNumber != null) // Mostrar solo si no es nulo
                      Text(
                        'Referencia: ${widget.payment.referenceNumber != null && widget.payment.referenceNumber!.length >= 4 ? widget.payment.referenceNumber?.substring(widget.payment.referenceNumber!.length - 4) : widget.payment.referenceNumber ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (widget.payment.paymentAmount.isNotEmpty) // Mostrar solo si no es nulo o vacío
                      Text(
                        widget.payment.paymentMethod == 'divisas' ? 'Monto: \$${widget.payment.paymentAmount}' : 'Monto: Bs. ${widget.payment.paymentAmount}',
                          style: const TextStyle(fontSize: 16)),
                    // Cambiar a Row para mostrar el estado y el icono en la misma línea
                    Row(
                      children: [
                        Text(paymentStatus.paymentStatusString,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        if (widget.payment.paymentStatus == 'checked') 
                          Icon(Icons.check, color: Colors.blueAccent, size: 20),
                        if (widget.payment.paymentStatus == 'pending') 
                          Icon(Icons.access_time, color: Colors.deepOrange, size: 20),
                        if (widget.payment.paymentStatus == 'finished') 
                          Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
                      ],
                    ),
                    Text(timeAgo, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              if (widget.payment.token != null && userRole == 'cliente')
                if (widget.payment.paymentStatus != 'finished')
                IconButton(
                  icon: Icon(Icons.qr_code, size: 30),
                  tooltip: 'Ver QR',
                  onPressed: () {
                    // Aquí llamas a la función que mostrará el QR
                    showQrConfirmationDialog(context, widget.payment.token!, widget.payment.orderNumber);
                  },
                ),
              if (widget.payment.paymentStatus == 'finished')
                IconButton(
                  icon: Icon(Icons.check_circle_outline, size: 30, color: Colors.green),
                  tooltip: 'Finalizado',
                  onPressed: () {
                    ErrorDialog.show(context, 'Finalizado', 'Este pago ya ha sido canjeado', Colors.green);
                  },
                ),
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
        ),
      ),
    );
  }

  PaymentStatus _getPaymentStatus(String paymentStatus) {
    String paymentStatusString;
    Color cardColor;

    switch (paymentStatus) {
      case 'pending':
        paymentStatusString = 'Pendiente';
        cardColor = Color.fromARGB(255, 255, 193, 7); // #FFC107;
        break;

      case 'finished':
        paymentStatusString = 'Finalizado';
        cardColor = Colors.greenAccent;
        break;

      case 'checked':
        paymentStatusString = 'Verificado';
        cardColor = const Color.fromARGB(255, 122, 240, 255); // #00BCD4;
        break;
        
      default:
        paymentStatusString = 'Desconocido';
        cardColor = Colors.grey;
        break;
    }

    return PaymentStatus(
      paymentStatusString: paymentStatusString,
      cardColor: cardColor,
    );
  }

  PaymentDetails _getPaymentDetails(Payment payment) {
    IconData icon;
    Color textColor = const Color.fromARGB(178, 0, 0, 0);
    String paymentMethodString;

    switch (payment.paymentMethod) {
      case 'pago_movil':
        icon = Icons.mobile_friendly;
        paymentMethodString = 'Pago móvil';
        break;
      case 'divisas':
        icon = Icons.attach_money;
        paymentMethodString = 'Divisas';
        break;
      case 'transferencia':
        icon = Icons.swap_horiz_sharp;
        paymentMethodString = 'Transferencia';
        break;
      case 'bolivares':
        icon = Icons.payments_outlined;
        paymentMethodString = 'Bolívares';
        break;
      case 'tarjeta':
        icon = Icons.credit_card;
        paymentMethodString = 'Tarjeta';
        break;
      default:
        icon = Icons.error_outline_rounded;
        textColor = Colors.red; // Color para el texto de error
        paymentMethodString = 'Desconocido';
        break;
    }

    return PaymentDetails(
      icon: icon,
      textColor: textColor,
      paymentMethodString: paymentMethodString,
    );
  }
}

class PaymentDetails {
  final IconData icon;
  final Color textColor;
  final String paymentMethodString;

  PaymentDetails({
    required this.icon,
    required this.textColor, 
    required this.paymentMethodString,
  });
}

class PaymentStatus {
  final String paymentStatusString;
  final Color cardColor;

  PaymentStatus({
    required this.paymentStatusString,
    required this.cardColor,
  }); 
}