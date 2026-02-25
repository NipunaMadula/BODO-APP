import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart'; 

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
  final double? latitude;
  final double? longitude;
  final double? distance;  
  final bool available;

  static String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

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
    this.latitude,   
    this.longitude,    
    this.distance,
    bool? available,
    }) : available = available ?? true;

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
        title: toTitleCase(data['title']?.toString() ?? ''),
        description: data['description']?.toString() ?? '',
        type: data['type']?.toString() ?? '',
        price: price,
        district: data['district']?.toString() ?? '',
        location: toTitleCase(data['location']?.toString() ?? ''),
        phone: data['phone']?.toString() ?? '',
        userId: data['userId']?.toString() ?? '',
        images: images,
        createdAt: createdAt,
        latitude: (data['latitude'] as num?)?.toDouble(),
        longitude: (data['longitude'] as num?)?.toDouble(),
        distance: null,
        available: (data['available'] as bool?) ?? true,
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
    'latitude': latitude,
    'longitude': longitude,
    'available': available,
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
    double? latitude,
    double? longitude,
    double? distance,
    bool? available,
  }) {
    return ListingModel(
      id: id ?? this.id,
      title: title != null ? toTitleCase(title) : this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      price: price ?? this.price,
      district: district ?? this.district,
      location: location != null ? toTitleCase(location) : this.location,
      phone: phone ?? this.phone,
      userId: userId ?? this.userId,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
      available: available ?? this.available,
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
    double? latitude,
    double? longitude,
    required Future<List<String>> Function(List<File> images, String userId) uploadImages,
    bool available = true,
  }) async {
    final imageUrls = await uploadImages(images, userId);
    
    return ListingModel(
      id: '',
      userId: userId,
      title: toTitleCase(title),
      description: description,
      type: type,
      price: price,
      district: district,
      location: toTitleCase(location),
      phone: phone,
      images: imageUrls,
      createdAt: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      distance: null,
      available: available,
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

  ListingModel withDistance(double userLat, double userLng) {
    if (latitude == null || longitude == null) return this;
    
    final distanceInMeters = Geolocator.distanceBetween(
      userLat,
      userLng,
      latitude!,
      longitude!,
    );
    
    return copyWith(distance: distanceInMeters);
  }
}  