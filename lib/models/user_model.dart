import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    try {
      return UserModel(
        id: doc.id,
        email: data['email'] ?? '',
        createdAt: (data['createdAt'] as Timestamp).toDate(),
      );
    } catch (e) {
      throw 'Error parsing user data: $e';
    }
  }

  Map<String, dynamic> toMap() => {
    'email': email,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  @override
  String toString() => 'UserModel(id: $id, email: $email, createdAt: $createdAt)';
}