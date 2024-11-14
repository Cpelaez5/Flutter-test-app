import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/bloc/notifications_bloc.dart';
import '../../services/payments/upload_image.dart'; // Asegúrate de importar tu función de subida de imagen
import '../splash_screen.dart'; // Asegúrate de importar tu NotificationsBloc

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _imageUrl;
  Map<String, String> _originalData = {};
  final NotificationsBloc notificationsBloc = NotificationsBloc(); // Instancia del NotificationsBloc

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser ;
    if (user == null) {
      print('Usuario no autenticado');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          _nameController.text = data['name'] ?? '';
          _idController.text = data['idCard'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _emailController.text = data['email'] ?? '';
          _imageUrl = data['imageUrl'];
          _originalData = {
            'name': _nameController.text,
            'idCard': _idController.text,
            'phone': _phoneController.text,
            'email': _emailController.text,
          };
          print('Datos cargados: $_originalData'); // Verificar que los datos se carguen correctamente
        }
      } else {
        print('No se encontró el documento para el usuario: ${user.uid}');
      }
    } catch (error) {
      print('Error al cargar datos: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveUser () async {
    final user = FirebaseAuth.instance.currentUser ;
    if (user == null) {
      print('Usuario no autenticado');
      return;
    }

    if (_nameController.text == _originalData['name'] &&
        _idController.text == _originalData['idCard'] &&
        _phoneController.text == _originalData['phone'] &&
        _emailController.text == _originalData['email']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hay cambios para actualizar')),
      );
      return;
    }

    if (_nameController.text != _originalData['name']) {
      bool confirmChange = await _showConfirmationDialog();
      if (!confirmChange) return;
    }

    final password = await _showPasswordDialog();
    if (password == null) {
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debe ingresar su contraseña para confirmar')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(credential);
      print('Reautenticación exitosa');

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'imageUrl': _imageUrl, // Guarda la URL de la imagen si se subió
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datos guardados exitosamente')),
      );
    } on FirebaseAuthException catch (error) {
      if (error.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Contraseña incorrecta')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar datos: ${error.message}')),
        );
      }
    } catch (error) {
      print('Error al guardar datos: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar datos: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      try {
        final user = FirebaseAuth.instance.currentUser ;
        if (user != null) {
          // Consulta Firestore para obtener la URL de la imagen actual
          DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          final data = userDoc.data() as Map<String, dynamic>?; // Casting a Map<String, dynamic>
          String? existingImageUrl = data?['imageUrl']; // Acceso seguro

          // Si existe una imagen, elimínala de Firebase Storage
          if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
            await deleteImageFromStorage(existingImageUrl); // existingImageUrl es de tipo String
          }

          // Sube la nueva imagen y obtiene la URL de descarga
          String downloadUrl = await uploadImage(XFile(pickedFile.path), 'profile_images');

          // Actualiza la URL de la imagen en Firestore
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'imageUrl': downloadUrl,
          }, SetOptions(merge: true)); // merge: true asegura que se cree si no existe

          setState(() {
            _imageUrl = downloadUrl; // Actualiza el estado de la URL de la imagen
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Imagen subida y guardada exitosamente')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir la imagen: $e')));
      }
    }
  }

// Función para eliminar la imagen de Firebase Storage
Future<void> deleteImageFromStorage(String imageUrl) async {
  try {
    final ref = FirebaseStorage.instance.refFromURL(imageUrl);
    await ref.delete();
    print('Imagen eliminada de Storage: $imageUrl');
  } catch (e) {
    print('Error al eliminar la imagen de Storage: $e');
  }
}

 Future<bool> _showConfirmationDialog() async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Confirmar cambio de nombre'),
        content: Text('¿Estás seguro de que deseas cambiar tu nombre?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Confirmar'),
          ),
        ],
      );
    },
  );

  // Devuelve el resultado o false si el resultado es null
  return result ?? false;
}

  Future<String?> _showPasswordDialog() async {
    String? password;
    bool showError = false;

    return showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Confirmar Contraseña'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      errorText: showError ? 'Debe ingresar su contraseña' : null,
                      errorStyle: TextStyle(color: Colors.red),
                    ),
                    onChanged: (value) {
                      password = value;
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    if (password?.isEmpty ?? true) {
                      setState(() {
                        showError = true;
                      });
                    } else {
                      Navigator.of(context).pop(password);
                    }
                  },
                  child: Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _signOut() async {
    try {
      final user = FirebaseAuth.instance.currentUser ;
      if (user != null) {
        await notificationsBloc.revokeToken();
      }

      await FirebaseAuth.instance.signOut();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SplashScreenWrapper()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error al cerrar sesión: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión')),
      );
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de Usuario'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundImage: _imageUrl != null && _imageUrl!.isNotEmpty 
                      ? NetworkImage(_imageUrl!) 
                      : null,
                  child: (_imageUrl == null || _imageUrl!.isEmpty)
                      ? Icon(Icons.person, size: 70) 
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.camera_alt, color: Colors.deepOrangeAccent),
                    onPressed: _uploadImage,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTextField(_nameController, 'Nombre completo', TextInputType.name),
                    _buildTextField(_idController, 'ID Card', TextInputType.number, [FilteringTextInputFormatter.digitsOnly], false),
                    _buildTextField(_phoneController, 'Teléfono', TextInputType.phone),
                    _buildTextField(_emailController, 'Correo electrónico', TextInputType.emailAddress, null, false),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_isLoading)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _saveUser ,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: Text('Actualizar Datos'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType keyboardType, [List<TextInputFormatter>? inputFormatters, bool editable = true]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        enabled: editable,
      ),
    );
  }
}