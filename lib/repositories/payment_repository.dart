import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/payment_model.dart';

class PaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addPayment({
    required String listingId,
    required String listingOwnerId,
    required String payerId,
    required String payerName,
    required double amount,
    String method = 'card (dummy)',
    String status = 'completed',
  }) async {
    try {
      await _firestore.collection('payments').add({
        'listingId': listingId,
        'listingOwnerId': listingOwnerId,
        'payerId': payerId,
        'payerName': payerName,
        'amount': amount,
        'method': method,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding payment: $e');
      throw 'Failed to record payment';
    }
  }

  Stream<List<PaymentModel>> getPaymentsForListing(String listingId) {
    try {
      return _firestore
          .collection('payments')
          .where('listingId', isEqualTo: listingId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map((d) => PaymentModel.fromFirestore(d)).toList());
    } catch (e) {
      print('Error fetching payments for listing: $e');
      return Stream.value([]);
    }
  }

  Stream<List<PaymentModel>> getPaymentsForOwner(String ownerId) {
    try {
      return _firestore
          .collection('payments')
          .where('listingOwnerId', isEqualTo: ownerId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map((d) => PaymentModel.fromFirestore(d)).toList());
    } catch (e) {
      print('Error fetching payments for owner: $e');
      return Stream.value([]);
    }
  }
}
