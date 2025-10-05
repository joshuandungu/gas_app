import 'package:ecommerce_app_fluterr_nodejs/constants/global_variables.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/admin/services/admin_services.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminOrdersScreen extends StatefulWidget {
  static const String routeName = '/admin-orders';
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List<Order>? orders;
  final AdminServices adminServices = AdminServices();

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  void fetchOrders() async {
    orders = await adminServices.fetchAllOrders(context);
    setState(() {});
  }

  void changeOrderStatus(Order order, int status) async {
    adminServices.changeOrderStatus(context: context, id: order.id!, status: status);
    fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
          title: const Text(
            'All Orders',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: orders == null
          ? const Center(child: CircularProgressIndicator())
          : orders!.isEmpty
              ? const Center(child: Text('No orders found'))
              : ListView.builder(
                  itemCount: orders!.length,
                  itemBuilder: (context, index) {
                    final order = orders![index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text('Order ID: ${order.id}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total: \$${order.totalPrice}'),
                            Text('Status: ${getStatusText(order.status)}'),
                            Text('Ordered At: ${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(order.orderedAt))}'),
                          ],
                        ),
                        trailing: PopupMenuButton<int>(
                          onSelected: (status) => changeOrderStatus(order, status),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 0, child: Text('Pending')),
                            const PopupMenuItem(value: 1, child: Text('Shipped')),
                            const PopupMenuItem(value: 2, child: Text('Out for Delivery')),
                            const PopupMenuItem(value: 3, child: Text('Delivered')),
                            const PopupMenuItem(value: 4, child: Text('Cancelled')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Shipped';
      case 2:
        return 'Out for Delivery';
      case 3:
        return 'Delivered';
      case 4:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
}
