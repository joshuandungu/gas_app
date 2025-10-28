import 'package:ecommerce_app_fluterr_nodejs/features/account/services/account_services.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/widgets/notifications_bottom_sheet.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/product_details/screens/product_details_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/product_details/services/product_details_services.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/notification.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  static const String routeName = '/notifications';
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Notification_Model> notifications = [];
  final AccountServices accountServices = AccountServices();

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    notifications = await accountServices.fetchNotifications(context);
    setState(() {});
  }

  Future<void> _handleNotificationTap(Notification_Model notification) async {
    if (!notification.isRead) {
      await accountServices.markNotificationAsRead(
        context,
        notification.id,
      );
    }

    if (!context.mounted) return;

    switch (notification.type) {
      case 'new_product':
      case 'update_product':
      case 'discount':
        final productDetailsServices = ProductDetailsServices();
        final product = await productDetailsServices.fetchProductById(
          context: context,
          productId: notification.productId,
        );

        if (!context.mounted) return;
        Navigator.pushNamed(
          context,
          ProductDetailsScreen.routeName,
          arguments: product,
        );
        break;
    }

    fetchNotifications();
  }

  Future<void> _handleMarkAllRead() async {
    await accountServices.markAllNotificationsAsRead(context);
    fetchNotifications();
  }

  Future<void> _handleDeleteNotification(String id) async {
    await accountServices.deleteNotification(context, id);
    fetchNotifications();
  }

  Future<void> _handleDeleteAll() async {
    await accountServices.deleteAllNotifications(context);
    fetchNotifications();
  }

  Future<void> _handleClearOld(int days) async {
    await accountServices.clearOldNotifications(context, days);
    fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Dismissible(
                  key: Key(notification.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _handleDeleteNotification(notification.id),
                  child: Card(
                    elevation: notification.isRead ? 0 : 2,
                    color: notification.isRead ? Colors.white : Colors.blue[50],
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getNotificationColor(notification.type).withOpacity(0.2),
                        child: Icon(
                          _getNotificationIcon(notification.type),
                          color: _getNotificationColor(notification.type),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        notification.message,
                        style: TextStyle(
                          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        _formatDate(notification.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      onTap: () => _handleNotificationTap(notification),
                    ),
                  ),
                );
              },
            ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'new_product':
        return Icons.new_releases;
      case 'update_product':
        return Icons.update;
      case 'discount':
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'new_product':
        return Colors.green;
      case 'update_product':
        return Colors.blue;
      case 'discount':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    }
    if (difference.inDays == 1) {
      return 'Yesterday';
    }
    return '${difference.inDays} days ago';
  }
}
