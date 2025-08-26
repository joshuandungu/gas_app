import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WithdrawFundsScreen extends StatefulWidget {
  const WithdrawFundsScreen({Key? key}) : super(key: key);

  @override
  State<WithdrawFundsScreen> createState() => _WithdrawFundsScreenState();
}

class _WithdrawFundsScreenState extends State<WithdrawFundsScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountDetailsController =
      TextEditingController();
  String _selectedMethod = 'M-Pesa';
  double _balance = 0.0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchVendorBalance();
  }

  Future<void> _fetchVendorBalance() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          _balance = (snapshot.data()?['balance'] ?? 0).toDouble();
        });
      }
    } catch (e) {
      debugPrint('Error fetching balance: $e');
    }
  }

  Future<void> _submitWithdrawal() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final accountDetails = _accountDetailsController.text.trim();

    if (amount <= 0) {
      _showSnackBar("Please enter a valid amount.");
      return;
    }

    if (amount > _balance) {
      _showSnackBar("Withdrawal amount exceeds your balance.");
      return;
    }

    if (accountDetails.isEmpty) {
      _showSnackBar("Please enter account details.");
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance.collection('withdrawals').add({
        'vendorId': uid,
        'amount': amount,
        'method': _selectedMethod,
        'accountDetails': accountDetails,
        'status': 'pending', // admin will update to approved/declined
        'requestedAt': FieldValue.serverTimestamp(),
      });

      // Update vendor balance
      await FirebaseFirestore.instance.collection('vendors').doc(uid).update({
        'balance': _balance - amount,
      });

      setState(() {
        _balance -= amount;
        _amountController.clear();
        _accountDetailsController.clear();
        _loading = false;
      });

      _showSnackBar("Withdrawal request submitted successfully.");
    } catch (e) {
      setState(() => _loading = false);
      _showSnackBar("Error: ${e.toString()}");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildAccountDetailsField() {
    String label = '';
    switch (_selectedMethod) {
      case 'M-Pesa':
        label = 'M-Pesa Phone Number';
        break;
      case 'Bank Transfer':
        label = 'Bank Account Number';
        break;
      case 'PayPal':
        label = 'PayPal Email';
        break;
    }
    return TextField(
      controller: _accountDetailsController,
      decoration: InputDecoration(labelText: label),
      keyboardType:
          _selectedMethod == 'M-Pesa' ? TextInputType.phone : TextInputType.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw Funds'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Current Balance: Ksh $_balance",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Withdrawal Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _selectedMethod,
              items: const [
                DropdownMenuItem(value: 'M-Pesa', child: Text('M-Pesa')),
                DropdownMenuItem(
                    value: 'Bank Transfer', child: Text('Bank Transfer')),
                DropdownMenuItem(value: 'PayPal', child: Text('PayPal')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Withdrawal Method'),
            ),
            const SizedBox(height: 20),

            _buildAccountDetailsField(),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submitWithdrawal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Request Withdrawal",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
