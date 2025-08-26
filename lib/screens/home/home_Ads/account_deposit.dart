import 'package:flutter/material.dart';
import 'package:gas/services/api_service.dart';
import 'package:gas/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AccountDepositScreen extends StatefulWidget {
  const AccountDepositScreen({super.key});

  @override
  State<AccountDepositScreen> createState() => _AccountDepositScreenState();
}

class _AccountDepositScreenState extends State<AccountDepositScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _initiateMpesaDeposit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    // In a real app, here you’d call your backend API
    // to initiate M-Pesa STK Push via Safaricom Daraja API.
    await Future.delayed(const Duration(seconds: 2));

    // Get current user from AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;

    if (currentUser != null) {
      // Create notification data
      final notificationData = {
        'user_id': currentUser.id,
        'title': 'M-Pesa Deposit Initiated',
        'body': 'A deposit of KES ${_amountController.text.trim()} has been initiated.',
      };
      // Send notification to backend
      await ApiService.post('notifications', notificationData);
    }

    setState(() {
      _isProcessing = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'M-Pesa payment request sent. Please check your phone to complete the transaction.',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Deposit'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instructions
              const Text(
                'Deposit to Your Account via M-Pesa',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter the amount you wish to deposit and your Safaricom M-Pesa number. '
                'You will receive an STK Push prompt to authorize the payment.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Amount input
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (KES)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 50) {
                    return 'Minimum deposit is KES 50';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Phone number input
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'M-Pesa Phone Number (e.g., 254712345678)',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your M-Pesa phone number';
                  }
                  if (!RegExp(r'^2547\d{8}$').hasMatch(value)) {
                    return 'Enter a valid Safaricom number (2547XXXXXXXX)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Deposit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _initiateMpesaDeposit,
                  icon: const Icon(Icons.payments_outlined),
                  label: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Deposit via M-Pesa'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
