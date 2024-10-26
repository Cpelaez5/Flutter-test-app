import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/order_model.dart';

class PaymentCard extends StatelessWidget {
  final Payment payment;
  final Function onTap;

  const PaymentCard({
    Key? key,
    required this.payment,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeAgo = timeago.format(payment.timestamp, locale: 'es');
    final paymentStatus = _getPaymentStatus(payment.paymentStatus);
    final paymentDetails = _getPaymentDetails(payment);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      color: paymentStatus.cardColor,
      child: InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(paymentDetails.icon, color: paymentDetails.textColor),
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
                      'Referencia: ${payment.referenceNumber}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Monto: ${payment.paymentAmount} Bs.',
                        style: const TextStyle(fontSize: 16)),
                    Text(paymentStatus.paymentStatusString,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(timeAgo, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
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
        cardColor = Color.fromARGB(255, 245, 215, 110);
        break;

      case 'finished':
        paymentStatusString = 'Finalizado';
        cardColor = Colors.greenAccent;
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