import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String BACKEND_BASE = 'http://YOUR_BACKEND_URL';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  /// --------------------- FIRESTORE ACTIONS ---------------------

  Future<void> _deleteUser(String docId, String name) async {
    if (!await _confirm('Delete User', 'Are you sure you want to delete $name?')) return;

    setState(() => _isProcessing = true);
    try {
      await _firestore.collection('users').doc(docId).delete();
      _showMessage('User deleted.');
    } catch (e) {
      _showMessage('Error deleting user: $e');
    }
    setState(() => _isProcessing = false);
  }

  Future<void> _approveVendor(String docId, Map<String, dynamic> vendorData) async {
    if (!await _confirm('Approve Vendor', 'Approve ${vendorData['fullName'] ?? vendorData['name'] ?? 'vendor'}?')) return;

    setState(() => _isProcessing = true);
    try {
      await _firestore.collection('users').doc(docId).update({
        'isVendor': true,
        'role': 'vendor',
        'vendorApprovedAt': FieldValue.serverTimestamp(),
        'vendorStatus': 'active',
        'vendorRequestStatus': 'approved',
      });

      final resp = await http.post(
        Uri.parse('$BACKEND_BASE/api/vendors/approve'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': docId,
          'name': vendorData['name'],
          'email': vendorData['email']
        }),
      );

      _showMessage(resp.statusCode == 200
          ? 'Vendor approved.'
          : 'Firestore updated but backend failed.');
    } catch (e) {
      _showMessage('Error: $e');
    }
    setState(() => _isProcessing = false);
  }

  Future<void> _rejectVendor(String docId, Map<String, dynamic> vendorData) async {
    if (!await _confirm('Reject Vendor', 'Reject ${vendorData['fullName'] ?? vendorData['name'] ?? 'vendor'}?')) return;

    setState(() => _isProcessing = true);
    try {
      await _firestore.collection('users').doc(docId).update({
        'vendorRequestStatus': 'rejected',
        'vendorStatus': 'rejected',
      });

      final resp = await http.post(
        Uri.parse('$BACKEND_BASE/api/vendors/reject'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uid': docId}),
      );

      _showMessage(resp.statusCode == 200
          ? 'Vendor rejected.'
          : 'Firestore updated but backend failed.');
    } catch (e) {
      _showMessage('Error: $e');
    }
    setState(() => _isProcessing = false);
  }

  Future<void> _suspendVendor(String docId) async {
    if (!await _confirm('Suspend Vendor', 'Suspend this vendor?')) return;

    setState(() => _isProcessing = true);
    try {
      await _firestore.collection('users').doc(docId).update({
        'vendorStatus': 'suspended',
        'vendorSuspendedAt': FieldValue.serverTimestamp(),
      });
      _showMessage('Vendor suspended.');
    } catch (e) {
      _showMessage('Error: $e');
    }
    setState(() => _isProcessing = false);
  }

  Future<void> _unsuspendVendor(String docId) async {
    if (!await _confirm('Unsuspend Vendor', 'Unsuspend this vendor?')) return;

    setState(() => _isProcessing = true);
    try {
      await _firestore.collection('users').doc(docId).update({
        'vendorStatus': 'active',
      });
      _showMessage('Vendor unsuspended.');
    } catch (e) {
      _showMessage('Error: $e');
    }
    setState(() => _isProcessing = false);
  }

  /// --------------------- UI HELPERS ---------------------

  Future<bool> _confirm(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Yes')),
            ],
          ),
        ) ??
        false;
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildUserTile(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['fullName'] ?? data['name'] ?? 'No Name';
    final email = data['email'] ?? '';
    final role = data['role'] ?? 'buyer';

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: CircleAvatar(
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?')),
        title: Text(name),
        subtitle: Text('$email\nRole: $role'),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteUser(doc.id, name),
        ),
      ),
    );
  }

  Widget _buildPendingVendorTile(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['fullName'] ?? data['name'] ?? 'No Name';
    final email = data['email'] ?? '';

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(name),
        subtitle: Text(email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                onPressed: () => _approveVendor(doc.id, data),
                icon: const Icon(Icons.check, color: Colors.green)),
            IconButton(
                onPressed: () => _rejectVendor(doc.id, data),
                icon: const Icon(Icons.close, color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovedVendorTile(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['fullName'] ?? data['name'] ?? 'No Name';
    final email = data['email'] ?? '';
    final status = data['vendorStatus'] ?? 'active';

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(name),
        subtitle: Text('$email\nStatus: $status'),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (val) {
            if (val == 'suspend') _suspendVendor(doc.id);
            if (val == 'unsuspend') _unsuspendVendor(doc.id);
          },
          itemBuilder: (_) => [
            if (status != 'suspended')
              const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
            if (status == 'suspended')
              const PopupMenuItem(value: 'unsuspend', child: Text('Unsuspend')),
          ],
        ),
      ),
    );
  }

  /// --------------------- BUILD ---------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Pending Vendors'),
            Tab(text: 'Approved Vendors'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // USERS TAB
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('users').snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snap.data!.docs;
              if (docs.isEmpty) {
                return const Center(child: Text('No users found.'));
              }
              return ListView(children: docs.map(_buildUserTile).toList());
            },
          ),

          // PENDING VENDORS TAB
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('users')
                .where('vendorRequestStatus', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snap.data!.docs;
              if (docs.isEmpty) {
                return const Center(
                    child: Text('No pending vendor requests.'));
              }
              return ListView(
                  children: docs.map(_buildPendingVendorTile).toList());
            },
          ),

          // APPROVED VENDORS TAB
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('users')
                .where('isVendor', isEqualTo: true)
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snap.data!.docs;
              if (docs.isEmpty) {
                return const Center(child: Text('No approved vendors.'));
              }
              return ListView(
                  children: docs.map(_buildApprovedVendorTile).toList());
            },
          ),
        ],
      ),
    );
  }
}
