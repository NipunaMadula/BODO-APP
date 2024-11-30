import 'package:cloud_firestore/cloud_firestore.dart';

class ListingModel {
  final String id;
  final String title;
  final String description;
  final String type;
  final double price;
  final String location;
  final String userId;
  final List<String> images;
  final DateTime createdAt;

  ListingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.price,
    required this.location,
    required this.userId,
    required this.images,
    required this.createdAt,
  });

  factory ListingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ListingModel(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      type: data['type'],
      price: data['price'].toDouble(),
      location: data['location'],
      userId: data['userId'],
      images: List<String>.from(data['images']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'type': type,
    'price': price,
    'location': location,
    'userId': userId,
    'images': images,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  ListingModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    double? price,
    String? location,
    String? userId,
    List<String>? images,
    DateTime? createdAt,
  }) {
    return ListingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      price: price ?? this.price,
      location: location ?? this.location,
      userId: userId ?? this.userId,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}