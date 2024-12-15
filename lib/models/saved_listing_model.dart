import 'package:cloud_firestore/cloud_firestore.dart';

class SavedListingModel {
  final String userId;
  final String listingId;
  final DateTime savedAt;

  SavedListingModel({
    required this.userId,
    required this.listingId,
    required this.savedAt,
  });

  factory SavedListingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavedListingModel(
      userId: data['userId'] ?? '',
      listingId: doc.id,
      savedAt: (data['savedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'savedAt': Timestamp.fromDate(savedAt),
  };

  SavedListingModel copyWith({
    String? userId,
    String? listingId,
    DateTime? savedAt,
  }) {
    return SavedListingModel(
      userId: userId ?? this.userId,
      listingId: listingId ?? this.listingId,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  @override
  String toString() => 
    'SavedListingModel(userId: $userId, listingId: $listingId, savedAt: $savedAt)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavedListingModel &&
        other.userId == userId &&
        other.listingId == listingId &&
        other.savedAt == savedAt;
  }

  @override
  int get hashCode => userId.hashCode ^ listingId.hashCode ^ savedAt.hashCode;
}