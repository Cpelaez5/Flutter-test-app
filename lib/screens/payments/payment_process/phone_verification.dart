import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/phone_validation.dart';
import '../../../widgets/custom_dialog.dart';
import '../../../widgets/error_dialog.dart';
import 'reference_number.dart';// Importar la función de validación

class PhoneVerificationScreen extends StatefulWidget {
  final String userId; // ID del usuario
  final double totalAmount;
  final List<Map<String, dynamic>> products;
  final String? action;

  const PhoneVerificationScreen({
    super.key,
    required this.userId,
    required this.totalAmount,
    required this.products, 
    this.action,
  });

  @override
  _PhoneVerificationScreenState createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  String? phone;
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (snapshot.exists) {
        setState(() {
          phone = snapshot['phone'];
          _phoneController.text = phone ?? ''; // Pre-cargar el número en el controlador
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los datos: $e')),
      );
    }
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

              CustomDialog.show(context, title, message);
            },
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
                'Confirma el número de teléfono',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                phone ?? 'Cargando...',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Ingrese un nuevo número de teléfono'),
                        content: TextField(
                          controller: _phoneController,
                          decoration: const InputDecoration(hintText: "Número de teléfono"),
                          keyboardType: TextInputType.phone,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              String newPhone = _phoneController.text;
                              if (validatePhoneNumber(newPhone)) {
                                setState(() {
                                  phone = newPhone;
                                });
                                Navigator.of(context).pop();
                              } else {
                                ErrorDialog.show(context, 'Número inválido', 'Por favor, ingrese un número de teléfono válido.', null);
                              }
                            },
                            child: const Text('Aceptar'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Usé otro número'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (widget.action == 'edit') {
                    String newPhone = _phoneController.text;
                    if (validatePhoneNumber(newPhone)) {
                      setState(() {
                        phone = newPhone;
                      });
                      return Navigator.of(context).pop(phone);
                    } else {
                      ErrorDialog.show(context, 'Número inválido', 'Por favor, ingrese un número de teléfono válido.', null);
                      return;
                    }
                  }
                  // Navegar a la pantalla de ingreso del número de referencia
                  if (validatePhoneNumber(phone ?? '')) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReferenceNumberScreen(
                          confirmedPhone: phone ?? '', // El número de teléfono confirmado
                          totalAmount: widget.totalAmount, // Total amount
                          products: widget.products, // Lista de productos
                        ),
                      ),
                    );
                  } else {
                    ErrorDialog.show(context, 'Número inválido', 'Por favor, ingrese un número de teléfono válido.', null);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: Text(
                  widget.action == 'edit' ? 'Actualizar número' : 'Confirmar número',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}