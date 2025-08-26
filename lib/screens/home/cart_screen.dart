import 'package:flutter/material.dart';
import 'package:gas/models/user_model.dart';
import 'package:gas/screens/home/home_Ads/order_now_screen.dart';

class CartScreen extends StatelessWidget {
  final Color primaryColor = const Color(0xFF00C853);
  final UserModel currentUser; // ✅ passed from MainScreen
  final List<Map<String, dynamic>> items; // ✅ passed from MainScreen

  const CartScreen({
    Key? key,
    required this.currentUser,
    required this.items,
  }) : super(key: key);

  // --- Helpers: safely coerce dynamic values ---
  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) {
      // Remove currency, commas, spaces, etc. Keep digits, dot, minus.
      final cleaned = v.replaceAll(RegExp(r'[^0-9\.\-]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  int _toInt(dynamic v, {int fallback = 1}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) {
      final cleaned = v.replaceAll(RegExp(r'[^0-9\-]'), '');
      return int.tryParse(cleaned) ?? fallback;
    }
    return fallback;
  }

  String _pickTitle(Map<String, dynamic> item) {
    return (item['title'] ??
            item['name'] ??
            item['product_name'] ??
            'Product')
        .toString();
  }

  String _pickImage(Map<String, dynamic> item) {
    final candidates = [
      item['image_url'],
      item['imageUrl'],
      item['image'],
      item['thumbnail'],
      item['thumb'],
    ];

    for (final c in candidates) {
      if (c is String && c.isNotEmpty && (c.startsWith('http://') || c.startsWith('https://'))) {
        return c;
      }
    }
    // If you need to support relative paths, prepend your backend base here.
    return 'https://via.placeholder.com/100';
  }

  String _pickProductType(Map<String, dynamic> item) {
    return (item['product_type'] ??
            item['category'] ??
            item['type'] ??
            'Gas')
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = items;

    final totalPrice = cartItems.fold<double>(
      0.0,
      (sum, item) => sum + _toDouble(item['price']) * _toInt(item['quantity']),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "🛒 Your cart is empty",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final productName = _pickTitle(item);
                      final productPrice = _toDouble(item['price']);
                      final productImage = _pickImage(item);
                      final quantity = _toInt(item['quantity']);

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: Image.network(
                            productImage,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                          title: Text(productName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Ksh ${productPrice.toStringAsFixed(2)}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text("Quantity: $quantity"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ✅ Total Price Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Ksh ${totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ Checkout Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () {
                        if (cartItems.isNotEmpty) {
                          final productType = _pickProductType(cartItems[0]);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderNowScreen(
                                currentUser: currentUser,
                                product: cartItems[0],
                                productType: productType,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("No items in cart."),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Proceed to Checkout",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
