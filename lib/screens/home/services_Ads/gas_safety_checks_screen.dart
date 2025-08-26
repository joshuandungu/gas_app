import 'package:flutter/material.dart';
import 'package:gas/services/api_service.dart';
import 'package:gas/providers/auth_provider.dart';
import 'package:gas/models/user_model.dart';
import 'package:provider/provider.dart';

class GasSafetyChecksScreen extends StatefulWidget {
  const GasSafetyChecksScreen({super.key});

  @override
  State<GasSafetyChecksScreen> createState() => _GasSafetyCheckScreenState();
}

class _GasSafetyCheckScreenState extends State<GasSafetyChecksScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isSubmitting = false;

  void _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulate a network call delay
      await Future.delayed(const Duration(seconds: 2));

      // Get current user from AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user;

      if (currentUser != null) {
        // Create notification data
        final notificationData = {
          'user_id': currentUser.id,
          'title': 'Gas Safety Check Booked',
          'body': 'A gas safety check has been booked for ${currentUser.fullName} at ${_addressController.text.trim()}.',
        };
        // Send notification to backend
        await ApiService.post('notifications', notificationData);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Safety check appointment booked successfully!')),
      );

      _fullNameController.clear();
      _phoneController.clear();
      _addressController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book safety check: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gas Safety Check'),
        backgroundColor: const Color(0xFF00C853),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.security,
              size: 80,
              color: Color(0xFF00C853),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ensure Your Safety',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Our certified technicians will inspect your gas installations and equipment '
              'to ensure everything is safe and functioning properly. Book a safety check appointment today.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Full Name',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your full name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Phone Number',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Enter your phone number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (!RegExp(r'^\+?254\d{9}$').hasMatch(value)) {
                        return 'Enter a valid Kenyan phone number starting with +254';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Address',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Enter the address for the safety check',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                            )
                          : const Text(
                              'Book Safety Check',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
