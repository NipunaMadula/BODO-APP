import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bodo_app/models/listing_model.dart';
import 'dart:io';

class ListingRepository {
 final FirebaseFirestore _firestore;
 final FirebaseStorage _storage;

 ListingRepository({
   FirebaseFirestore? firestore,
   FirebaseStorage? storage,
 })  : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  Future<List<String>> uploadImages(List<File> images, String userId) async {
    try {
      List<String> imageUrls = [];
      
      for (var image in images) {
        // Create a reference to 'listings/userId/timestamp_index.jpg'
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageUrls.length}.jpg';
        final ref = _storage
            .ref()
            .child('listings')
            .child(userId)
            .child(fileName);
        
        // Upload file
        await ref.putFile(
          image,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {'userId': userId},
          ),
        );
        
        // Get download URL
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }
      
      return imageUrls;
    } catch (e) {
      throw 'Failed to upload images: $e';
    }
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
 }) async {
   // First upload images
   final imageUrls = await uploadImages(images, userId);
   
   // Create listing model
   final listing = ListingModel(
     id: '',
     userId: userId,
     title: title,
     description: description,
     type: type,
     price: price,
     location: location,
     images: imageUrls,
     createdAt: DateTime.now(),
   );

   // Save to Firestore
   return createListing(listing);
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
   await _firestore.collection('listings').doc(listingId).delete();
 }

 Future<void> updateListing(String listingId, Map<String, dynamic> data) async {
   await _firestore.collection('listings').doc(listingId).update(data);
 }
}