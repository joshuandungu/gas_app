import 'dart:convert';
import 'package:ecommerce_app_fluterr_nodejs/common/widgets/bottom_bar.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/error_handling.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/global_variables.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/utils.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/order_details/screens/order_details_screens.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/order.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/product.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/user.dart';
import 'package:ecommerce_app_fluterr_nodejs/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AddressServices {
  void saveUserAddress({
    required BuildContext context,
    required String address,
    required String phoneNumber,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/save-user-address'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'address': address,
          'phoneNumber': phoneNumber,
        }),
      );
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          final data = jsonDecode(res.body);
          User user = userProvider.user.copyWith(
            address: data['address'],
            phoneNumber: data['phoneNumber'],
          );
          userProvider.setUserFromModel(user);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // place order from cart
  void placeOrder({
    required BuildContext context,
    required String address,
    required double totalSum,
    required List<int> selectedItems,
    required String phoneNumber,
    String paymentMethod = 'COD', // Default Cash on Delivery
    Function(Order)? onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      final selectedCart = selectedItems.map((index) {
        // The cart item is already in the correct format { 'product': ..., 'quantity': ... }
        return userProvider.user.cart[index];
      }).toList();
      http.Response res = await http.post(
        Uri.parse('$uri/api/order'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'cart': selectedCart,
          'totalPrice': totalSum,
          'address': address,
          'paymentMethod': paymentMethod,
          'phoneNumber': phoneNumber,
        }),
      );

      if (!context.mounted) return;

      _handleOrderSuccess(res, context, paymentMethod, phoneNumber, totalSum,
          onSuccess: onSuccess, onCodSuccess: () {
        _clearCart(context, selectedItems);
      });
    } catch (e) {
      if (context.mounted) showSnackBar(context, e.toString());
    }
  }

  // direct order (without cart)
  void placeDirectOrder({
    required BuildContext context,
    required String address,
    required double totalSum,
    required List<Product> products,
    required List<int> quantities,
    required String phoneNumber,
    String paymentMethod = 'COD',
    Function(Order)? onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/order-direct'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'products': products.map((e) => e.toMap()).toList(),
          'quantities': quantities,
          'totalPrice': totalSum,
          'address': address,
          'paymentMethod': paymentMethod,
          'phoneNumber': phoneNumber,
        }),
      );

      if (!context.mounted) return;

      _handleOrderSuccess(res, context, paymentMethod, phoneNumber, totalSum,
          onSuccess: onSuccess, onCodSuccess: () {
        Navigator.pop(context); // Assuming this is from a "Buy Now" flow
      });
    } catch (e) {
      if (context.mounted) showSnackBar(context, e.toString());
    }
  }

  // Helper to handle success logic for both order types
  void _handleOrderSuccess(
    http.Response res,
    BuildContext context,
    String paymentMethod,
    String phoneNumber,
    double totalSum, {
    Function(Order)? onSuccess,
    VoidCallback? onCodSuccess,
  }) {
    httpErrorHandle(
      response: res,
      context: context,
      onSuccess: () {
        final order = Order.fromJson(res.body);

        if (paymentMethod == 'M-Pesa') {
          // For M-Pesa, trigger the callback to start the payment flow.
          onSuccess?.call(order);
        } else {
          // Handle COD and other future payment methods
          showSnackBar(context, "Your order has been placed!");
          onCodSuccess?.call();
          Navigator.pushReplacementNamed(context, OrderDetailsScreens.routeName,
              arguments: order);
        }
      },
    );
  }

  // M-Pesa STK Push + Polling
  void initiateMpesaPayment({
    required BuildContext context,
    required String orderId,
    required String phoneNumber,
    required double amount,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Validate phone number format
    const phoneRegex = r'^(\+254|254|0)([17]\d{8}|[2-9]\d{8})$';
    if (!RegExp(phoneRegex).hasMatch(phoneNumber)) {
      showSnackBar(context,
          'Invalid M-Pesa phone number format. Please use format: 07XXXXXXXX or +254XXXXXXXXX');
      return;
    }

    // Validate amount
    if (amount < 1 || amount > 150000) {
      showSnackBar(context, 'Amount must be between KES 1 and 150,000');
      return;
    }

    try {
      // Show detailed loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Initiating M-Pesa payment...',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Please wait while we connect to M-Pesa',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      http.Response res = await http.post(
        Uri.parse('$uri/api/mpesa/stk-push'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'orderId': orderId,
          'phoneNumber': phoneNumber,
          'amount': amount,
        }),
      );

      if (context.mounted) Navigator.pop(context); // dismiss loading

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // Show success dialog with instructions
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('M-Pesa Payment Initiated'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.phone_android,
                    size: 48,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'STK push sent to $phoneNumber',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please check your phone and enter your M-Pesa PIN to complete the payment.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Do not close this app while payment is processing.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // 🔄 Start polling payment status
                    pollPaymentStatus(context, orderId);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (context.mounted)
        Navigator.pop(context); // dismiss loading dialog if still open
      showSnackBar(context, 'Failed to initiate payment: ${e.toString()}');
    }
  }

  // Poll order status every few seconds
  Future<void> pollPaymentStatus(BuildContext context, String orderId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    const int maxAttempts = 20; // ~60 seconds (3 seconds * 20)
    int attempts = 0;

    // Show polling dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Waiting for payment confirmation...',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Please complete the payment on your phone',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 3));
      attempts++;

      try {
        final res = await http.get(
          Uri.parse('$uri/api/mpesa/orders/$orderId'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': userProvider.user.token,
          },
        );

        if (!context.mounted) return;
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final status = data?['paymentStatus'];

          if (status == 'paid' && data != null) {
            if (context.mounted)
              Navigator.pop(context); // dismiss polling dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Payment Successful!'),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 48,
                      color: Colors.green,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Your payment has been confirmed.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (context.mounted) Navigator.pop(context);
                      Navigator.pushReplacementNamed(
                        context,
                        OrderDetailsScreens.routeName,
                        arguments: Order.fromMap(data as Map<String, dynamic>),
                      );
                    },
                    child: const Text('View Order'),
                  ),
                ],
              ),
            );
            return;
          } else if (status == 'failed' && data != null) {
            if (context.mounted)
              Navigator.pop(context); // dismiss polling dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Payment Failed'),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error,
                      size: 48,
                      color: Colors.red,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Your payment could not be processed.',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please try again or contact support.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (context.mounted) Navigator.pop(context);
                      Navigator.pushReplacementNamed(
                        context,
                        OrderDetailsScreens.routeName,
                        arguments: Order.fromMap(data as Map<String, dynamic>),
                      );
                    },
                    child: const Text('View Order'),
                  ),
                ],
              ),
            );
            return;
          }
        } else {
          // Handle non-200 responses
          print('Polling failed with status: ${res.statusCode}');
        }
      } catch (e) {
        print('Polling error: $e');
      }
    }

    // Timeout - dismiss polling dialog and show timeout message
    if (context.mounted) Navigator.pop(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Timeout'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 48,
              color: Colors.orange,
            ),
            SizedBox(height: 16),
            Text(
              'Payment confirmation is taking longer than expected.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Please check your order details or contact support.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (context.mounted) {
                Navigator.pop(context); // Close the timeout dialog
                // Fetch the full order details before navigating to avoid partial data issues.
                _fetchOrderAndNavigate(context, orderId);
              }
            },
            child: const Text('Check Status'),
          ),
        ],
      ),
    );
  }

  // Helper to fetch full order details and navigate.
  Future<void> _fetchOrderAndNavigate(
      BuildContext context, String orderId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      final res = await http.get(
        Uri.parse('$uri/api/orders/$orderId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );
      if (context.mounted) {
        httpErrorHandle(
            response: res,
            context: context,
            onSuccess: () {
              final order = Order.fromJson(res.body);
              Navigator.pushReplacementNamed(
                  context, OrderDetailsScreens.routeName,
                  arguments: order);
            });
      }
    } catch (e) {
      if (context.mounted) showSnackBar(context, e.toString());
    }
  }

  // helper to clear cart after order
  void _clearCart(BuildContext context, List<int> selectedItems) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final updatedCart = List.from(userProvider.user.cart);

    final sortedIndexes = selectedItems.toList()
      ..sort((a, b) => b.compareTo(a));
    for (var index in sortedIndexes) {
      updatedCart.removeAt(index);
    }

    User user = userProvider.user.copyWith(
      cart: updatedCart,
      phoneNumber: null,
    );
    userProvider.setUserFromModel(user);
  }

  // Get seller address by sellerId
  Future<String> getSellerAddress({
    required BuildContext context,
    required String sellerId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/seller/address/$sellerId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['address'];
      } else {
        throw Exception('Failed to fetch seller address');
      }
    } catch (e) {
      showSnackBar(context, e.toString());
      rethrow;
    }
  }

  // Get addresses of all sellers in cart
  Future<List<String>> getSellerAddresses(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/seller/addresses/cart'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        return data.map((e) => e as String).toList();
      } else {
        throw Exception('Failed to fetch seller addresses');
      }
    } catch (e) {
      showSnackBar(context, e.toString());
      rethrow;
    }
  }
}
