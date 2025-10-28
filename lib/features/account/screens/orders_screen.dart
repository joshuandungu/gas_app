import 'package:ecommerce_app_fluterr_nodejs/features/account/widgets/orders.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/widgets/top_button.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  static const String routeName = '/orders';
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      body: const Column(
        children: [
          TopButton(),
          Expanded(child: Orders()),
        ],
      ),
    );
  }
}
