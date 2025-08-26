import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gas/services/api_service.dart';
import 'package:gas/models/user_model.dart';

class NotificationScreen extends StatefulWidget {
  final UserModel currentUser;

  const NotificationScreen({super.key, required this.currentUser});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final List<dynamic> fetchedNotifications = await ApiService.get('notifications/user/${widget.currentUser.id}');
      if (!mounted) return;
      setState(() {
        _notifications = fetchedNotifications;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load notifications: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await ApiService.put('notifications/$notificationId/read', {});
      if (!mounted) return;
      // Optimistically update UI or refetch
      _fetchNotifications();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark as read: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await ApiService.delete('notifications/$notificationId');
      if (!mounted) return;
      // Optimistically update UI or refetch
      _fetchNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification deleted.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete notification: ${e.toString()}')),
      );
    }
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat("MMM d, yyyy • h:mm a").format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _notifications.isEmpty
                  ? const Center(
                      child: Text(
                        "No notifications yet.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        final title = notification["title"] ?? "New Notification";
                        final body = notification["body"] ?? "";
                        final timestamp = notification["created_at"] != null && notification["created_at"] is String
                            ? _formatTimestamp(notification["created_at"] as String)
                            : "";
                        final isRead = notification['is_read'] ?? false;

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          color: isRead ? Colors.white : Colors.blue.shade50,
                          child: ListTile(
                            leading: Icon(
                              isRead ? Icons.notifications_none : Icons.notifications_active,
                              color: isRead ? Colors.grey : Colors.blue,
                            ),
                            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(body),
                                const SizedBox(height: 4),
                                Text(
                                  timestamp,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteNotification(notification['id']),
                            ),
                            onTap: () {
                              if (!isRead) {
                                _markAsRead(notification['id']);
                              }
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}