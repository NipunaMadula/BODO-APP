import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/payment_model.dart';

class PaymentRepository {
  // local storage key
  static const _kKey = 'local_payments';
  static final StreamController<List<PaymentModel>> _controller = StreamController.broadcast();

  PaymentRepository() {
    _init();
  }

  Future<void> _init() async {
    final list = await _loadPayments();
    _controller.add(list);
  }

  Future<List<PaymentModel>> _loadPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final arr = json.decode(raw) as List<dynamic>;
      return arr.map((e) => PaymentModel.fromMap(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _savePayments(List<PaymentModel> payments) async {
    final prefs = await SharedPreferences.getInstance();
    final enc = json.encode(payments.map((p) => p.toMap()).toList());
    await prefs.setString(_kKey, enc);
    _controller.add(payments);
  }

  Future<void> addPayment({
    required String listingId,
    required String listingOwnerId,
    required String payerId,
    required String payerName,
    required double amount,
    String method = 'card (dummy)',
    String status = 'completed',
  }) async {
    final now = DateTime.now();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final payment = PaymentModel(
      id: id,
      listingId: listingId,
      listingOwnerId: listingOwnerId,
      payerId: payerId,
      payerName: payerName,
      amount: amount,
      method: method,
      status: status,
      createdAt: now,
    );

    final list = await _loadPayments();
    list.insert(0, payment);
    await _savePayments(list);
  }

  Stream<List<PaymentModel>> getPaymentsForListing(String listingId) {
    return _controller.stream.asyncMap((_) async {
      final list = await _loadPayments();
      return list.where((p) => p.listingId == listingId).toList();
    });
  }

  Stream<List<PaymentModel>> getPaymentsForOwner(String ownerId) {
    return _controller.stream.asyncMap((_) async {
      final list = await _loadPayments();
      return list.where((p) => p.listingOwnerId == ownerId).toList();
    });
  }
}
