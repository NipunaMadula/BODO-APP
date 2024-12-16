import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Information We Collect',
            'We collect information you provide directly to us, including name, email address, phone number, and property details when you create listings.',
          ),
          _buildSection(
            'How We Use Your Information',
            'We use the information we collect to provide, maintain, and improve our services, communicate with you, and ensure platform security.',
          ),
          _buildSection(
            'Information Sharing',
            'We do not sell or rent your personal information. We share information only as described in this policy or with your consent.',
          ),
          _buildSection(
            'Data Security',
            'We implement appropriate security measures to protect your personal information from unauthorized access or disclosure.',
          ),
          _buildSection(
            'Your Rights',
            'You have the right to access, correct, or delete your personal information. Contact us to exercise these rights.',
          ),
          const SizedBox(height: 24),
          Text(
            'Last updated: ${DateTime.now().year}',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}