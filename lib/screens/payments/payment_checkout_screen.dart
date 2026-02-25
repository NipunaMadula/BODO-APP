import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bodo_app/repositories/payment_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  final String listingId;
  final String listingOwnerId;
  final double amount;

  const PaymentCheckoutScreen({
    required this.listingId,
    required this.listingOwnerId,
    required this.amount,
    super.key,
  });

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvcCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _cardNumberCtrl.addListener(_formatCardNumber);
    _expiryCtrl.addListener(_formatExpiry);
  }

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvcCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _formatCardNumber() {
    final text = _cardNumberCtrl.text;
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    final parts = <String>[];
    for (var i = 0; i < digits.length; i += 4) {
      parts.add(digits.substring(i, i + 4 > digits.length ? digits.length : i + 4));
    }
    final formatted = parts.join(' ');
    if (formatted != text) {
      final sel = _cardNumberCtrl.selection;
      _cardNumberCtrl.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length.clamp(0, formatted.length)),
      );
    }
  }

  void _formatExpiry() {
    final text = _expiryCtrl.text;
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    var formatted = digits;
    if (digits.length > 2) {
      formatted = '${digits.substring(0,2)}/${digits.substring(2, digits.length>4?4:digits.length)}';
    }
    if (formatted != text) {
      _expiryCtrl.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length.clamp(0, formatted.length)),
      );
    }
  }

  bool _luhnCheck(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\s+'), '');
    if (digits.isEmpty) return false;
    int sum = 0;
    final reversed = digits.split('').reversed.toList();
    for (var i = 0; i < reversed.length; i++) {
      final d = int.tryParse(reversed[i]);
      if (d == null) return false;
      if (i % 2 == 1) {
        var dbl = d * 2;
        if (dbl > 9) dbl -= 9;
        sum += dbl;
      } else {
        sum += d;
      }
    }
    return sum % 10 == 0;
  }

  bool _expiryValid(String v) {
    if (!RegExp(r'^(0[1-9]|1[0-2])\/[0-9]{2}$').hasMatch(v)) return false;
    final parts = v.split('/');
    final mm = int.parse(parts[0]);
    final yy = int.parse(parts[1]);
    final now = DateTime.now();
    final year = 2000 + yy;
    final lastDay = DateTime(year, mm + 1, 0);
    return lastDay.isAfter(now);
  }

  String _maskCard(String num) {
    final cleaned = num.replaceAll(' ', '');
    if (cleaned.length <= 4) return cleaned;
    final last = cleaned.substring(cleaned.length - 4);
    return '•••• •••• •••• $last';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in to pay')));
      return;
    }

    setState(() => _loading = true);
    try {
      // In a real integration you'd create a payment intent and process card via SDK
      // Here we record a dummy successful payment in Firestore
      await PaymentRepository().addPayment(
        listingId: widget.listingId,
        listingOwnerId: widget.listingOwnerId,
        payerId: user.uid,
        payerName: _nameCtrl.text.trim().isEmpty ? (user.email ?? 'Anonymous') : _nameCtrl.text.trim(),
        amount: widget.amount,
        method: 'card',
        status: 'completed',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment recorded successfully')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pay Advance')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: Rs.${widget.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _cardNumberCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                    ],
                    decoration: const InputDecoration(labelText: 'Card Number'),
                    validator: (v) {
                      final digits = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                      if (digits.length != 16) return 'Enter 16 digit card number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expiryCtrl,
                          decoration: const InputDecoration(labelText: 'MM/YY'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          validator: (v) {
                            if (v == null || !_expiryValid(v.trim())) return 'Enter a valid expiry MM/YY';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          controller: _cvcCtrl,
                          decoration: const InputDecoration(labelText: 'CVC'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          validator: (v) {
                            final digits = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                            if (digits.length != 3) return 'Enter 3 digit CVC';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Name on Card'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter name';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Pay Now'),
                    ),
                  ),
                ],
              ),
            ),
                  const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
