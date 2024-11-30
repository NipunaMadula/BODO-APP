import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bodo_app/models/listing_model.dart';

class ListingRepository {
  final FirebaseFirestore _firestore;

  ListingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<ListingModel> createListing(ListingModel listing) async {
    final docRef = await _firestore
        .collection('listings')
        .add(listing.toMap());
    
    return listing.copyWith(id: docRef.id);
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
}