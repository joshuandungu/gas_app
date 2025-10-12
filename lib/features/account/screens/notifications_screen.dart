import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  static const String routeName = '/notifications';
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text('Order Confirmed'),
            subtitle: Text('Your order #1234 has been confirmed.'),
            trailing: Text('2h ago'),
          ),
          ListTile(
            title: Text('Order Shipped'),
            subtitle: Text('Your order #1234 has been shipped.'),
            trailing: Text('1d ago'),
          ),
          // Add more notifications as needed
        ],
      ),
    );
  }
}
