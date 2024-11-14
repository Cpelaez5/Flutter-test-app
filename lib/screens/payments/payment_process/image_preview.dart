import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/payments/upload_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../my_home_page.dart';

class ImagePreviewScreen extends StatefulWidget {
  final String documentId; // ID del documento en Firestore
  final Function(String?) onImageSelected;

  const ImagePreviewScreen({
    super.key,
    required this.documentId,
    required this.onImageSelected,
  });

  @override
  _ImagePreviewScreenState createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  bool isLoading = false;
  String? imageUrl; // Variable para almacenar la URL de la imagen

  @override
  void initState() {
    super.initState();
    loadImageUrl(); // Cargar la imagen desde Firestore al iniciar
  }

  Future<void> loadImageUrl() async {
    setState(() {
      isLoading = true; // Cambiar el estado de carga al iniciar la carga de la imagen
    });

    try {
      // Obtener la URL de la imagen desde Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('payments').doc(widget.documentId).get();
      if (doc.exists) {
        if (mounted) {
          setState(() {
            imageUrl = doc['imageUrl']; // Asignar la URL de la imagen
          });
        }
      }
    } catch (e) {
      print('Error al cargar la imagen: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // Cambiar el estado de carga después de cargar la imagen
        });
      }
    }
  }

  Future<void> changeImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        isLoading = true; // Cambiar el estado de carga mientras se sube la imagen
      });

      try {
        // Eliminar la imagen anterior del almacenamiento si existe
        if (imageUrl != null) {
          final previousImageRef = FirebaseStorage.instance.refFromURL(imageUrl!);
          await previousImageRef.delete(); // Eliminar la imagen anterior
          print('Imagen anterior eliminada: $imageUrl');
        }

        // Llamar a la función para subir la nueva imagen y obtener la URL
        String downloadUrl = await uploadImage(image, 'payments');
        print('Download URL: $downloadUrl'); // Imprimir la URL de descarga

        // Actualizar la URL en Firestore
        await FirebaseFirestore.instance.collection('payments').doc(widget.documentId).update({
          'imageUrl': downloadUrl,
        });

        // Actualizar la vista previa de la imagen
        if (mounted) {
          setState(() {
            imageUrl = downloadUrl; // Actualizar la URL de la imagen en el estado
          });
          widget.onImageSelected(downloadUrl); // Pasar la nueva URL de la imagen a la pantalla anterior
          // Puedes mantener el SnackBar de éxito si lo deseas
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Comprobante modificado con éxito!')),
          );
        }
      } catch (e) {
        // Registrar el error en la consola
        print('Error al subir la imagen: $e');
        // No mostrar el SnackBar de error
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false; // Cambiar el estado de carga después de subir la imagen
          });
        }
      }
    } else {
      if (mounted) {
        // No mostrar el SnackBar de error si no se seleccionó ninguna imagen
        print('No se seleccionó ninguna imagen.');
      }
    }
  }

  @override
  void dispose() {
    // Aquí puedes realizar cualquier limpieza necesaria
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
        // Obtener el ancho de la pantalla
    double screenWidth = MediaQuery.of(context).size.width;

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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time, size: 100, color: Colors.deepOrange),
                  const SizedBox(height: 16),
                  const Text(
                    'Recibimos los datos del pago y lo estamos verificando',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Este proceso puede demorar hasta 30 min',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (imageUrl != null)
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(26), // Redondear bordes
                          child: SizedBox(
                            width: screenWidth * 0.9, // Ancho de la imagen
                            height: 200, // Limitar la altura de la imagen
                            child: Image.network(
                              imageUrl!,
                              fit: BoxFit.cover, // Ajustar la imagen
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            const SizedBox(height: 16), // Espacio adicional para bajar el botón
                            SizedBox(
                              width: screenWidth * 0.9, // Ancho del botón
                              child: ElevatedButton.icon(
                                onPressed: changeImage, // Cambiar la imagen
                                icon: const Icon(Icons.edit),
                                label: const Text('Modificar comprobante'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black87,
                                  backgroundColor: Colors.grey[100], // Color del botón
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(26), // Redondear bordes
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    const Text('No hay imagen seleccionada.'),
                  const SizedBox(height: 32),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Navegar a MyHomePage y borrar el historial
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => MyHomePage()),
              (Route<dynamic> route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87, 
            foregroundColor: Colors.grey[100], // Color del botón
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            textStyle: const TextStyle(fontSize: 18, color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26), // Redondear bordes
            ),
          ),
          child: const Text('Ir al inicio'),
        ),
      ),
    );
  }
}