import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/id_card_validation.dart';
import '../../../utils/phone_validation.dart';
import '../../users/user_order_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final String userId;

  UserDetailScreen({required this.userId});

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  String? _status; 
  String? _role; 
  String? _imageUrl; 
  bool _isLoading = false;
  bool _isEditingName = false;
  bool _isEditingId = false;
  bool _isEditingEmail = false;
  bool _isEditingPhone = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _setLoadingState(true);
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      if (doc.exists) {
        _populateUserData(doc.data());
      } else {
        print('No se encontró el documento para el usuario: ${widget.userId}');
      }
    } catch (error) {
      _showSnackBar('Error al cargar datos: $error');
    } finally {
      _setLoadingState(false);
    }
  }

  void _setLoadingState(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  void _populateUserData(Map<String, dynamic>? data) {
    if (data != null) {
      _nameController.text = data['name'] ?? '';
      _idController.text = data['idCard'] ?? '';
      _emailController.text = data['email'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _role = data['role'] ?? 'cliente';
      _status = data['status'] ?? '';
      _imageUrl = data['imageUrl'] ?? '';
    }
  }

  Future<void> _toggleBlockUser() async {
    String newStatus = _status == 'blocked' ? 'active' : 'blocked';
    String action = newStatus == 'blocked' ? 'bloquear' : 'desbloquear';

    final confirm = await _showConfirmationDialog('Confirmar $action usuario', '¿Estás seguro de que deseas $action a este usuario?');

    if (confirm == true) {
      await _updateUserStatus(newStatus, action);
    }
  }

  Future<void> _updateUserStatus(String newStatus, String action) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({'status': newStatus});
      setState(() {
        _status = newStatus;
      });
      _showSnackBar('Usuario $action exitosamente');
    } catch (e) {
      _showSnackBar('Error al $action usuario: $e');
    }
  }

  Future<void> _updateUser (String field) async {
      String value = _getFieldValue(field);
      if (value.isEmpty) {
          _showSnackBar('El campo no puede estar vacío');
          return;
      }

      if (await _isValueUnchanged(field, value) || !await _validateField(field, value)) return;

      final confirm = await _showConfirmationDialog('Confirmar actualización', '¿Estás seguro de que deseas actualizar el campo $field?');
      if (confirm == true) {
          if (field == 'email') {
             return _showSnackBar('No se puede actualizar el correo electrónico actualmente');
          }

          // Actualizar el usuario en Firestore
          await _performUserUpdate(field, value);
      }
  }

  String _getFieldValue(String field) {
    switch (field) {
      case 'name': return _nameController.text;
      case 'idCard': return _idController.text;
      case 'email': return _emailController.text;
      case 'phone': return _phoneController.text;
      default: return '';
    }
  }

/*************  ✨ Codeium Command ⭐  *************/
  /// Verifica si el valor proporcionado es diferente al valor actual en el campo del usuario especificado.
  ///
  /// Si el valor es diferente, se muestra un mensaje de error y se devuelve [true]. De lo contrario, se devuelve [false].
  ///
