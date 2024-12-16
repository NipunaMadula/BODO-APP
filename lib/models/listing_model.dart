import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class ListingModel {
  final String id;
  final String title;
  final String description;
  final String type;
  final double price;
  final String district;
  final String location;
  final String phone;
  final String userId;
  final List<String> images;
  final DateTime createdAt;

  ListingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.price,
    required this.district,
    required this.location,
    required this.phone,
    required this.userId,
    required this.images,
    required this.createdAt,
  });

  factory ListingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    try {
      final dynamic rawPrice = data['price'];
      final double price = switch (rawPrice) {
        null => 0.0,
        num n => n.toDouble(),
        String s => double.tryParse(s) ?? 0.0,
        _ => 0.0,
      };

      final List<String> images = switch (data['images']) {
        null => [],
        List l => List<String>.from(l),
        _ => [],
      };

      final DateTime createdAt = switch (data['createdAt']) {
        Timestamp t => t.toDate(),
        DateTime d => d,
        _ => DateTime.now(),
      };

      return ListingModel(
        id: doc.id,
        title: data['title']?.toString() ?? '',
        description: data['description']?.toString() ?? '',
        type: data['type']?.toString() ?? '',
        price: price,
        district: data['district']?.toString() ?? '',
        location: data['location']?.toString() ?? '',
        phone: data['phone']?.toString() ?? '',
        userId: data['userId']?.toString() ?? '',
        images: images,
        createdAt: createdAt,
      );
    } catch (e) {
      print('Error parsing document ${doc.id}: $e');
      print('Raw document data: $data');
      rethrow;
    }
  }

  static bool isValidListing(Map<String, dynamic> data) {
    try {
      if (data['title']?.toString().isEmpty ?? true) return false;
      if (data['location']?.toString().isEmpty ?? true) return false;
      if (data['type']?.toString().isEmpty ?? true) return false;
      if (data['district']?.toString().isEmpty ?? true) return false;

      final dynamic price = data['price'];
      if (price != null) {
        final double? numPrice = switch (price) {
          num n => n.toDouble(),
          String s => double.tryParse(s),
          _ => null,
        };
        if (numPrice == null || numPrice < 0) return false;
      }

      final String phone = data['phone']?.toString() ?? '';
      if (!RegExp(r'^\d{10}$').hasMatch(phone)) return false;

      return true;
    } catch (e) {
      print('Validation error: $e');
      return false;
    }
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'type': type,
    'price': price,
    'district': district,
    'location': location,
    'phone': phone,
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
    String? district,
    String? location,
    String? phone,
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
      district: district ?? this.district,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      userId: userId ?? this.userId,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static Future<ListingModel> createListingWithImages({
    required String userId,
    required String title,
    required String description,
    required String type,
    required double price,
    required String district,
    required String location,
    required String phone,
    required List<File> images,
    required Future<List<String>> Function(List<File> images, String userId) uploadImages,
  }) async {
    final imageUrls = await uploadImages(images, userId);
    
    return ListingModel(
      id: '',
      userId: userId,
      title: title,
      description: description,
      type: type,
      price: price,
      district: district,
      location: location,
      phone: phone,
      images: imageUrls,
      createdAt: DateTime.now(),
    );
  }

  static String? validateFields({
    required String title,
    required String description,
    required String type,
    required String price,
    required String district,
    required String location,
    required String phone,
    required List<File>? images,
  }) {
    if (title.trim().isEmpty) return 'Title is required';
    if (description.trim().isEmpty) return 'Description is required';
    if (type.isEmpty) return 'Property type is required';
    if (price.isEmpty) return 'Price is required';
    if (district.trim().isEmpty) return 'District is required';
    if (location.trim().isEmpty) return 'Location is required';
    if (phone.trim().isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\d{10}$').hasMatch(phone.trim())) {
      return 'Please enter a valid 10-digit phone number';
    }
    if (images == null || images.isEmpty) {
      return 'At least one image is required';
    }

    try {
      final priceValue = double.parse(price);
      if (priceValue <= 0) return 'Price must be greater than 0';
    } catch (e) {
      return 'Please enter a valid price';
    }

    return null;
  }

  bool get isValid => validateFields(
    title: title,
    description: description,
    type: type,
    price: price.toString(),
    district: district,
    location: location,
    phone: phone,
    images: null,
  ) == null;

  @override
  String toString() => 'ListingModel(id: $id, title: $title, type: $type, price: $price, district: $district, location: $location)';
}