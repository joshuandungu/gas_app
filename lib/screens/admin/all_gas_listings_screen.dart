
import 'package:flutter/material.dart';

class AllGasListingsScreen extends StatelessWidget {
  const AllGasListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Gas Listings'),
      ),
      body: Center(
        child: Text('This screen will display all gas listings from all vendors.'),
      ),
    );
  }
}
