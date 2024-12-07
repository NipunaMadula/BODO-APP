import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
 final String id;
 final String email;
 final String? name;
 final String? phone;
 final DateTime createdAt;

 UserModel({
   required this.id,
   required this.email,
   this.name,
   this.phone, 
   required this.createdAt,
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
 };

 @override
 String toString() => 'UserModel(id: $id, email: $email, name: $name, phone: $phone, createdAt: $createdAt)';
}