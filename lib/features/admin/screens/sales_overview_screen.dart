import 'package:ecommerce_app_fluterr_nodejs/constants/global_variables.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/admin/services/admin_services.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/order.dart';
import 'package:flutter/material.dart';

class SalesOverviewScreen extends StatefulWidget {
  static const String routeName = '/admin-sales-overview';
  const SalesOverviewScreen({Key? key}) : super(key: key);

  @override
  State<SalesOverviewScreen> createState() => _SalesOverviewScreenState();
}

class _SalesOverviewScreenState extends State<SalesOverviewScreen> {
  List<Order> orders = [];
  bool isLoading = false;
  Map<String, Map<String, dynamic>> salesData = {};
  final AdminServices adminServices = AdminServices();

  @override
  void initState() {
    super.initState();
    fetchAllOrders();
  }

  Future<void> fetchAllOrders() async {
    setState(() => isLoading = true);
    try {
      orders = await adminServices.fetchAllOrders(context);
      aggregateSalesData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
    setState(() => isLoading = false);
  }

  void aggregateSalesData() {
    salesData.clear();
    for (var order in orders) {
      if (order.status == 3 && !order.cancelled) { // Assuming status 3 is delivered
        for (var product in order.products) {
          String sellerId = product.sellerId;
          double revenue = product.finalPrice * order.quantity[order.products.indexOf(product)];
          if (salesData.containsKey(sellerId)) {
            salesData[sellerId]!['revenue'] += revenue;
            salesData[sellerId]!['orders'] += 1;
          } else {
            salesData[sellerId] = {
              'revenue': revenue,
              'orders': 1,
              'shopName': product.shopName ?? 'Unknown Shop',
              'shopAvatar': product.shopAvatar ?? '',
            };
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Sales Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : salesData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No sales data available',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: salesData.length,
                        itemBuilder: (context, index) {
                          String sellerId = salesData.keys.elementAt(index);
                          var data = salesData[sellerId]!;
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: data['shopAvatar'].isNotEmpty
                                        ? NetworkImage(data['shopAvatar'])
                                        : null,
                                    child: data['shopAvatar'].isEmpty
                                        ? const Icon(Icons.store, size: 30)
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['shopName'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            _buildStatItem(
                                              Icons.attach_money,
                                              'Revenue',
                                              '\$${data['revenue'].toStringAsFixed(2)}',
                                              Colors.green,
                                            ),
                                            const SizedBox(width: 16),
                                            _buildStatItem(
                                              Icons.shopping_bag,
                                              'Orders',
                                              data['orders'].toString(),
                                              Colors.blue,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
