import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/review_model.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ReviewModel>> getReviewsForListing(String listingId) {
    try {
      return _firestore
          .collection('reviews')
          .where('listingId', isEqualTo: listingId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .handleError((error) {
            print('Error fetching reviews: $error');
            return Stream.value([]);
          })
          .map((snapshot) => 
              snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList());
    } catch (e) {
      print('Error in getReviewsForListing: $e');
      return Stream.value([]);
    }
  }

Stream<List<ReviewModel>> getUserReviews(String userId) {
  try {
    return _firestore
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList());
  } catch (e) {
    print('Error in getUserReviews: $e');
    return Stream.value([]);
  }
}

Future<void> addReview({
  required String listingId,
  required String userId,
  required String userName,
  required int rating,
  required String comment,
}) async {
  try {
    final listingDoc = await _firestore
        .collection('listings')
        .doc(listingId)
        .get();
    
    final listingData = listingDoc.data();
    final listingTitle = listingDoc.exists && listingData != null
        ? listingData['title'] as String? ?? 'Unknown Listing'
        : 'Deleted Listing';

    await _firestore.collection('reviews').add({
      'listingId': listingId,
      'listingTitle': listingTitle,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    print('Error adding review: $e');
    throw 'Failed to add review. Please try again.';
  }
}

  Future<bool> canDeleteReview(String reviewId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    try {
      final doc = await _firestore.collection('reviews').doc(reviewId).get();
      if (!doc.exists) return false;
      
      final data = doc.data() as Map<String, dynamic>;
      return data['userId'] == user.uid;
    } catch (e) {
      print('Error checking review permissions: $e');
      return false;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      final canDelete = await canDeleteReview(reviewId);
      if (!canDelete) {
        throw 'You do not have permission to delete this review';
      }
      await _firestore.collection('reviews').doc(reviewId).delete();
    } catch (e) {
      print('Error deleting review: $e');
      throw 'Failed to delete review: $e';
    }
  }

  Future<double> getAverageRating(String listingId) async {
    final querySnapshot = await _firestore
        .collection('reviews')
        .where('listingId', isEqualTo: listingId)
        .get();

    if (querySnapshot.docs.isEmpty) return 0.0;

    final totalRating = querySnapshot.docs
        .map((doc) => doc.data()['rating'] as int)
        .reduce((a, b) => a + b);

    return totalRating / querySnapshot.docs.length;
  }
}