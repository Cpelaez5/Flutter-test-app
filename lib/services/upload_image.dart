import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

Future<String> uploadImage(XFile image) async {
  // Crea una referencia a Firebase Storage
  final storageRef = FirebaseStorage.instance.ref();
  
  // Crea una referencia para la imagen
  final imageRef = storageRef.child('products/${image.name}');
  
  // Sube la imagen
  await imageRef.putFile(File(image.path));
  
  // Obtén la URL de descarga
  String downloadUrl = await imageRef.getDownloadURL();
  
  return downloadUrl;
}