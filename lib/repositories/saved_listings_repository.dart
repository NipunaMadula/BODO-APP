import 'package:bodo_app/models/listing_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SavedListingsRepository {
  final FirebaseFirestore _firestore;

  SavedListingsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> toggleSavedListing({
    required String userId,
    required String listingId,
  }) async {
    try {
      final docRef = _firestore
          .collection('saved_listings')
          .doc(userId)
          .collection('listings')
          .doc(listingId);

      final doc = await docRef.get();
      if (doc.exists) {
        await docRef.delete();
      } else {
        await docRef.set({
          'savedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error toggling saved listing: $e');
      throw 'Failed to save/unsave listing. Please try again.';
    }
  }

  Stream<bool> isListingSaved({
    required String userId,
    required String listingId,
  }) {
    if (userId.isEmpty || listingId.isEmpty) {
      return Stream.value(false);
    }

    return _firestore
        .collection('saved_listings')
        .doc(userId)
        .collection('listings')
        .doc(listingId)
        .snapshots()
        .map((doc) => doc.exists)
        .handleError((error) {
          print('Error checking if listing is saved: $error');
          return false;
        });
  }

  Stream<List<String>> getSavedListingIds(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('saved_listings')
        .doc(userId)
        .collection('listings')
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList())
        .handleError((error) {
          print('Error getting saved listing IDs: $error');
          return [];
        });
  }

  Stream<List<ListingModel>> getSavedListings(String userId) {
    if (userId.isEmpty) return Stream.value([]);

    return getSavedListingIds(userId).asyncMap((savedIds) async {
      if (savedIds.isEmpty) return [];

      try {
        final futures = savedIds.map((id) =>
            _firestore.collection('listings').doc(id).get());

        final docs = await Future.wait(futures);
        return docs
            .where((doc) => doc.exists)
            .map((doc) => ListingModel.fromFirestore(doc))
            .toList();
      } catch (e) {
        print('Error fetching saved listings: $e');
        return [];
      }
    });
  }

  Future<void> clearSavedListings(String userId) async {
    try {
      final batch = _firestore.batch();
      final snapshots = await _firestore
          .collection('saved_listings')
          .doc(userId)
          .collection('listings')
          .get();

      for (var doc in snapshots.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error clearing saved listings: $e');
      throw 'Failed to clear saved listings. Please try again.';
    }
  }
}