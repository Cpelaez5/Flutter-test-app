import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Asegúrate de importar Firestore
import 'user_detail_screen.dart'; // Asegúrate de tener esta pantalla
import 'package:firebase_auth/firebase_auth.dart'; // Importar Firebase Auth para obtener el usuario actual

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<Map<String, dynamic>> users = []; // Lista de usuarios
  String currentUserId = ''; // ID del usuario actual

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId(); // Obtener el ID del usuario actual
  }

  Future<void> _fetchCurrentUserId() async {
    // Obtener el ID del usuario actualmente autenticado
    User? user = FirebaseAuth.instance.currentUser ;
    if (user != null) {
      currentUserId = user.uid;
      await _fetchUsers(); // Cargar usuarios después de obtener el ID
    }
  }

  Future<void> _fetchUsers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        users = snapshot.docs.map((doc) {
          // Agregar el ID del documento a cada usuario
          var data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id; // Agregar el ID del documento
          return data;
        }).toList();

        // Filtrar el usuario actual
        users.removeWhere((user) => user['id'] == currentUserId);
      });
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Usuarios'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh), // Icono de actualización
            tooltip: 'Actualizar Usuarios',
            onPressed: _fetchUsers, // Llamar al método para actualizar la lista de usuarios
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: users.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return UserCard(
                    user: users[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailScreen(userId: users[index]['id']), // Navegar a detalles del usuario
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onTap;

  UserCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Cambiar el color de fondo según si está bloqueado o no
    Color cardColor = user['status'] == 'blocked' ? Colors.red[100]! : Colors.green[100]!;

    // Icono dependiendo del rol
    IconData roleIcon = user['role'] == 'administrador' ? Icons.admin_panel_settings : Icons.person;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(vertical: 8.0),
        color: cardColor, // Color de la tarjeta
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(roleIcon, size: 30), // Icono del rol
              SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['name'] ?? 'Nombre no disponible',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Text('ID: ${user['idCard'] ?? 'ID no disponible'}'),
                    SizedBox(height: 4.0),
                    Text('Email: ${user['email'] ?? 'Email no disponible'}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}