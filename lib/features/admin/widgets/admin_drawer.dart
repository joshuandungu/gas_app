import 'package:ecommerce_app_fluterr_nodejs/features/account/screens/about_app_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/services/account_services.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/admin/screens/customer_queries_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/admin/screens/system_settings_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/screens/login_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/screens/login_selection_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user.name),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              backgroundImage: user.shopAvatar.isNotEmpty
                  ? NetworkImage(user.shopAvatar) as ImageProvider
                  : const AssetImage('assets/images/logo_3.png'),
            ),
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              // Navigate to profile screen
              Navigator.pop(context); // Close drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_system_daydream),
            title: const Text('System Settings'),
            onTap: () {
              Navigator.pushNamed(context, SystemSettingsScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.question_answer),
            title: const Text('Customer Queries'),
            onTap: () {
              Navigator.pushNamed(context, CustomerQueriesScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About App'),
            onTap: () {
              Navigator.pushNamed(context, AboutAppScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              String logoutRedirectRouteName = LoginSelectionScreen.routeName;
              String? role;

              if (user.type == 'seller') {
                logoutRedirectRouteName = LoginScreen.routeName;
                role = 'seller';
              } else if (user.type == 'admin') {
                logoutRedirectRouteName = LoginScreen.routeName;
                role = 'admin';
              }
              AccountServices().logOut(
                context,
                logoutRedirectRouteName: logoutRedirectRouteName,
                role: role,
              );
            },
          ),
        ],
      ),
    );
  }
}
