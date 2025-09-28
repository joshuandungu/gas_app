import 'package:flutter/material.dart';

import 'package:ecommerce_app_fluterr_nodejs/features/admin/services/admin_services.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/user.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User>? users;
  final AdminServices adminServices = AdminServices();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  fetchUsers() async {
    users = await adminServices.fetchUsers(context);
    setState(() {});
  }

  void suspendUser(String userId) {
    adminServices.suspendUser(
      context: context,
      userId: userId,
      onSuccess: () {
        fetchUsers();
      },
    );
  }

  void deleteUser(String userId) {
    adminServices.deleteUser(
      context: context,
      userId: userId,
      onSuccess: () {
        fetchUsers();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return users == null
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              title: const Text('Manage Users'),
            ),
            body: ListView.builder(
              itemCount: users!.length,
              itemBuilder: (context, index) {
                final user = users![index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => suspendUser(user.id),
                        icon: const Icon(
                          Icons.pause,
                          color: Colors.orange,
                        ),
                        tooltip: 'Suspend User',
                      ),
                      IconButton(
                        onPressed: () => deleteUser(user.id),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        tooltip: 'Delete User',
                      ),
                    ],
                  ),
                );
              },
            ),
          );
  }
}
