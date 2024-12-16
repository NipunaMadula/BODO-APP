import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFAQSection(),
          const SizedBox(height: 24),
          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildFAQItem(
          'How do I post a listing?',
          'To post a listing, tap the + button in the bottom navigation bar and fill in the required details about your property.',
        ),
        _buildFAQItem(
          'How can I edit my listing?',
          'Go to "My Properties" in your profile, find the listing you want to edit, tap the menu icon, and select "Edit".',
        ),
        _buildFAQItem(
          'How do I contact property owners?',
          'When viewing a listing, tap the "Contact Owner" button to see available contact options.',
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(answer),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Need More Help?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            Icons.email_outlined,
            'Email Support',
            'support@bodoapp.com',
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            Icons.phone_outlined,
            'Phone Support',
            '1-800-BODO-HELP',
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String detail) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              detail,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }
}