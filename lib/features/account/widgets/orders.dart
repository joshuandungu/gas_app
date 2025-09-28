import 'package:ecommerce_app_fluterr_nodejs/features/account/services/account_services.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/widgets/single_product.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/order_details/screens/order_details_screens.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/order.dart';
import 'package:flutter/material.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  late Future<List<Order>?> _ordersFuture;
  final AccountServices _accountServices = AccountServices();

  @override
  void initState() {
    super.initState();
    _ordersFuture = _accountServices.fetchOrders(context);
  }

  Future<void> _refreshOrders() async {
    setState(() {
      // Trigger a new fetch by assigning a new Future
      _ordersFuture = _accountServices.fetchOrders(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Order>?>(
      future: _ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 120, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  'Oops! Something went wrong',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[400]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Failed to load your orders. Please try again.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshOrders,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        final orderList = snapshot.data!;

        if (orderList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 120, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No Orders Yet!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your orders will appear here',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshOrders,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: orderList.length,
                itemBuilder: (context, index) {
                  final order = orderList[index];
                  // Check if products list is not empty before accessing
                  if (order.products.isEmpty ||
                      order.products[0].images.isEmpty) {
                    return const Card(
                        child: Center(child: Icon(Icons.broken_image)));
                  }
                  return InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        OrderDetailsScreens.routeName,
                        arguments: order,
                      );
                    },
                    child: SingleProduct(
                      image: order.products[0].images[0],
                    ),
                  );
                }),
          ),
        );
      },
    );
  }
}
