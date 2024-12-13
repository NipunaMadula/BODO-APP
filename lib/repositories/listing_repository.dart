import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bodo_app/models/listing_model.dart';
import 'dart:io';

class ListingRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final int maxRetries = 3;

  ListingRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Future<List<String>> uploadImages(List<File> images, String userId) async {
    List<String> imageUrls = [];
    
    for (var image in images) {
      String? url = await _uploadSingleImage(image, userId, imageUrls.length);
      if (url != null) {
        imageUrls.add(url);
      } else {
        throw 'Failed to upload image after multiple retries';
      }
    }
    
    return imageUrls;
  }

  Future<String?> _uploadSingleImage(File image, String userId, int index) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$index.jpg';
        final ref = _storage
            .ref()
            .child('listings')
            .child(userId)
            .child(fileName);
        
        // Upload with metadata
        await ref.putFile(
          image,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'userId': userId,
              'timestamp': DateTime.now().toString(),
              'attempt': attempts.toString(),
            },
          ),
        );
        
        // Get and return download URL if successful
        return await ref.getDownloadURL();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          print('Failed to upload image after $maxRetries attempts: $e');
          return null;
        }
        // Wait before retrying with exponential backoff
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
    return null;
  }

  Future<ListingModel> createListing(ListingModel listing) async {
    final docRef = await _firestore
        .collection('listings')
        .add(listing.toMap());
        
    return listing.copyWith(id: docRef.id);
  }

  Future<ListingModel> createListingWithImages({
    required String userId,
    required String title,
    required String description,
    required String type,
    required double price,
    required String location,
    required List<File> images,
    required String phone, 
  }) async {
    List<String> uploadedUrls = [];
    try {
      // Try to upload images
      uploadedUrls = await uploadImages(images, userId);
      
      // Create listing with successful uploads
      final listing = ListingModel(
        id: '',
        userId: userId,
        title: title,
        description: description,
        type: type,
        price: price,
        location: location,
        phone: phone, 
        images: uploadedUrls,
        createdAt: DateTime.now(),
      );

      return await createListing(listing);
    } catch (e) {
      // If any images were uploaded before failure, clean them up
      if (uploadedUrls.isNotEmpty) {
        await _cleanupFailedUploads(uploadedUrls);
      }
      throw 'Failed to create listing: $e';
    }
  }

  Stream<List<ListingModel>> getListings() {
    return _firestore
        .collection('listings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ListingModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<ListingModel>> getListingsByUserId(String userId) {
    return _firestore
        .collection('listings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ListingModel.fromFirestore(doc))
            .toList());
  }

  Future<void> deleteListing(String listingId) async {
    // First get the listing to get image URLs
    final docSnapshot = await _firestore.collection('listings').doc(listingId).get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data['images'] != null) {
        // Delete all images from storage
        final List<String> imageUrls = List<String>.from(data['images']);
        await _cleanupFailedUploads(imageUrls);
      }
    }
    // Then delete the listing document
    await _firestore.collection('listings').doc(listingId).delete();
  }

  Future<void> updateListing(String listingId, Map<String, dynamic> data) async {
    await _firestore.collection('listings').doc(listingId).update(data);
  }

  Future<void> _cleanupFailedUploads(List<String> urls) async {
    for (var url in urls) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(url);
        await ref.delete();
      } catch (e) {
        print('Failed to cleanup image: $e');
      }
    }
  }
}