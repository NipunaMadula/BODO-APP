import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String listingId;
  final String listingTitle;
  final String userId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      listingId: data['listingId'] ?? '',
      listingTitle: data['listingTitle'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      rating: (data['rating'] as num?)?.toInt() ?? 0,
      comment: data['comment'] ?? '',
      createdAt: ((data['createdAt'] as Timestamp?) ?? Timestamp.now()).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'listingId': listingId,
        'listingTitle': listingTitle,
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  @override
  String toString() =>
      'ReviewModel(id: $id, listingTitle: $listingTitle, rating: $rating, comment: $comment)';

  bool get isValid =>
      id.isNotEmpty &&
      listingId.isNotEmpty &&
      listingTitle.isNotEmpty &&
      userId.isNotEmpty &&
      rating >= 0 &&
      rating <= 5;
}