/******  629aac7b-fa90-4b87-b459-81dd32d1f65b  *******/
  Future<bool> _isValueUnchanged(String field, String value) async {
    final currentValue = await _getCurrentValue(field);
    if (currentValue == value) {
      _showSnackBar('No hay cambios para actualizar');
      return true;
    }
    return false;
  }

  Future<bool> _validateField(String field, String value) async {
    if (field == 'idCard') {
    // Verificar el formato de la cédula
    if (!validateIdCard(value)) {
        _showSnackBar('Cédula de identidad no válida');
        return false;
    }

    // Verificar que la cédula no esté ya en uso
    final existingIdCard = await FirebaseFirestore.instance
        .collection('users')
        .where('idCard', isEqualTo: value)
        .get();

    if (existingIdCard.docs.isNotEmpty) {
        _showSnackBar('La cédula de identidad ya está en uso');
        return false;
    }
}

    if (field == 'email') {
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
        _showSnackBar('Correo electrónico no válido');
        return false;
      }

      final existingEmail = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: value)
          .get();
      if (existingEmail.docs.isNotEmpty) {
        _showSnackBar('El correo electrónico ya existe');
        return false;
      }
    }

    if (field == 'phone' && !validatePhoneNumber(value)) {
      _showSnackBar('Número telefónico no válido');
      return false;
    }

    return true;
  }

  Future<void> _performUserUpdate(String field, String value) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({field: value});
      _showSnackBar('Usuario actualizado exitosamente');
    } catch (e) {
      _showSnackBar('Error al actualizar el usuario: $e');
    }
  }

  Future<String> _getCurrentValue(String field) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    return doc.exists ? (doc.data()?[field] ?? '') : '';
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

  Future<bool> _validatePassword(String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser ;
      if (user == null) return false;

      AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _changeRole(String newRole) async {
    final password = await _showPasswordDialog();
    if (password == null) return;

    if (!await _validatePassword(password)) {
      _showSnackBar('Contraseña incorrecta');
      return;
    }

    final confirm = await _showConfirmationDialog('Confirmar cambio de rol', '¿Estás seguro de que deseas cambiar el rol a $newRole?');
    if (confirm == true) {
      await _updateRole(newRole);
    }
  }

  Future<void> _updateRole(String newRole) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({'role': newRole});
      setState(() {
        _role = newRole;
      });
      _showSnackBar('Rol actualizado exitosamente');
    } catch (e) {
      _showSnackBar('Error al actualizar el rol: $e');
    }
  }

  Future<bool?> _showConfirmationDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
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
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
      )
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, bool isEditing, VoidCallback toggleEdit, String field) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                enabled: isEditing,
                decoration: InputDecoration(
                  enabledBorder: isEditing 
                      ? UnderlineInputBorder() 
                      : InputBorder.none,
                  focusedBorder: isEditing 
                      ? UnderlineInputBorder() 
                      : InputBorder.none,
                  hintText: isEditing ? null : controller.text,
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isEditing ? Colors.black : Colors.grey[700],
                ),
                readOnly: !isEditing,
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(isEditing ? Icons.check : Icons.edit),
          onPressed: () {
            if (isEditing) {
              _updateUser(field);
              toggleEdit();
            } else {
              toggleEdit();
            }
          },
        ),
      ],
    );
  }

  Widget _buildDataCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEditableField('Nombre', _nameController, _isEditingName, () {
              setState(() {
                _isEditingName = !_isEditingName;
              });
            }, 'name'),
            const SizedBox(height: 16),
            _buildEditableField('Cédula de Identidad', _idController, _isEditingId, () {
              setState(() {
                _isEditingId = !_isEditingId;
              });
            }, 'idCard'),
            const SizedBox(height: 16),
            _buildEditableField('Correo Electrónico', _emailController, _isEditingEmail, () {
              setState(() {
                _isEditingEmail = !_isEditingEmail;
              });
            }, 'email'),
            const SizedBox(height: 16),
            _buildEditableField('Teléfono', _phoneController, _isEditingPhone, () {
              setState(() {
                _isEditingPhone = !_isEditingPhone;
              });
            }, 'phone'),
            const SizedBox(height: 16),
            _buildRoleField(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _role,
            items: [
              DropdownMenuItem(value: 'cliente', child: Text('Cliente')),
              DropdownMenuItem(value: 'administrador', child: Text('Administrador')),
            ],
            onChanged: (value) {
              if (value != null) {
                _changeRole(value);
              }
            },
            decoration: InputDecoration(labelText: 'Rol', border: OutlineInputBorder()),
          ),
        ),
      ],
    );
  }

  Widget _buildImageField() {
    return Center(
      child: CircleAvatar(
        radius: 80,
        backgroundImage: _imageUrl != null || _imageUrl!.isNotEmpty ? NetworkImage(_imageUrl!) : null,
        child: _imageUrl == null || _imageUrl!.isEmpty ? Icon(Icons.person, size: 70) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Usuario'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageField(),
                    const SizedBox(height: 16.0),
                    _buildDataCard(),
                    const SizedBox(height: 16.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: _toggleBlockUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 40.0),
                          textStyle: const TextStyle(fontSize: 18, color : Colors.white),
                        ),
                        child: Text(_status == 'blocked' ? 'Desbloquear Usuario' : 'Bloquear Usuario'),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserOrdersScreen(userId: widget.userId, fromAdmin: true),
                            ),
                          )
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 40.0),
                          textStyle: const TextStyle(fontSize: 18, color : Colors.white),
                        ),
                        child: Text('Ver Pedidos'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}