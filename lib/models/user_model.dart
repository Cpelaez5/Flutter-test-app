class UserModel {
  final String uid;
  final String idCard;
  final String name;
  final String email;
  final String phone;
  final String role;

  UserModel({
    required this.uid,
    required this.idCard,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] as String? ?? '',
      idCard: data['idCard'] as String? ?? '',
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      role: data['role'] as String? ?? 'cliente',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'idCard': idCard,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }
}