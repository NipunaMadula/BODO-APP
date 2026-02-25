import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bodo_app/repositories/user_review_repository.dart';

class RateUserScreen extends StatefulWidget {
  final String listingId;

  const RateUserScreen({required this.listingId, super.key});

  @override
  State<RateUserScreen> createState() => _RateUserScreenState();
}

class _RateUserScreenState extends State<RateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _commentController = TextEditingController();
  int _rating = 0;
  bool _isLoading = false;
  final _repo = UserReviewRepository();

  @override
  void dispose() {
    _emailController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Find target user by email
      final targetId = await _repo.getUserIdByEmail(_emailController.text.trim());
      if (targetId == null) throw 'No user found with that email';

      await _repo.addReview(
        targetUserId: targetId,
        reviewerId: currentUser.uid,
        reviewerName: currentUser.displayName ?? currentUser.email ?? 'Owner',
        rating: _rating,
        comment: _commentController.text.trim(),
        listingId: widget.listingId,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate a User')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'User Email'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email is required';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => IconButton(
                  icon: Icon(i < _rating ? Icons.star : Icons.star_border, color: Colors.amber),
                  onPressed: () => setState(() => _rating = i + 1),
                )),
              ),
              TextFormField(
                controller: _commentController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Comment (optional)'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Submit Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
