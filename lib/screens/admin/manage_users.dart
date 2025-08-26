
import 'package:flutter/material.dart';
import 'package:gas/models/user_model.dart';
// import 'package:gas/config/app_routes.dart'; // Ensure this file defines AppRoutes

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  ManageUsersScreenState createState() => ManageUsersScreenState();
}

class ManageUsersScreenState extends State<ManageUsersScreen> {
  final List<UserModel> _users = [
    UserModel(id: '1', fullName: 'Alice', email: 'alice@example.com', role: 'buyer', createdAt: DateTime.now()),
    UserModel(id: '2', fullName: 'Bob', email: 'bob@example.com', role: 'vendor', createdAt: DateTime.now()),
    UserModel(id: '3', fullName: 'Charlie', email: 'charlie@example.com', role: 'admin', createdAt: DateTime.now()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Users'),
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(user.fullName[0]),
              ),
              title: Text(user.fullName),
              subtitle: Text(user.email),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.pushNamed(context, '/userDetails', arguments: user);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Handle delete user
                      _showDeleteConfirmationDialog(context, user);
                    },
                  ),
                ],
              ),
              onTap: () {
                Navigator.pushNamed(context, '/userDetails', arguments: user);
              },
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete User'),
          content: Text('Are you sure you want to delete \${user.fullName}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // Perform delete operation here
                setState(() {
                  _users.removeWhere((u) => u.id == user.id);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
