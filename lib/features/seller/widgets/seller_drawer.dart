import 'package:ecommerce_app_fluterr_nodejs/features/account/screens/about_app_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/screens/customer_care_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/screens/notifications_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/screens/settings_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/services/account_services.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/screens/login_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/screens/login_selection_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/orders_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/seller_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SellerDrawer extends StatelessWidget {
  const SellerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, SellerScreen.routeName);
              },
              child: Text(user.name),
            ),
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
              Navigator.pushNamed(context, SellerScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Orders'),
            onTap: () {
              Navigator.pushNamed(context, '/seller-orders');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About App'),
            onTap: () {
              Navigator.pushNamed(context, AboutAppScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pushNamed(context, SettingsScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pushNamed(context, NotificationsScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.support),
            title: const Text('Customer Care'),
            onTap: () {
              Navigator.pushNamed(context, CustomerCareScreen.routeName);
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
