
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gas/providers/vendor_provider.dart';

class VendorOrders extends StatefulWidget {
  const VendorOrders({super.key});

  @override
  _VendorOrdersState createState() => _VendorOrdersState();
}

class _VendorOrdersState extends State<VendorOrders> {
  @override
  void initState() {
    super.initState();
    // Fetch orders when the screen loads
    Provider.of<VendorProvider>(context, listen: false).fetchReceivedOrders('v1'); // Replace with actual vendor ID
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Received Orders'),
      ),
      body: Consumer<VendorProvider>(
        builder: (context, provider, child) {
          if (provider.receivedOrders.isEmpty) {
            return Center(child: Text('You have no orders yet.'));
          }
          return ListView.builder(
            itemCount: provider.receivedOrders.length,
            itemBuilder: (context, index) {
              final order = provider.receivedOrders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListTile(
                  title: Text('Order ID: ${order.id}'),
                  subtitle: Text('Status: ${order.status}'),
                  trailing: Text('\$${order.totalPrice.toStringAsFixed(2)}'),
                  onTap: () {
                    // Can add functionality to view order details
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
