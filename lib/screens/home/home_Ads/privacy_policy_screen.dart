import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  final String _privacyText = '''
Larry Enterprises Privacy Policy

Effective Date: August 2025

Welcome to Larry Enterprises (“we”, “our”, “us”). Your privacy is very important to us. This policy explains how we collect, use, and protect your personal data when you use our mobile app “LA” for online gas ordering.

1. Information We Collect
- Personal Information: Name, email, phone number, address.
- Payment Information: Details required to process payments securely.
- Usage Data: App usage and interaction data to improve service.

2. How We Use Your Information
- To provide and maintain our service.
- To process payments and manage your orders.
- To communicate important updates and offers.
- To comply with legal obligations.

3. Sharing Your Information
- We do not sell or rent your personal data.
- We may share data with trusted service providers assisting with app operations.
- We may disclose data as required by law.

4. Security
- We implement reasonable security measures to protect your data.
- However, no method is completely secure.

5. Your Choices
- You can update or delete your profile information anytime.
- You can opt out of promotional communications.

6. Contact Us
For questions about this Privacy Policy, please contact support@larryenterprises.co.ke.

Thank you for trusting Larry Enterprises.
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          _privacyText,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}
