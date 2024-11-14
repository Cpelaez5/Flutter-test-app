class UserModel {
  final String uid;
  final String idCard;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? imageUrl;
  final String? status;

  UserModel({
    required this.uid,
    required this.idCard,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.imageUrl,
    this.status
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] as String? ?? '',
      idCard: data['idCard'] as String? ?? '',
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      role: data['role'] as String? ?? 'cliente',
      imageUrl: data['imageUrl'] as String? ?? '',
      status: data['status'] as String? ?? '',
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
      'imageUrl': imageUrl,
      'status': status
    };
  }
}