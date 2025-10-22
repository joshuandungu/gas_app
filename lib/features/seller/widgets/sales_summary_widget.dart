import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/services/seller_services.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/order.dart';

class SalesSummaryWidget extends StatefulWidget {
  const SalesSummaryWidget({Key? key}) : super(key: key);

  @override
  State<SalesSummaryWidget> createState() => _SalesSummaryWidgetState();
}

class _SalesSummaryWidgetState extends State<SalesSummaryWidget> {
  final SellerServices _sellerServices = SellerServices();
  List<Order> _orders = [];
  bool _isLoading = true;
  double _totalRevenue = 0.0;
  int _totalOrders = 0;
  Map<String, double> _categoryRevenue = {};

  @override
  void initState() {
    super.initState();
    _fetchSalesData();
  }

  Future<void> _fetchSalesData() async {
    setState(() => _isLoading = true);
    try {
      _orders = await _sellerServices.fetchAllOrders(context);
      _calculateSalesSummary();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching sales data: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  void _calculateSalesSummary() {
    _totalRevenue = 0.0;
    _totalOrders = 0;
    _categoryRevenue.clear();

    for (var order in _orders) {
      if (order.status == 3 && !order.cancelled) { // Delivered orders only
        for (var product in order.products) {
          final quantity = order.quantity[order.products.indexOf(product)];
          final revenue = product.finalPrice * quantity;

          _totalRevenue += revenue;
          _totalOrders += 1;

          // Category-wise revenue
          final category = product.category;
          _categoryRevenue[category] = (_categoryRevenue[category] ?? 0) + revenue;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSummaryItem(
                  'Total Revenue',
                  '\$${_totalRevenue.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.green,
                ),
                const SizedBox(width: 16),
                _buildSummaryItem(
                  'Total Orders',
                  _totalOrders.toString(),
                  Icons.shopping_cart,
                  Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Revenue by Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ..._categoryRevenue.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key),
                  Text(
                    '\$${entry.value.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
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
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
