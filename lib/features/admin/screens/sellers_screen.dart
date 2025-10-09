import 'package:flutter/material.dart';

import 'package:ecommerce_app_fluterr_nodejs/features/admin/services/admin_services.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/user.dart';

class SellersScreen extends StatefulWidget {
  const SellersScreen({Key? key}) : super(key: key);

  @override
  State<SellersScreen> createState() => _SellersScreenState();
}

class _SellersScreenState extends State<SellersScreen> {
  List<User>? sellers;
  final AdminServices adminServices = AdminServices();

  @override
  void initState() {
    super.initState();
    fetchSellers();
  }

  fetchSellers() async {
    sellers = await adminServices.fetchSellers(context);
    setState(() {});
  }

  void suspendSeller(String sellerId) {
    adminServices.suspendSeller(
      context: context,
      sellerId: sellerId,
      onSuccess: () {
        fetchSellers();
      },
    );
  }

  void activateSeller(String sellerId) {
    adminServices.activateSeller(
      context: context,
      sellerId: sellerId,
      onSuccess: () {
        fetchSellers();
      },
    );
  }

  void deleteSeller(String sellerId) {
    adminServices.deleteSeller(
      context: context,
      sellerId: sellerId,
      onSuccess: () {
        fetchSellers();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return sellers == null
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            body: ListView.builder(
              itemCount: sellers!.length,
              itemBuilder: (context, index) {
                final seller = sellers![index];
                return ListTile(
                  title: Text(seller.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(seller.email),
                      Text('Role: Seller'),
                      Text(
                        'Status: ${seller.status}',
                        style: TextStyle(
                          color: seller.status == 'active'
                              ? Colors.green
                              : seller.status == 'suspended'
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (seller.status == 'active')
                        ElevatedButton.icon(
                          onPressed: () => suspendSeller(seller.id),
                          icon: const Icon(Icons.pause, color: Colors.white),
                          label: const Text('Suspend'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                        )
                      else if (seller.status == 'suspended')
                        ElevatedButton.icon(
                          onPressed: () => activateSeller(seller.id),
                          icon: const Icon(Icons.play_arrow, color: Colors.white),
                          label: const Text('Activate'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      IconButton(
                        onPressed: () => deleteSeller(seller.id),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        tooltip: 'Delete Seller',
                      ),
                    ],
                  ),
                  isThreeLine: true,
                );
              },
            ),
          );
  }
}