
import 'package:flutter/material.dart';
import 'package:gas/models/user_model.dart';

class UserDetailsScreen extends StatelessWidget {
  final UserModel user;

  const UserDetailsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.fullName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${user.id}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Email: ${user.email}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Role: ${user.role}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Address: ${user.address ?? 'N/A'}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Phone: ${user.phoneNumber ?? 'N/A'}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Member Since: ${user.createdAt}', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
