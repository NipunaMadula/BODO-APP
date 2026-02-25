import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bodo_app/repositories/payment_repository.dart';
import 'package:bodo_app/models/payment_model.dart';

class OwnerPaymentsScreen extends StatelessWidget {
  const OwnerPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view payments')),
      );
    }

    final repo = PaymentRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('Received Payments')),
      body: StreamBuilder<List<PaymentModel>>(
        stream: repo.getPaymentsForOwner(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final payments = snapshot.data ?? [];
          if (payments.isEmpty) return const Center(child: Text('No payments received yet'));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final p = payments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text('${p.payerName} — Rs.${p.amount.toStringAsFixed(2)}'),
                  subtitle: Text('${p.method} • ${p.status} • Listing: ${p.listingId}'),
                  trailing: Text(DateFormat('MMM d, hh:mm a').format(p.createdAt)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
