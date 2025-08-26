import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gas/providers/vendor_provider.dart';
import 'package:gas/models/user_model.dart';
import 'package:gas/models/gas_model.dart';

class VendorGasListingsScreen extends StatefulWidget {
  final UserModel currentUser;

  const VendorGasListingsScreen({super.key, required this.currentUser});

  @override
  State<VendorGasListingsScreen> createState() =>
      _VendorGasListingsScreenState();
}

class _VendorGasListingsScreenState extends State<VendorGasListingsScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Delay the provider call until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGasListings();
    });
  }

  Future<void> _loadGasListings() async {
    try {
      final vendorProvider =
          Provider.of<VendorProvider>(context, listen: false);
      await vendorProvider.fetchGasListings(widget.currentUser.id);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load gas listings: $e';
      });
    }
  }

  Future<void> _deleteListing(String listingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Listing"),
        content: const Text("Are you sure you want to delete this listing?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final vendorProvider =
          Provider.of<VendorProvider>(context, listen: false);
      await vendorProvider.deleteGasListing(listingId, widget.currentUser.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Listing deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Gas Listings')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    return Consumer<VendorProvider>(
      builder: (context, provider, child) {
        if (provider.gasListings.isEmpty) {
          return const Center(child: Text('You have no gas listings yet.'));
        }

        return RefreshIndicator(
          onRefresh: _loadGasListings,
          child: ListView.builder(
            itemCount: provider.gasListings.length,
            itemBuilder: (context, index) {
              final GasModel gas = provider.gasListings[index];
              final isAvailable = gas.quantityAvailable > 0;

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundImage: gas.imageUrl.isNotEmpty
                        ? NetworkImage(gas.imageUrl)
                        : null,
                    child: gas.imageUrl.isEmpty
                        ? const Icon(Icons.local_gas_station)
                        : null,
                  ),
                  title: Text(
                    gas.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quantity: ${gas.quantityAvailable}'),
                      Text('Status: ${isAvailable ? 'Available' : 'Sold Out'}'),
                      if (gas.category.isNotEmpty)
                        Text("Category: ${gas.category}"),
                      Text(
                        "Updated: ${gas.lastUpdated.toLocal().toString().split('.').first}",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '\$${gas.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteListing(gas.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
