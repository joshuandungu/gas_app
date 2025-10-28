import 'package:ecommerce_app_fluterr_nodejs/features/account/screens/about_app_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/screens/customer_care_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/screens/notifications_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/screens/orders_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/screens/settings_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/services/account_services.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/screens/login_selection_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/screens/login_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/chat/screens/chat_list_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuyerDrawer extends StatelessWidget {
  const BuyerDrawer({super.key});

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
                Navigator.pushNamed(context, '/account');
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
              Navigator.pushNamed(context, '/account'); // Navigate to account screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Orders'),
            onTap: () {
              Navigator.pushNamed(context, OrdersScreen.routeName);
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
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Become a Seller'),
            onTap: () {
              Navigator.pushNamed(context, '/seller-request-screen');
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Chat with Sellers'),
            onTap: () {
              Navigator.pushNamed(context, ChatListScreen.routeName, arguments: {'view': 'seller'});
            },
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Chat with Admin'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatListScreen(initialView: 'admin')));
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
