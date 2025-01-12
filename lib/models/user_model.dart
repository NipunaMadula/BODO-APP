import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final DateTime createdAt;
  final String? profilePicture; 

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    required this.createdAt,
    this.profilePicture,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    try {
      return UserModel(
        id: doc.id,
        email: data['email'] ?? '',
        name: data['name'],
        phone: data['phone'],
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        profilePicture: data['profilePicture'],
      );
    } catch (e) {
      throw 'Error parsing user data: $e';
    }
  }

  Map<String, dynamic> toMap() => {
    'email': email,
    'name': name,
    'phone': phone,
    'createdAt': Timestamp.fromDate(createdAt),
    'profilePicture': profilePicture,
  };

  @override
  String toString() => 'UserModel(id: $id, email: $email, name: $name, phone: $phone, createdAt: $createdAt, profilePicture: $profilePicture)';
}

extension UserModelExtension on UserModel {
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    DateTime? createdAt,
    String? profilePicture,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      profilePicture: profilePicture ?? this.profilePicture, 
    );
  }
}