import 'package:ecommerce_app_fluterr_nodejs/features/admin/services/admin_services.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/vendor_sales.dart';
import 'package:flutter/material.dart';

class VendorSalesScreen extends StatefulWidget {
  static const String routeName = '/admin-vendor-sales';
  const VendorSalesScreen({super.key});

  @override
  State<VendorSalesScreen> createState() => _VendorSalesScreenState();
}

class _VendorSalesScreenState extends State<VendorSalesScreen> {
  List<VendorSales>? vendorSales;
  final AdminServices adminServices = AdminServices();

  @override
  void initState() {
    super.initState();
    fetchVendorSales();
  }

  void fetchVendorSales() async {
    vendorSales = await adminServices.getVendorSalesSummary(context: context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Sales'),
      ),
      body: vendorSales == null
          ? const Center(child: CircularProgressIndicator())
          : vendorSales!.isEmpty
              ? const Center(child: Text('No sales data available.'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Summary of All Vendors',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: vendorSales!.length,
                        itemBuilder: (context, index) {
                          final vendor = vendorSales![index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: vendor.shopAvatar.isNotEmpty
                                    ? NetworkImage(vendor.shopAvatar)
                                    : null,
                                child: vendor.shopAvatar.isEmpty
                                    ? const Icon(Icons.store)
                                    : null,
                              ),
                              title: Text(
                                vendor.shopName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Revenue: \$${vendor.totalRevenue.toStringAsFixed(2)}'),
                                  Text(
                                      'Completed Orders: ${vendor.completedOrders}'),
                                ],
                              ),
                              trailing: Text(
                                '#${index + 1}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
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
}
