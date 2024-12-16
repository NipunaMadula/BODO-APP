import 'package:bodo_app/repositories/saved_listings_repository.dart';
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
    try {
      print('Starting to upload ${images.length} images');
      List<String> imageUrls = [];
      
      for (var image in images) {
        String? url = await _uploadSingleImage(image, userId, imageUrls.length);
        if (url != null) {
          imageUrls.add(url);
          print('Successfully uploaded image: $url');
        } else {
          throw 'Failed to upload image after multiple retries';
        }
      }
      
      return imageUrls;
    } catch (e) {
      print('Error in uploadImages: $e');
      rethrow;
    }
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
        
        return await ref.getDownloadURL();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          print('Failed to upload image after $maxRetries attempts: $e');
          return null;
        }
  
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
    return null;
  }

  Future<ListingModel> createListing(ListingModel listing) async {
    try {
      print('Creating listing: ${listing.toMap()}'); // Debug log
      final docRef = await _firestore
          .collection('listings')
          .add(listing.toMap());
      print('Created listing with ID: ${docRef.id}'); // Debug 
      return listing.copyWith(id: docRef.id);
    } catch (e) {
      print('Error creating listing: $e');
      rethrow;
    }
  }

  Future<ListingModel> createListingWithImages({
    required String userId,
    required String title,
    required String description,
    required String type,
    required double price,
    required String district, 
    required String location,
    required List<File> images,
    required String phone,
  }) async {
    List<String> uploadedUrls = [];
    try {
      print('Starting image upload for user: $userId'); // Debug 
      uploadedUrls = await uploadImages(images, userId);
      print('Uploaded ${uploadedUrls.length} images'); // Debug log
      
      final listing = ListingModel(
        id: '',
        userId: userId,
        title: title,
        description: description,
        type: type,
        price: price,
        district: district,
        location: location,
        phone: phone,
        images: uploadedUrls,
        createdAt: DateTime.now(),
      );

      print('Creating listing with uploaded images'); // Debug log
      return await createListing(listing);
    } catch (e) {
      print('Error in createListingWithImages: $e');
      if (uploadedUrls.isNotEmpty) {
        print('Cleaning up ${uploadedUrls.length} uploaded images'); // Debug log
        await _cleanupFailedUploads(uploadedUrls);
      }
      rethrow;
    }
  }

  Stream<List<ListingModel>> getSavedListings(String userId) {
  if (userId.isEmpty) return Stream.value([]);
  
  final _savedListingsRepository = SavedListingsRepository();

  return _savedListingsRepository
    .getSavedListingIds(userId)
    .asyncMap((savedIds) async {
      if (savedIds.isEmpty) return [];
      
      final futures = savedIds.map((id) => 
        _firestore.collection('listings').doc(id).get()
      );
      
      final docs = await Future.wait(futures);
      return docs
          .where((doc) => doc.exists)
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();
    });
}

Stream<List<ListingModel>> getListings() {
  try {
    return _firestore
        .collection('listings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print('Got ${snapshot.docs.length} listings from Firestore');
          return snapshot.docs.where((doc) {
            final data = doc.data();
            final isValid = ListingModel.isValidListing(data);
            if (!isValid) {
              print('Invalid listing data for doc ${doc.id}: $data');
            }
            return isValid;
          }).map((doc) {
            try {
              return ListingModel.fromFirestore(doc);
            } catch (e) {
              print('Error parsing listing ${doc.id}: $e');
              rethrow;
            }
          }).toList();
        });
  } catch (e) {
    print('Error in getListings: $e');
    rethrow;
  }
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
    final docSnapshot = await _firestore.collection('listings').doc(listingId).get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data['images'] != null) {
        final List<String> imageUrls = List<String>.from(data['images']);
        await _cleanupFailedUploads(imageUrls);
      }
    }
    // Delete the listing document
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