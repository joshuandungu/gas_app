import 'package:ecommerce_app_fluterr_nodejs/constants/global_variables.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/admin/services/admin_services.dart';
import 'package:flutter/material.dart';

class RevenueSummaryScreen extends StatefulWidget {
  static const String routeName = '/admin-revenue-summary';
  const RevenueSummaryScreen({Key? key}) : super(key: key);

  @override
  State<RevenueSummaryScreen> createState() => _RevenueSummaryScreenState();
}

class _RevenueSummaryScreenState extends State<RevenueSummaryScreen> {
  Map<String, dynamic> summaryData = {};
  bool isLoading = false;
  final AdminServices adminServices = AdminServices();

  @override
  void initState() {
    super.initState();
    fetchRevenueSummary();
  }

  Future<void> fetchRevenueSummary() async {
    setState(() => isLoading = true);
    try {
      Map<String, dynamic> data = await adminServices.getRevenueSummary(context: context);
      setState(() {
        summaryData = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    double totalRevenue = summaryData['totalRevenue']?.toDouble() ?? 0.0;
    List<dynamic> vendors = summaryData['vendors'] ?? [];

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
                // Summary Stats
                Row(
                  children: [
                    _buildSummaryStat(
                      Icons.attach_money,
                      'Total Revenue',
                      '\$${totalRevenue.toStringAsFixed(2)}',
                      Colors.green,
                    ),
                    const SizedBox(width: 16),
                    _buildSummaryStat(
                      Icons.store,
                      'Total Vendors',
                      '${vendors.length}',
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
                : vendors.isEmpty
                    ? const Center(child: Text('No revenue data available'))
                    : ListView.builder(
                        itemCount: vendors.length,
                        itemBuilder: (context, index) {
                          var vendor = vendors[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: vendor['shopAvatar']?.isNotEmpty == true
                                    ? NetworkImage(vendor['shopAvatar'])
                                    : null,
                                child: vendor['shopAvatar']?.isEmpty == true
                                    ? const Icon(Icons.store)
                                    : null,
                              ),
                              title: Text(
                                vendor['shopName'] ?? 'Unknown Shop',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Orders: ${vendor['orders'] ?? 0}'),
                                  Text('Revenue: \$${vendor['revenue']?.toStringAsFixed(2) ?? '0.00'}'),
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
