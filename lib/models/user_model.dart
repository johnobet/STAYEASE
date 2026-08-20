class StayEaseUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? profilePhoto;
  final DateTime createdAt;

  StayEaseUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profilePhoto,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'profilePhoto': profilePhoto,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StayEaseUser.fromMap(Map<String, dynamic> map) {
    return StayEaseUser(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'tenant',
      profilePhoto: map['profilePhoto'],
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}