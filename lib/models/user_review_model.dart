import 'package:cloud_firestore/cloud_firestore.dart';

class UserReviewModel {
  final String id;
  final String targetUserId;
  final String reviewerId;
  final String reviewerName;
  final int rating;
  final String comment;
  final String? listingId;
  final DateTime createdAt;

  UserReviewModel({
    required this.id,
    required this.targetUserId,
    required this.reviewerId,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    this.listingId,
    required this.createdAt,
  });

  factory UserReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserReviewModel(
      id: doc.id,
      targetUserId: data['targetUserId'] ?? '',
      reviewerId: data['reviewerId'] ?? '',
      reviewerName: data['reviewerName'] ?? 'Anonymous',
      rating: (data['rating'] as num?)?.toInt() ?? 0,
      comment: data['comment'] ?? '',
      listingId: data['listingId'] as String?,
      createdAt: ((data['createdAt'] as Timestamp?) ?? Timestamp.now()).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'targetUserId': targetUserId,
        'reviewerId': reviewerId,
        'reviewerName': reviewerName,
        'rating': rating,
        'comment': comment,
        if (listingId != null) 'listingId': listingId,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
