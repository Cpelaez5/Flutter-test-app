import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Asegúrate de importar Firestore
import 'user_detail_screen.dart'; // Asegúrate de tener esta pantalla

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<Map<String, dynamic>> users = []; // Lista de usuarios

  @override
  void initState() {
    super.initState();
    _fetchUsers(); // Cargar usuarios al inicializar
  }

  Future<void> _fetchUsers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        users = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
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
                          builder: (context) => UserDetailScreen(user: users[index]), // Navegar a detalles del usuario
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
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
      ),
    );
  }
}