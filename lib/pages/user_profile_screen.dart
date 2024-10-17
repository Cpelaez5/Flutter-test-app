import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

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
  Map<String, String> _originalData = {};

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
        _idController.text = data['Cédula'] ?? '';
        _phoneController.text = data['Teléfono'] ?? '';
        _emailController.text = data['email'] ?? '';
        _originalData = {
          'name': _nameController.text,
          'Cédula': _idController.text,
          'Teléfono': _phoneController.text,
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
        _idController.text == _originalData['Cédula'] &&
        _phoneController.text == _originalData['Teléfono'] &&
        _emailController.text == _originalData['email']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hay cambios para actualizar')),
      );
      return;
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
        'Cédula': _idController.text,
        'Teléfono': _phoneController.text,
        'email': _emailController.text,
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
        SnackBar(content: Text('Error al guardar datos: $error ')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                  onPressed: () => Navigator.of(context).pop(), // Cerrar el diálogo sin devolver nada
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    if (password?.isEmpty ?? true) {
                      setState(() {
                        showError = true;
                      });
                    } else {
                      Navigator.of(context).pop(password); // Devolver la contraseña
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
    // Realiza el cierre de sesión
    await FirebaseAuth.instance.signOut();

    // Navega a la pantalla de inicio de sesión
    Navigator.of(context).pushReplacementNamed('/login');
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
                    _buildTextField(_idController, 'Cédula', TextInputType.number, [FilteringTextInputFormatter.digitsOnly]),
                    _buildTextField(_phoneController, 'Teléfono', TextInputType.phone),
                    _buildTextField(_emailController, 'Correo electrónico', TextInputType.emailAddress),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_isLoading)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _saveUser,
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

  Widget _buildTextField(TextEditingController controller, String label, TextInputType keyboardType, [List<TextInputFormatter>? inputFormatters]) {
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
      ),
    );
  }
}