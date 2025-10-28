import 'package:flutter/material.dart';

class CustomerQueriesScreen extends StatelessWidget {
  static const String routeName = '/customer-queries';
  const CustomerQueriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Queries'),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text('Order Issue'),
            subtitle: Text('Customer reported problem with order #1234'),
            trailing: Text('2h ago'),
          ),
          ListTile(
            title: Text('Payment Issue'),
            subtitle: Text('Customer unable to complete payment'),
            trailing: Text('5h ago'),
          ),
          // Add more queries as needed
        ],
      ),
    );
  }
}
