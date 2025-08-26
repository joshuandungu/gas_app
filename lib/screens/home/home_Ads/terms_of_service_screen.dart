import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  final String _termsText = '''
Larry Enterprises Terms of Service

Effective Date: August 2025

Welcome to Larry Enterprises (“we”, “our”, “us”). By using our mobile app “LA” for online gas ordering, you agree to the following terms:

1. Acceptance of Terms
By accessing and using our app, you agree to comply with these Terms of Service.

2. User Responsibilities
- Provide accurate and truthful information when registering and ordering.
- Use the app for lawful purposes only.
- Respect intellectual property rights.

3. Ordering and Payment
- Orders are subject to availability.
- Payment must be made using the available payment methods.
- We reserve the right to cancel or refuse orders if necessary.

4. Vendor Approval and Privileges
- Users applying as vendors require admin approval.
- Vendors can post gas listings and manage their sales after approval.
- Withdrawal of funds is subject to admin authorization.

5. Limitation of Liability
- We are not liable for any damages arising from use of the app.
- We do not guarantee uninterrupted service.

6. Privacy
- Your data is handled according to our Privacy Policy.

7. Changes to Terms
- We may update these terms at any time; changes will be notified via the app.

8. Contact
For questions, contact support@larryenterprises.co.ke.

Thank you for using Larry Enterprises.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          _termsText,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}
