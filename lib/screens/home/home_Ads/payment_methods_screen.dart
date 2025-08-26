import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final Map<String, dynamic> order; // order details

  const PaymentMethodsScreen({
    super.key,
    required this.order,
  });

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool _isLoading = false;
  String? _responseMessage;

  Map<String, dynamic> get orderData => widget.order;

  @override
  void initState() {
    super.initState();
    // Pre-fill amount from order total
    final total = orderData['total'] ?? orderData['totalPrice'] ?? 0;
    _amountController.text = total.toString();
  }

  bool _isValidKenyaPhone(String phone) {
    final normalized = phone.replaceAll(' ', '');
    return RegExp(r'^(07\d{8}|(\+2547\d{8}))$').hasMatch(normalized);
  }

  Future<void> _startMpesaPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    final amount = _amountController.text.trim();

    setState(() {
      _isLoading = true;
      _responseMessage = null;
    });

    try {
      final url = Uri.parse('http://192.168.40.70:5000/api/mpesa/stkpush');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Bypass-Tunnel-Reminder': 'true',
        },
        body: jsonEncode({
          'phone': phone,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        // ✅ Mark order as paid in Firestore
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString())
            .set({...orderData, 'status': 'paid'}, SetOptions(merge: true));

        // ✅ Generate PDF receipt
        await _generatePdfReceipt();

        setState(() {
          _responseMessage =
              'Payment request sent! Check your phone to complete payment.';
        });
      } else {
        setState(() {
          _responseMessage = 'Payment failed: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Error sending payment: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generatePdfReceipt() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Payment Receipt",
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text("Order ID: ${orderData['id'] ?? 'N/A'}"),
                pw.Text(
                    "Customer: ${FirebaseAuth.instance.currentUser?.email ?? 'Guest'}"),
                pw.SizedBox(height: 10),
                pw.Text("Product: ${orderData['product']?['title'] ?? 'N/A'}"),
                pw.Text("Quantity: ${orderData['quantity']}"),
                pw.Text("Total: KES ${orderData['total']}"),
                pw.SizedBox(height: 10),
                pw.Text("Vendor: ${orderData['vendor']?['shopName'] ?? 'N/A'}"),
                pw.Text("Vendor Phone: ${orderData['vendor']?['phone'] ?? 'N/A'}"),
                pw.SizedBox(height: 20),
                pw.Text("Status: Paid",
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = orderData['product'] ?? {};
    final vendor = orderData['vendor'] ?? {};
    final total = orderData['total'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.green[700],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- ORDER SUMMARY CARD ----
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Order Summary",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product['image_url'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product['image_url'],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product['title'] ?? 'Gas Product',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text("Quantity: ${orderData['quantity']}"),
                            Text("Unit Price: KES ${product['price']}"),
                            Text("Total: KES $total",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text("Vendor: ${vendor['shopName'] ?? 'N/A'}"),
                  Text("Phone: ${vendor['phone'] ?? 'N/A'}"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ---- PAYMENT FORM ----
          const Text(
            'Pay with M-Pesa',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '07XXXXXXXX or +2547XXXXXXXX',
                    prefixIcon: Icon(Icons.phone_android),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (!_isValidKenyaPhone(value)) {
                      return 'Enter a valid Kenyan phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount (KES)',
                    prefixIcon: Icon(Icons.money),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount < 1) {
                      return 'Enter a valid amount (minimum 1 KES)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.payment),
                        label: const Text('Pay with M-Pesa'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 18),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: _startMpesaPayment,
                      ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (_responseMessage != null)
            Text(
              _responseMessage!,
              style: TextStyle(
                color: _responseMessage!.toLowerCase().contains('failed') ||
                        _responseMessage!.toLowerCase().contains('error')
                    ? Colors.red
                    : Colors.green[700],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
