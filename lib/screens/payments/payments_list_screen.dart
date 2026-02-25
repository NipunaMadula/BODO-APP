import 'package:flutter/material.dart';
import 'package:bodo_app/repositories/payment_repository.dart';
import 'package:bodo_app/models/payment_model.dart';
import 'package:intl/intl.dart';

class PaymentsListScreen extends StatelessWidget {
  final String listingId;

  const PaymentsListScreen({required this.listingId, super.key});

  @override
  Widget build(BuildContext context) {
    final repo = PaymentRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: StreamBuilder<List<PaymentModel>>(
        stream: repo.getPaymentsForListing(listingId),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final payments = snapshot.data ?? [];
          if (payments.isEmpty) return const Center(child: Text('No payments yet'));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final p = payments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text('${p.payerName} — Rs.${p.amount}'),
                  subtitle: Text('${p.method} • ${p.status}'),
                  trailing: Text(DateFormat('MMM d').format(p.createdAt)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
