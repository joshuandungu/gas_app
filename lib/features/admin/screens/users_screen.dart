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

  void approveUser(String userId) {
    adminServices.approveUser(
      context: context,
      userId: userId,
      onSuccess: () {
        fetchUsers();
      },
    );
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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email),
                      Text('Role: ${user.type}'),
                      Text(
                        'Status: ${user.status}',
                        style: TextStyle(
                          color: user.status == 'pending'
                              ? Colors.orange
                              : user.status == 'active'
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (user.status == 'pending')
                        ElevatedButton.icon(
                          onPressed: () => approveUser(user.id),
                          icon: const Icon(Icons.check_circle, color: Colors.white),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      if (user.status == 'active')
                        ElevatedButton.icon(
                          onPressed: () => suspendUser(user.id),
                          icon: const Icon(Icons.pause, color: Colors.white),
                          label: const Text('Suspend'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                        ),
                      if (user.status == 'suspended')
                        ElevatedButton.icon(
                          onPressed: () => approveUser(user.id),
                          icon: const Icon(Icons.play_arrow, color: Colors.white),
                          label: const Text('Activate'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
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
                  isThreeLine: true,
                );
              },
            ),
          );
  }
}
