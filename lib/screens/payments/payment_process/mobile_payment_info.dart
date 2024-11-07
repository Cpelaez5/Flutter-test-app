import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Importar la biblioteca intl
import '../../../widgets/custom_dialog.dart';
import 'phone_verification.dart';

class MobilePaymentInfoScreen extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> products;  

  const MobilePaymentInfoScreen({
    super.key,
    required this.totalAmount,
    required this.products,
  });

  @override
  _MobilePaymentInfoScreenState createState() => _MobilePaymentInfoScreenState();
}

class _MobilePaymentInfoScreenState extends State<MobilePaymentInfoScreen> {
  String? bank;
  String? phone;
  String? rif;

  @override
  void initState() {
    super.initState();
    _fetchPaymentData();
  }

  Future<void> _fetchPaymentData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('paymentData')
          .doc('mobilePayment') // Asegúrate de que este sea el ID correcto del documento
          .get();

      if (snapshot.exists) {
        setState(() {
          bank = snapshot['bank'];
          phone = snapshot['phone'];
          rif = snapshot['rif'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los datos: $e')),
      );
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copiado al portapapeles')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación de pago'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              String title = 'No olvides registrar tu pago';
              String message;

              if (widget.products.isNotEmpty) {
                message = 'Si te retrasas en el pago de ${widget.products.length > 1 ? "los artículos" : "una orden"}, podrías perder la reserva del artículo.';
              } else {
                message = 'Si hiciste un pago, no olvides registrarlo.';
              }

              // Usa el CustomSnackbar para mostrar el Snackbar
              CustomDialog.show(context, title, message);
            }, // Muestra el Snackbar al presionar el icono
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Transfiere a esta cuenta',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildInfoBox(),
              const SizedBox(height: 32),
              _buildDataCard(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  String userId = FirebaseAuth.instance.currentUser ?.uid ?? '';
                  // Navegar a la siguiente pantalla y pasar los datos
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhoneVerificationScreen(
                        userId: userId,
                        products: widget.products,
                        totalAmount: widget.totalAmount,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Utilicé estos datos'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.totalAmount != 0) // Mostrar monto solo si no es 0
              _buildDataRow('Monto', NumberFormat.currency(locale: 'es', symbol: 'Bs').format(widget.totalAmount)),
            const SizedBox(height: 24), // Aumentar el espacio entre filas
            _buildDataRow('Número de Teléfono', phone),
            const SizedBox(height: 24), // Aumentar el espacio entre filas
            _buildDataRow('RIF', rif),
            const SizedBox(height: 24), // Aumentar el espacio entre filas
            _buildDataRow('Banco', bank),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String title, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value ?? 'Cargando...', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () => _copyToClipboard(value ?? ''),
        ),
      ],
    );
  }

  Widget _buildInfoBox() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.info, color: Colors.blue),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Copia los datos y asegúrate de pagar correctamente.",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}