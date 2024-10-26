class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'administrador', 'vendedor' o 'cliente'

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  // Método para crear un UserModel desde un Map (por ejemplo, desde Firestore)
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'cliente', // Valor por defecto
    );
  }

  // Método para convertir un UserModel a un Map (para guardar en Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}