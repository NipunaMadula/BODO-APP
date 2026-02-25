import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_review_model.dart';

class UserReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<UserReviewModel>> getReviewsForUser(String userId) {
    try {
      return _firestore
          .collection('user_reviews')
          .where('targetUserId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map((d) => UserReviewModel.fromFirestore(d)).toList());
    } catch (e) {
      print('Error getting user reviews: $e');
      return Stream.value([]);
    }
  }

  Future<void> addReview({
    required String targetUserId,
    required String reviewerId,
    required String reviewerName,
    required int rating,
    required String comment,
    String? listingId,
  }) async {
    try {
      await _firestore.collection('user_reviews').add({
        'targetUserId': targetUserId,
        'reviewerId': reviewerId,
        'reviewerName': reviewerName,
        'rating': rating,
        'comment': comment,
        if (listingId != null) 'listingId': listingId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding user review: $e');
      throw 'Failed to add review';
    }
  }

  Future<String?> getUserIdByEmail(String email) async {
    try {
      final q = await _firestore.collection('users').where('email', isEqualTo: email).limit(1).get();
      if (q.docs.isEmpty) return null;
      return q.docs.first.id;
    } catch (e) {
      print('Error finding user by email: $e');
      return null;
    }
  }

  Future<double> getAverageRating(String userId) async {
    final snapshot = await _firestore
        .collection('user_reviews')
        .where('targetUserId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isEmpty) return 0.0;

    final total = snapshot.docs
        .map((d) => (d.data()['rating'] as num).toDouble())
        .reduce((a, b) => a + b);

    return total / snapshot.docs.length;
  }

  Future<bool> canDeleteReview(String reviewId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore.collection('user_reviews').doc(reviewId).get();
      if (!doc.exists) return false;
      final data = doc.data() as Map<String, dynamic>;
      return data['reviewerId'] == user.uid;
    } catch (e) {
      print('Error checking delete permission: $e');
      return false;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    final can = await canDeleteReview(reviewId);
    if (!can) throw 'No permission to delete review';
    await _firestore.collection('user_reviews').doc(reviewId).delete();
  }
}
