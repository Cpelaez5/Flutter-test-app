import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

Future<String> uploadImage(XFile image, String folderName) async {
  try {
    // Obtén la referencia al almacenamiento de Firebase
    final storageRef = FirebaseStorage.instance.ref();
    
    // Crea una referencia para la imagen
    final imageRef = storageRef.child('$folderName/${basename(image.path)}');

    // Sube la imagen
    await imageRef.putFile(File(image.path));

    // Obtén la URL de descarga
    String downloadUrl = await imageRef.getDownloadURL();
    print('URL de descarga de la imagen: $downloadUrl');
    return downloadUrl;
  } catch (e) {
    throw Exception('Error al subir la imagen: $e');
  }
}