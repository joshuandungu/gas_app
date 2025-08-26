import 'package:flutter/material.dart';

class VendorRequestScreen extends StatelessWidget {
  const VendorRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Vendor'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'To become a vendor, please contact the admin for approval.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
