import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gas/models/user_model.dart';

class BulkGasSupplyScreen extends StatefulWidget {
  final UserModel currentUser;

  const BulkGasSupplyScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  _BulkGasSupplyScreenState createState() => _BulkGasSupplyScreenState();
}

class _BulkGasSupplyScreenState extends State<BulkGasSupplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;

  Future<void> _postBulkSupply() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Save bulk gas supply in Firestore
      final supplyRef = await FirebaseFirestore.instance
          .collection('bulk_gas_supplies')
          .add({
        'vendorId': widget.currentUser.id,
        'vendorName': widget.currentUser.fullName,
        'quantity': _quantityController.text.trim(),
        'price': _priceController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Also create a notification entry for buyers
      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'bulk_supply',
        'supplyId': supplyRef.id,
        'vendorId': widget.currentUser.id,
        'vendorName': widget.currentUser.fullName,
        'quantity': _quantityController.text.trim(),
        'price': _priceController.text.trim(),
        'location': _locationController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'description': _descriptionController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bulk gas supply posted successfully!')),
      );

      _quantityController.clear();
      _priceController.clear();
      _locationController.clear();
      _descriptionController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }

    setState(() => _isLoading = false);
  }

  Widget _buildVendorForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity (e.g., 500 Liters)'),
              validator: (v) => v!.isEmpty ? 'Enter quantity' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price per unit'),
              validator: (v) => v!.isEmpty ? 'Enter price' : null,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
              validator: (v) => v!.isEmpty ? 'Enter location' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _postBulkSupply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      padding: const EdgeInsets.all(14),
                    ),
                    child: const Text(
                      'Post Bulk Gas Supply',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyerView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bulk_gas_supplies')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No bulk gas supplies available.'));
        }

        final supplies = snapshot.data!.docs;

        return ListView.builder(
          itemCount: supplies.length,
          itemBuilder: (context, index) {
            final data = supplies[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                title: Text('${data['quantity']} - ${data['price']}'),
                subtitle: Text('${data['vendorName']} • ${data['location']}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Bulk Gas Details'),
                      content: Text(
                        'Vendor: ${data['vendorName']}\n'
                        'Quantity: ${data['quantity']}\n'
                        'Price: ${data['price']}\n'
                        'Location: ${data['location']}\n'
                        'Description: ${data['description'] ?? "No description"}',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Gas Supply'),
        backgroundColor: const Color(0xFF00C853),
      ),
      body: widget.currentUser.role == 'vendor'
          ? _buildVendorForm()
          : _buildBuyerView(),
    );
  }
}
