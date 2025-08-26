
import 'package:flutter/material.dart';
import 'package:gas/models/gas_model.dart';
import 'package:gas/providers/buyer_provider.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatelessWidget {
  final GasModel gas;

  const ProductScreen({super.key, required this.gas});

  @override
  Widget build(BuildContext context) {
    final TextEditingController quantityController =
        TextEditingController(text: '1');

    return Scaffold(
      appBar: AppBar(
        title: Text(gas.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              gas.description,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              'Price: \$${gas.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text('Add to Cart'),
              onPressed: () {
                final quantity = int.tryParse(quantityController.text) ?? 1;
                Provider.of<BuyerProvider>(context, listen: false)
                    .addToCart(gas, quantity);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('\${gas.name} added to cart.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
