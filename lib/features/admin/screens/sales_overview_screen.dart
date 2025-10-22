import 'package:ecommerce_app_fluterr_nodejs/constants/global_variables.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/admin/services/admin_services.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  // Filter variables
  String selectedCategory = 'All Categories';
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    fetchSalesOverview();
  }

  Future<void> fetchSalesOverview() async {
    setState(() => isLoading = true);
    try {
      List<Map<String, dynamic>> data = await adminServices.getSalesOverview(
        context: context,
        startDate: startDate?.millisecondsSinceEpoch,
        endDate: endDate?.millisecondsSinceEpoch,
        category: selectedCategory,
      );

      salesData.clear();
      for (var item in data) {
        String sellerId = item['_id'];
        salesData[sellerId] = {
          'revenue': item['revenue']?.toDouble() ?? 0.0,
          'orders': item['orders'] ?? 0,
          'shopName': item['shopName'] ?? 'Unknown Shop',
          'shopAvatar': item['shopAvatar'] ?? '',
        };
      }
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
      if (order.status == 3 && !order.cancelled) {
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

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      fetchSalesOverview();
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
                ),
              ],
            ),
            child: Column(
              children: [
                // Filters Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          'All Categories',
                          ...GlobalVariables.categoryImages.map((e) => e['title'] as String)
                        ].map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategory = newValue!;
                          });
                          fetchSalesOverview();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _selectDateRange(context),
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          startDate != null && endDate != null
                              ? '${DateFormat('MMM dd').format(startDate!)} - ${DateFormat('MMM dd').format(endDate!)}'
                              : 'Select Date Range',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Summary Stats
                Row(
                  children: [
                    _buildSummaryStat(
                      Icons.attach_money,
                      'Total Revenue',
                      '\$${salesData.values.fold(0.0, (sum, data) => sum + data['revenue']).toStringAsFixed(2)}',
                      Colors.green,
                    ),
                    const SizedBox(width: 16),
                    _buildSummaryStat(
                      Icons.shopping_bag,
                      'Total Orders',
                      '${salesData.values.fold<int>(0, (sum, data) => sum + (data['orders'] as num).toInt())}',
                      Colors.blue,
                    ),
                    const SizedBox(width: 16),
                    _buildSummaryStat(
                      Icons.store,
                      'Total Sellers',
                      '${salesData.length}',
                      Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : salesData.isEmpty
                    ? const Center(child: Text('No sales data available'))
                    : ListView.builder(
                        itemCount: salesData.length,
                        itemBuilder: (context, index) {
                          String sellerId = salesData.keys.elementAt(index);
                          Map<String, dynamic> data = salesData[sellerId]!;
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: data['shopAvatar'].isNotEmpty
                                    ? NetworkImage(data['shopAvatar'])
                                    : null,
                                child: data['shopAvatar'].isEmpty
                                    ? const Icon(Icons.store)
                                    : null,
                              ),
                              title: Text(
                                data['shopName'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Orders: ${data['orders']}'),
                                  Text('Revenue: \$${data['revenue'].toStringAsFixed(2)}'),
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

  Widget _buildSummaryStat(IconData icon, String label, String value, Color color) {
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
