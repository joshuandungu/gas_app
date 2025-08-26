
import 'package:flutter/material.dart';

class AllOrdersScreen extends StatelessWidget {
  const AllOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Orders'),
      ),
      body: Center(
        child: Text('This screen will display all orders from all users.'),
      ),
    );
  }
}
