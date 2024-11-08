import 'dart:math'; // Importa la librería para generar números aleatorios
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Asegúrate de importar Firebase Auth
import '../../../models/product.dart';
import '../../../services/notification_service.dart';
import '../../../services/payments/update_payment_status.dart'; // Asegúrate de importar la función

class LocalPaymentVerificationScreen extends StatefulWidget {
  final double totalAmount;
  final List<Product> products;
  final String? paymentMethod;
  final double? dolarPrice; // Agregar esta variable para el precio del dólar

  LocalPaymentVerificationScreen({
    required this.totalAmount,
    required this.products,
    required this.paymentMethod,
    this.dolarPrice, // Asegúrate de que se pase el precio del dólar
  });

  @override
  _LocalPaymentVerificationScreenState createState() => _LocalPaymentVerificationScreenState();
}

class _LocalPaymentVerificationScreenState extends State<LocalPaymentVerificationScreen> {
  bool isLoading = false; // Estado para manejar la carga

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmación de Pago'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView( // Permite el desplazamiento si el contenido es largo
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTotalAmountCard(),
                    SizedBox(height: 20),
                    _buildProductsList(),
                    SizedBox(height: 20),
                    _buildPaymentMethodCard(),
                    SizedBox(height: 20),
                    _buildInstructionMessage(), // Mensaje instructivo
                  ],
                ),
              ),
            ),
            _buildConfirmButton(context), // Botón para confirmar el pedido
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAmountCard() {
    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total a Pagar',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange),
              ),
              SizedBox(height: 10),
              Text(
                widget.paymentMethod == 'divisas'
                    ? '\$${(widget.totalAmount / (widget.dolarPrice ?? 1)).toStringAsFixed(2)}' // Muestra en dólares
                    : 'Bs.${widget.totalAmount.toStringAsFixed(2)}', // Muestra en bolívares
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    if (widget.products.isEmpty) {
      return Center(
        child: Text(
          'No hay productos en este pago.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true, // Permite que la lista ocupe solo el espacio necesario
      physics: NeverScrollableScrollPhysics(), // Desactiva el desplazamiento de la lista
      itemCount: widget.products.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          child: ListTile(
            leading: CachedNetworkImage(
              imageUrl: widget.products[index].imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            title: Text(widget.products[index].name, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Precio: ${widget.paymentMethod == 'divisas' ? '\$' : 'Bs.'}${widget.products[index].price.toStringAsFixed(2)}'),
            trailing: Text('Cantidad: ${widget.products[index].quantity}', style: TextStyle(color: Colors.grey)),
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodCard() {
    String? paymentSelected;
    IconData paymentIcon;

    switch (widget.paymentMethod) {
      case 'bolivares':
        paymentSelected = 'Bolívares en efectivo';
        paymentIcon = Icons.payments;
        break;
        
      case 'divisas':
        paymentSelected = 'Divisas en efectivo';
        paymentIcon = Icons.attach_money;
        break;

      case 'tarjeta':
        paymentSelected = 'Punto de venta';
        paymentIcon = Icons.credit_card;
        break;

      default:
        paymentSelected = 'No especificado';
        paymentIcon = Icons.payment;
        break;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Método de Pago',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(paymentIcon, size: 30, color: Colors.blueGrey),
                SizedBox(width: 10),
                Text(
                  paymentSelected,
                  style: TextStyle(fontSize: 18, color: Colors.blueGrey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton(
        onPressed: () async {
          setState(() {
            isLoading = true; // Iniciar carga
          });

          // Crear el objeto de pago
          Map<String, dynamic> paymentData = {
            'paymentAmount': widget.totalAmount,
            'products': widget.products.map((product) {
              return {
                'productId': product.id,
                'quantity': product.quantity,
                'price': widget.paymentMethod == 'divisas' ? product.price : product.price * (widget.dolarPrice ?? 1),
              };
            }).toList(),
            'paymentMethod': widget.paymentMethod,
            'uid': FirebaseAuth.instance.currentUser!.uid, // Agregar ID del usuario
            'timestamp': FieldValue.serverTimestamp(),
            'referenceNumber': null, // Puedes asignar un valor si es necesario
            'phoneNumber': null, // Puedes asignar un valor si es necesario
            'selectedBank': null, // Asignar null si no se usa
            'paymentDate': null, // Asignar null si no se usa
            'token': null, // Asignar null si no se usa
          };

          try {
            // Guardar en Firestore
            DocumentReference docRef = await FirebaseFirestore.instance.collection('payments').add(paymentData);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Pedido registrado con éxito!')),
            );

            // Llamar a la función para actualizar el estado del pago y agregar el token
            await updatePaymentStatus(docRef.id, 'pending'); // Cambia 'Registrado' al estado que desees

          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al registrar el pedido: $e')),
            );
          } finally {
              if (widget.paymentMethod != 'divisas') {
                await NotificationService.sendNotification(
                'Nuevo Pedido Registrado',
                'Un pedido local por Bs.${widget.totalAmount} ha sido registrado',
                'administrador',
                null,
              );
            } else {
               await NotificationService.sendNotification(
                'Nuevo Pedido Registrado',
                'Un pedido local por \$${widget.totalAmount*(widget.dolarPrice ?? 1)} ha sido registrado',
                'administrador',
                null,
              );
            }
            // Enviar notificación a los administradores
            
            setState(() {
              isLoading = false; // Finalizar carga
            });
            
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          backgroundColor: Colors.grey[700], // Color de fondo según el esquema
          textStyle: TextStyle(fontSize: 20, color: Colors.white), // Texto en blanco
        ),
        child: Text('Confirmar Pedido', style: TextStyle(color: Colors.white)), // Texto del botón
      ),
    );
  }

  Widget _buildInstructionMessage() {
    return Text(
      'Recuerda que el pago se canjeará con el código QR en la tienda física al momento de la compra.',
      style: TextStyle(fontSize: 16, color: Colors.grey),
    );
  }
}