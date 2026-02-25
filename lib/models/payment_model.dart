import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String listingId;
  final String listingOwnerId;
  final String payerId;
  final String payerName;
  final double amount;
  final String method; // e.g., 'card (dummy)'
  final String status; // e.g., 'completed', 'pending'
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.listingId,
    required this.listingOwnerId,
    required this.payerId,
    required this.payerName,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
  });

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PaymentModel(
      id: doc.id,
      listingId: d['listingId'] ?? '',
      listingOwnerId: d['listingOwnerId'] ?? '',
      payerId: d['payerId'] ?? '',
      payerName: d['payerName'] ?? '',
      amount: (d['amount'] as num?)?.toDouble() ?? 0.0,
      method: d['method'] ?? 'card (dummy)',
      status: d['status'] ?? 'completed',
      createdAt: ((d['createdAt'] as Timestamp?) ?? Timestamp.now()).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'listingId': listingId,
        'listingOwnerId': listingOwnerId,
        'payerId': payerId,
        'payerName': payerName,
        'amount': amount,
        'method': method,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
