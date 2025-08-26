import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gas/providers/buyer_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final buyerProvider = Provider.of<BuyerProvider>(context);
    final cart = buyerProvider.cart;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart'),
      ),
      body: cart.isEmpty
          ? Center(child: Text('Your cart is empty.'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text('Quantity: ${item.quantity}'),
                        trailing: Text('\$${(item.priceAtPurchase * item.quantity).toStringAsFixed(2)}'),
                        onTap: () {
                          // Can add functionality to edit quantity or remove
                        },
                      );
                    },
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${buyerProvider.cart.fold(0.0, (sum, item) => sum + (item.priceAtPurchase * item.quantity)).toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Handle checkout
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                  ),
                  child: Text('Proceed to Checkout'),
                ),
                SizedBox(height: 16),
              ],
            ),
    );
  }
}