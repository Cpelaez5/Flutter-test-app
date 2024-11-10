import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/notification_service.dart';
import '../../../services/upload_image.dart';
import '../../my_home_page.dart';
import 'image_preview.dart'; // Asegúrate de importar la nueva pantalla

class PaymentConfirmationScreen extends StatefulWidget {
  final String confirmedPhone;
  final DateTime selectedDate;
  final String selectedBank;
  final double enteredAmount;
  final String referenceNumber;
  final double totalAmount;
  final List<Map<String, dynamic>> products;

  const PaymentConfirmationScreen({
    super.key,
    required this.confirmedPhone,
    required this.selectedDate,
    required this.selectedBank,
    required this.enteredAmount,
    required this.referenceNumber,
    required this.totalAmount,
    required this.products,
  });

  @override
  _PaymentConfirmationScreenState createState() => _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  late String paymentDate;
  bool isLoading = true; // Cambiar a true para mostrar el indicador de carga inicialmente
  bool isPaymentSuccessful = false;
  String? imageUrl;
  String? documentId; // Variable para almacenar el ID del documento

  @override
  void initState() {
    super.initState();
    paymentDate = "${widget.selectedDate.day.toString().padLeft(2, '0')}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.year}";
    _confirmPayment(); // Llamar a la función para confirmar el pago al iniciar
  }

  void _confirmPayment() async {
  if (widget.referenceNumber.isNotEmpty && widget.confirmedPhone.isNotEmpty) {
    Map<String, dynamic> paymentData = {
      'referenceNumber': widget.referenceNumber,
      'phoneNumber': widget.confirmedPhone,
      'paymentDate': paymentDate,
      'selectedBank': widget.selectedBank,
      'paymentAmount': widget.enteredAmount.toStringAsFixed(2),
      'paymentStatus': 'pending',
      'paymentMethod': 'pago_movil',
      'timestamp': FieldValue.serverTimestamp(),
      'uid': FirebaseAuth.instance.currentUser !.uid,
      'token': null,
      'imageUrl': imageUrl,
    };

    if (widget.products.isNotEmpty) {
      List<Map<String, dynamic>> productList = widget.products.map((product) {
        return {
          'productId': product['id'],
          'quantity': product['quantity'],
          'price': product['price'],
        };
      }).toList();

      paymentData['products'] = productList;
    }

    setState(() {
      isLoading = true; // Mostrar el indicador de carga
    });

    try {
      // Agregar el pago a Firestore y obtener el ID del documento
      DocumentReference docRef = await FirebaseFirestore.instance.collection('payments').add(paymentData);
      documentId = docRef.id; // Guardar el ID del documento
      setState(() {
        isPaymentSuccessful = true;
      });

      // Enviar notificación a los administradores
      await NotificationService.sendNotification(
        'Nuevo Pago Registrado',
        'Un nuevo pago móvil por Bs.${widget.totalAmount}0 ha sido registrado',
        'administrador',
        null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pago Móvil registrado con éxito!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el pago: $e')),
      );
    } finally {
      setState(() {
        isLoading = false; // Ocultar el indicador de carga
      });
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por favor, completa todos los campos requeridos.')),
    );
    setState(() {
      isLoading = false; // Ocultar el indicador de carga si hay un error
    });
  }
}

  Future<void> _uploadCapture() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  if (image != null) {
    setState(() {
      isLoading = true; // Cambiar el estado de carga mientras se sube la imagen
    });
    try {
      // Llamar a la función para subir la imagen y obtener la URL
      String downloadUrl = await uploadImage(image, 'payments');
      
      // Actualizar el estado con la URL de la imagen
      setState(() {
        imageUrl = downloadUrl;
      });

      // Actualizar la URL en Firestore
      if (documentId != null) {
        await FirebaseFirestore.instance.collection('payments').doc(documentId).update({
          'imageUrl': downloadUrl,
        });
        print('Firestore updated with imageUrl: $downloadUrl'); // Verifica que la actualización se ejecute
      }

      // Mostrar un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comprobante subido con éxito!')),
      );

      // Navegar a la pantalla de vista previa de la imagen
      print('Document ID que va hacia la pantalla de vista previa: $documentId');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => ImagePreviewScreen(
            documentId: documentId!, // Pasar el ID del documento
            onImageSelected: (newImageUrl) {
              setState(() {
                imageUrl = newImageUrl; // Actualizar la URL de la imagen
              });
            },
          ),
        ), 
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir el comprobante: $e')),
      );
    } finally {
      setState(() {
        isLoading = false; // Cambiar el estado de carga después de subir la imagen
      });
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se seleccionó ninguna imagen.')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación de Pago'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.info, size: 40, color: Colors.deepOrange),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Gracias por registrar el pago',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Recuerda que es necesario que subas el comprobante.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Recibimos los datos del pago y lo estamos verificando',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Este proceso puede demorar hasta 30 minutos',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  if (isPaymentSuccessful) ...[
                    const Text(
                      '¡El pago se ha registrado con éxito!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Center(
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _uploadCapture, // Llama a la función para subir el comprobante
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Subir comprobante'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Navegar a MyHomePage y borrar el historial
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => MyHomePage()),
                              (Route<dynamic> route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                            textStyle: const TextStyle(fontSize: 18, color: Colors.white),
                                                      ),
                          child: const Text('Ir al inicio'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}