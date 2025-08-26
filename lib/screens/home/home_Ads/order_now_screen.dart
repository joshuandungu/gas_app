import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gas/screens/home/home_Ads/payment_methods_screen.dart';
import 'package:gas/models/user_model.dart';

// ✅ define backend base
const String BACKEND_BASE = "http://192.168.40.70:5000";

class OrderNowScreen extends StatefulWidget {
  final UserModel currentUser;
  final Map<String, dynamic> product;
  final String productType;

  const OrderNowScreen({
    Key? key,
    required this.currentUser,
    required this.product,
    required this.productType,
  }) : super(key: key);

  @override
  State<OrderNowScreen> createState() => _OrderNowScreenState();
}

class _OrderNowScreenState extends State<OrderNowScreen> {
  Map<String, dynamic>? _vendor;
  bool _loading = true;
  int _quantity = 1;
  final TextEditingController _deliveryAddressController = TextEditingController();
  final TextEditingController _specialInstructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchVendorInfo();
    if (widget.currentUser.address != null && widget.currentUser.address!.isNotEmpty) {
      _deliveryAddressController.text = widget.currentUser.address!;
    }
  }

  Future<void> _fetchVendorInfo() async {
    try {
      final vendorId = widget.product['vendorId'] ??
          widget.product['vendor_id'] ??
          widget.product['userId'] ??
          widget.product['user_id'];

      if (vendorId != null) {
        final vendorDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(vendorId.toString())
            .get();

        if (vendorDoc.exists && vendorDoc.data() != null) {
          setState(() => _vendor = vendorDoc.data());
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching vendor info: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ✅ SAFE total price calculation
  double get _totalPrice {
    final dynamic rawPrice = widget.product['price'];
    double price = 0.0;

    if (rawPrice is int) {
      price = rawPrice.toDouble();
    } else if (rawPrice is double) {
      price = rawPrice;
    } else if (rawPrice is String) {
      price = double.tryParse(rawPrice) ?? 0.0;
    }

    return price * _quantity;
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _goToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodsScreen(
          order: {
            "product": widget.product,
            "quantity": _quantity,
            "total": _totalPrice,
            "vendor": _vendor,
            "deliveryAddress": _deliveryAddressController.text,
            "specialInstructions": _specialInstructionsController.text,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.product['image_url']?.toString() ?? "";

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Order Summary"),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _goToPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
            ),
            child: const Text(
              "Proceed to Payment",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Product Card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageUrl.isNotEmpty)
                          Image.network(
                            imageUrl.startsWith('http')
                                ? imageUrl
                                : '$BACKEND_BASE/$imageUrl',
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(height: 200, color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle("Product Details", Icons.local_gas_station),
                              const SizedBox(height: 8),
                              Text(
                                widget.product['title'] ?? 'Gas Product',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              if (widget.product['description'] != null)
                                Text(
                                  widget.product['description'].toString(),
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("KSh ${_totalPrice.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green)),
                                  Text("Type: ${widget.productType}",
                                      style: const TextStyle(fontStyle: FontStyle.italic)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Vendor Card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle("Vendor Details", Icons.storefront),
                          const SizedBox(height: 12),
                          Text("Shop: ${_vendor?['shopName'] ?? 'N/A'}"),
                          Text("Vendor: ${_vendor?['fullName'] ?? 'Unknown'}"),
                          Text("Phone: ${_vendor?['phone'] ?? 'N/A'}"),
                          Text("Email: ${_vendor?['email'] ?? 'N/A'}"),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Quantity + Total
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle("Quantity", Icons.shopping_cart),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                                    onPressed: () {
                                      if (_quantity > 1) setState(() => _quantity--);
                                    },
                                  ),
                                  Text("$_quantity",
                                      style: const TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle, color: Colors.green),
                                    onPressed: () => setState(() => _quantity++),
                                  ),
                                ],
                              ),
                              Text("Total: KSh ${_totalPrice.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Delivery Address
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle("Delivery Address", Icons.location_on),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _deliveryAddressController,
                            decoration: InputDecoration(
                              hintText: "Enter delivery address",
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Special Instructions
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle("Special Instructions", Icons.notes),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _specialInstructionsController,
                            decoration: InputDecoration(
                              hintText: "Any special delivery instructions?",
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}
