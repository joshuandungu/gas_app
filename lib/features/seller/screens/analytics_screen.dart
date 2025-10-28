import 'package:flutter/material.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/models/sales.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/services/seller_services.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/widgets/category_products_chart.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/widgets/sales_summary_widget.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final SellerServices _sellerServices = SellerServices();
  double? totalEarnings;
  List<Sales>? sales;

  @override
  void initState() {
    super.initState();
    getEarnings();
  }

  getEarnings() async {
    var earningData = await _sellerServices.getEarnings(context);
    totalEarnings = earningData['totalEarnings'];
    sales = earningData['sales'];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return sales == null || totalEarnings == null
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sales Summary Widget
                const SalesSummaryWidget(),
                const SizedBox(height: 20),

                // Existing earnings display
                Text(
                  'Total Earnings: Ksh ${totalEarnings!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Category-wise Earnings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 300,
                  child: BarChartAnalytics(salesData: sales!),
                ),
              ],
            ),
          );
  }
}
