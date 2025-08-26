
import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Sales Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16.0),
            _buildSalesOverview(context),
            SizedBox(height: 24.0),
            Text(
              'User Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16.0),
            _buildUserStatistics(context),
            SizedBox(height: 24.0),
            Text(
              'Top Performing Vendors',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16.0),
            _buildTopVendors(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesOverview(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildReportRow(context, icon: Icons.attach_money, title: 'Total Revenue', value: '\$12,345.67'),
            Divider(),
            _buildReportRow(context, icon: Icons.receipt_long, title: 'Total Orders', value: '456'),
            Divider(),
            _buildReportRow(context, icon: Icons.local_gas_station, title: 'Total Gas Sold', value: '1,234 units'),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStatistics(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildReportRow(context, icon: Icons.people, title: 'Total Users', value: '123'),
            Divider(),
            _buildReportRow(context, icon: Icons.person_add, title: 'New Users (Last 30 Days)', value: '15'),
            Divider(),
            _buildReportRow(context, icon: Icons.shopping_cart, title: 'Active Buyers', value: '78'),
          ],
        ),
      ),
    );
  }

  Widget _buildTopVendors(BuildContext context) {
    // Dummy data for top vendors
    final topVendors = [
      {'name': 'Vendor A', 'sales': '\$3,456.78'},
      {'name': 'Vendor B', 'sales': '\$2,123.45'},
      {'name': 'Vendor C', 'sales': '\$1,987.65'},
    ];

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        children: topVendors.map((vendor) {
          return ListTile(
            leading: Icon(Icons.store, color: Theme.of(context).primaryColor),
            title: Text(vendor['name']!),
            trailing: Text(vendor['sales']!, style: TextStyle(fontWeight: FontWeight.bold)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReportRow(BuildContext context, {required IconData icon, required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Icon(icon, color: Theme.of(context).primaryColor),
          SizedBox(width: 16.0),
          Text(title, style: TextStyle(fontSize: 16.0)),
          Spacer(),
          Text(value, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
