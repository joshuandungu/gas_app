import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gas/models/user_model.dart';

class OrdersScreen extends StatefulWidget {
  final UserModel currentUser;

  const OrdersScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class CartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final UserModel currentUser;

  const CartScreen({Key? key, required this.cartItems, required this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ...
    return Container(); // Placeholder to avoid errors
  }
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool isLoading = true;
  bool isError = false;
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      // Replace with your actual backend base URL
      const String backendBase = "http://192.168.40.70:5000";

      final response = await http.get(
        Uri.parse('$backendBase/api/orders/${widget.currentUser.id}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          orders = data is List ? data : [];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? const Center(child: Text("Error loading orders."))
              : orders.isEmpty
                  ? const Center(child: Text("You have no orders yet."))
                  : RefreshIndicator(
                      onRefresh: fetchOrders,
                      child: ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                child: const Icon(Icons.shopping_bag,
                                    color: Colors.green),
                              ),
                              title: Text(
                                order['product_name'] ?? "Unknown Product",
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Quantity: ${order['quantity']}"),
                                  Text("Status: ${order['status']}"),
                                  if (order['vendor_name'] != null)
                                    Text("Vendor: ${order['vendor_name']}"),
                                ],
                              ),
                              trailing: Text(
                                "KSh ${order['total_price']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
