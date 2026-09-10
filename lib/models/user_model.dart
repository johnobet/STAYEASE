import 'package:cloud_firestore/cloud_firestore.dart';

/// Matches spec section 30 — only the roles a person can self-register as.
/// Admin accounts are provisioned separately (spec section 5), never
/// through the public Register screen.
enum UserRole { tenant, owner, admin }

extension UserRoleX on UserRole {
  String get value => name;

  static UserRole fromString(String? value) {
    switch (value) {
      case 'owner':
        return UserRole.owner;
      case 'admin':
        return UserRole.admin;
      case 'tenant':
      default:
        return UserRole.tenant;
    }
  }
}

class UserModel {
  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profilePhoto,
    this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? profilePhoto;
  final DateTime? createdAt;

  /// For writing to Firestore. `uid` is the document ID, not a field.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.value,
      'profilePhoto': profilePhoto,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    final timestamp = map['createdAt'];
    return UserModel(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      role: UserRoleX.fromString(map['role'] as String?),
      profilePhoto: map['profilePhoto'] as String?,
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }
}