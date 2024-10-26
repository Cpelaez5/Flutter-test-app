import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../data/payment_data.dart';
import '../../utils/currency_input_formatter.dart';
import '../../utils/text_input_formatter.dart';

class MobilePaymentScreen extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> products;

  const MobilePaymentScreen({
    Key? key,
    required this.totalAmount,
    required this.products,
  }) : super(key: key);

  @override
  _MobilePaymentScreenState createState() => _MobilePaymentScreenState();
}

class _MobilePaymentScreenState extends State<MobilePaymentScreen> {
  String? selectedPhonePrefix;
  String? phoneNumber;
  String? referenceNumber;
  String? selectedBank;
  String? paymentDate;
  String? paymentAmount;
  bool isCaptureUploaded = false;
  final Uuid _uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago Móvil'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildTotalAmount(),
                    const SizedBox(height: 16),
                    _buildTextField('Número de referencia:', (value) {
                      referenceNumber = value;
                    }),
                    const SizedBox(height: 10),
                    _buildPhoneNumberField(),
                    const SizedBox(height: 10),
                    _buildDateField(),
                    const SizedBox(height: 10),
                    _buildTextField('Monto del pago:', (value) {
                      paymentAmount = value;
                    }, hintText: 'Ingrese el monto', inputFormatters: [CurrencyInputFormatter()]),
                    const SizedBox(height: 10),
                    _buildBankDropdown(),
                    const SizedBox(height: 10),
                    _buildFileUploadButton(),
                    if (isCaptureUploaded) _buildUploadConfirmation(),
                    const SizedBox(height: 20),
                    _buildConfirmButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.mobile_friendly,
          size: 48,
          color: Theme.of(context).primaryColor,
        ),
        const Text(
          'Pago móvil',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTotalAmount() {
    return Text(
      'Total a Pagar: \$${widget.totalAmount.toStringAsFixed(2)}',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged, {String? hintText, List<TextInputFormatter>? inputFormatters}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextField(
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
          keyboardType: TextInputType.text,
        ),
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Número de teléfono:'),
        Row(
          children: [
            DropdownButton<String>(
              value: selectedPhonePrefix,
              hint: const Text('código celular'),
              items: phonePrefixes.map((String prefix) {
                return DropdownMenuItem<String>(
                  value: prefix,
                  child: Text(prefix),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPhonePrefix = value;
                });
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  phoneNumber = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Número',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fecha del pago'),
        TextField(
          onChanged: (value) {
            setState(() {
              paymentDate = value;
            });
          },
          inputFormatters: [DateInputFormatter()],
          decoration: const InputDecoration(
            hintText: 'DD-MM-AA',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildBankDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Banco emisor:'),
        DropdownButton<String>(
          isExpanded: true,
          value: selectedBank,
          hint: const Text('Seleccione banco'),
          items: banks.map((String bank) {
            return DropdownMenuItem<String>(
              value: bank,
              child: Text(bank),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedBank = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildFileUploadButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Subir captura de pantalla del pago (opcional):'),
        ElevatedButton(
          onPressed: () {
            // Aquí puedes implementar la lógica para subir una imagen
            // Por ejemplo, abrir un selector de archivos o la galería
            setState(() {
              isCaptureUploaded = true; // Simulamos que se subió una captura
            });
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text('Seleccionar archivo'),
        ),
      ],
    );
  }

  Widget _buildUploadConfirmation() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: const Text('Captura de pantalla subida.'),
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: _confirmPayment,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text('Confirmar Pago Móvil'),
    );
  }

  void _confirmPayment() async {
    if (referenceNumber != null && (isCaptureUploaded || phoneNumber != null)) {
      // Crear un mapa con los datos del pago
      Map<String, dynamic> paymentData = {
        'referenceNumber': referenceNumber,
        'phoneNumber': '$selectedPhonePrefix-$phoneNumber',
        'paymentDate': paymentDate, // Asegúrate de que esta variable esté definida
        'selectedBank': selectedBank,
        'paymentAmount': paymentAmount,
        'paymentStatus': 'pending',
        'paymentMethod': 'pago_movil',
        'isCaptureUploaded': isCaptureUploaded,
        'timestamp': FieldValue.serverTimestamp(), // Para registrar la fecha y hora
        'uid': FirebaseAuth.instance.currentUser!.uid, // Almacenar el uid del usuario
        'token': _uuid.v4(), // Generar un token único para el pedido
      };

      // Solo agregar la lista de productos si no está vacía
      if (widget.products.isNotEmpty) {
        // Transformar la lista de productos para que contenga solo el ID y la cantidad
        List<Map<String, dynamic>> productList = widget.products.map((product) {
          return {
            'productId': product['id'], // Asegúrate de que 'id' sea la clave correcta
            'quantity': product['quantity'], // Asegúrate de que 'quantity' sea la clave correcta
            'price': product['price'],
          };
        }).toList();

        paymentData['products'] = productList; // Agregar la lista de productos al mapa
      }

      // Guardar en Firestore
      try {
        await FirebaseFirestore.instance.collection('payments').add (paymentData);
        Navigator.pop(context); // Regresar a la pantalla anterior
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pago Móvil registrado con éxito!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el pago: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos requeridos.')),
      );
    }
  }
}