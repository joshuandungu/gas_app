import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gas/providers/buyer_provider.dart';
import 'package:gas/screens/buyer/product_screen.dart';

class GasListScreen extends StatefulWidget {
  const GasListScreen({super.key});

  @override
  _GasListScreenState createState() => _GasListScreenState();
}

class _GasListScreenState extends State<GasListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch gases when the screen loads
    Provider.of<BuyerProvider>(context, listen: false).fetchGases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Gas'),
      ),
      body: Consumer<BuyerProvider>(
        builder: (context, provider, child) {
          if (provider.availableGases.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: provider.availableGases.length,
            itemBuilder: (context, index) {
              final gas = provider.availableGases[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.local_gas_station),
                  ),
                  title: Text(gas.name),
                  subtitle: Text(gas.description),
                  trailing: Text('\$${gas.price.toStringAsFixed(2)}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductScreen(gas: gas),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  
}