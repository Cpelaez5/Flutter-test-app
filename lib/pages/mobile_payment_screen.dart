import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/text_input_formatter.dart';

class MobilePaymentScreen extends StatefulWidget {
  @override
  _MobilePaymentScreenState createState() => _MobilePaymentScreenState();
}

class _MobilePaymentScreenState extends State<MobilePaymentScreen> {
  String? selectedPhonePrefix;
  String? phoneNumber;
  String? referenceNumber;
  String? selectedBank;
  String? userEnteredDate;
  bool isCaptureUploaded = false;

  final List<String> phonePrefixes = ['0416', '0426', '0414', '0424', '0412'];
  final List<String> banks = [
    '100% Banco, Banco Universal C.A.',
    'Bancamiga Banco Microfinanciero C.A.',
    'Bancaribe C.A. Banco Universal',
    'Banco Activo, C.A. Banco Universal',
    'Banco Agrícola de Venezuela, C.A. Banco Universal',
    'Banco Bicentenario Banco Universal C.A.',
    'Banco Caroní C.A. Banco Universal',
    'Banco Central de Venezuela',
    'Banco Industrial de Venezuela, C.A. Banco Universal',
    'Banco del Pueblo Soberano, C.A. Banco de Desarrollo',
    'Banco del Tesoro, C.A. Banco Universal',
    'Banco de la Fuerza Armada Nacional Bolivariana, B.U.',
    'Banco de la Gente Emprendedora C.A.',
    'Banco de Venezuela S.A.C.A. Banco Universal',
    'Banco Exterior C.A. Banco Universal',
    'Banco Espirito Santo, S.A. Sucursal Venezuela B.U.',
    'Banco Internacional de Desarrollo, C.A. Banco Universal',
    'Banco Mercantil, C.A S.A.C.A. Banco Universal',
    'Banco Nacional de Crédito, C.A. Banco Universal',
    'Banco Occidental de Descuento, Banco Universal C.A.',
    'Banco Plaza Banco Universal',
    'Banco Provincial, S.A. Banco Universal',
    'Banco Sofitasa Banco Universal',
    'Bancrecer, S.A. Banco Microfinanciero',
    'Banesco Banco Universal S.A.C.A.',
    'Banplus Banco Universal, C.A.',
    'BFC Banco Fondo Común C.A Banco Universal',
    'Citibank N.A.',
    'DelSur Banco Universal, C.A.',
    'Instituto Municipal de Crédito Popular',
    'Mi Banco Banco Microfinanciero C.A.',
    'Venezolano de Crédito, S.A. Banco Universal',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pago Móvil'),
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
                    Icon(
                      Icons.payment,
                      size: 48,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Realiza tu pago móvil',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    _buildTextField('Número de referencia:', (value) {
                      referenceNumber = value;
                    }),
                    SizedBox(height: 10),
                    _buildPhoneNumberField(),
                    SizedBox(height: 10),
                    _buildDateField(), // Usamos el método modificado aquí
                    SizedBox(height: 10),
                    _buildBankDropdown(),
                    SizedBox(height: 10),
                    _buildFileUploadButton(),
                    if (isCaptureUploaded)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text('Captura de pantalla subida.'),
                      ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _confirmPayment,
                      child: Text('Confirmar Pago Móvil'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fecha del pago'),
        TextField(
          onChanged: (value) {
           setState(() {
             userEnteredDate = value;
           });
          },
          inputFormatters: [DateInputFormatter()], // Usamos el TextInputFormatter aquí
          decoration: InputDecoration(
            hintText: 'DD-MM-AA',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged, {String? hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Número de teléfono:'),
        Row(
          children: [
            DropdownButton<String>(
              value: selectedPhonePrefix,
              hint: Text('código celular'),
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
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  phoneNumber = value;
                },
                decoration: InputDecoration(
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

  Widget _buildBankDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Banco emisor:'),
        DropdownButton<String>(
          isExpanded: true,
          value: selectedBank,
          hint: Text('Seleccione banco'),
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
        Text('Subir captura de pantalla del pago (opcional):'),
        ElevatedButton(
          onPressed: () {
            // Aquí puedes implementar la lógica para subir una imagen
            // Por ejemplo, abrir un selector de archivos o la galería
            setState(() {
              isCaptureUploaded = true; // Simulamos que se subió una captura
            });
          },
          child: Text('Seleccionar archivo'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }

    void _confirmPayment() async {
  if (referenceNumber != null && (isCaptureUploaded || phoneNumber != null)) {
    // Asegúrate de que el número de teléfono incluya el prefijo seleccionado
    String fullPhoneNumber = '$selectedPhonePrefix-$phoneNumber'; // Concatenar el prefijo con el número de teléfono

    // Crear un mapa con los datos que deseas subir
    Map<String, dynamic> paymentData = {
      'referenceNumber': referenceNumber,
      'phoneNumber': fullPhoneNumber, // Usar el número de teléfono completo
      'selectedBank': selectedBank,
      'isCaptureUploaded': isCaptureUploaded,
      'user': FirebaseAuth.instance.currentUser!.uid,
      'date': userEnteredDate,
      'timestamp': FieldValue.serverTimestamp(), // Agregar un timestamp
    };

    try {
      // Subir los datos a Firestore
      await FirebaseFirestore.instance.collection('pagosMoviles').add(paymentData);
      
      // Si la subida es exitosa, mostrar un mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pago Móvil procesado con éxito!')),
      );

      // Regresar a la pantalla anterior
      Navigator.pop(context);
    } catch (e) {
      // Manejo de errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar el pago: $e')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Por favor, completa todos los campos requeridos.')),
    );
  }
}
}

