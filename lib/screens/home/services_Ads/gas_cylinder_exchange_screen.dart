import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gas/models/user_model.dart';
import 'package:gas/services/api_service.dart';

class GasCylinderExchangeScreen extends StatefulWidget {
  final UserModel currentUser;

  const GasCylinderExchangeScreen({Key? key, required this.currentUser})
      : super(key: key);

  @override
  _GasCylinderExchangeScreenState createState() => _GasCylinderExchangeScreenState();
}

class _GasCylinderExchangeScreenState extends State<GasCylinderExchangeScreen> {
  final TextEditingController _gasTypeController = TextEditingController();
  final TextEditingController _cylinderSizeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool _isLoading = false;
  List<Map<String, dynamic>> _exchanges = [];

  final String backendUrl = "http://localhost:5000/api/cylinder-exchange"; // Update with your backend URL

  @override
  void initState() {
    super.initState();
    _fetchExchanges();
  }

  Future<void> _fetchExchanges() async {
    try {
      setState(() => _isLoading = true);
      final List<dynamic> data = await ApiService.get("cylinder-exchange");

      if (!mounted) return;
      setState(() {
        _exchanges = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      _showMessage("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _postExchange() async {
    if (_gasTypeController.text.isEmpty ||
        _cylinderSizeController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _locationController.text.isEmpty) {
      _showMessage("All fields are required");
      return;
    }

    try {
      setState(() => _isLoading = true);

      final body = {
        "vendorId": widget.currentUser.id,
        "vendorName": widget.currentUser.fullName,
        "gasType": _gasTypeController.text,
        "cylinderSize": _cylinderSizeController.text,
        "price": _priceController.text,
        "location": _locationController.text,
        "createdAt": DateTime.now().toIso8601String(),
      };

      await ApiService.post("cylinder-exchange", body);

      // Send notification to backend
      final notificationData = {
        'user_id': widget.currentUser.id,
        'title': 'New Cylinder Exchange Offer',
        'body': 'A new cylinder exchange offer for ${_gasTypeController.text} - ${_cylinderSizeController.text} has been posted by ${widget.currentUser.fullName}.',
      };
      await ApiService.post('notifications', notificationData);

      if (!mounted) return;
      _showMessage("Exchange offer posted!");
      _gasTypeController.clear();
      _cylinderSizeController.clear();
      _priceController.clear();
      _locationController.clear();
      _fetchExchanges();
    } catch (e) {
      if (!mounted) return;
      _showMessage("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Post Cylinder Exchange"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _gasTypeController,
                decoration: const InputDecoration(labelText: "Gas Type"),
              ),
              TextField(
                controller: _cylinderSizeController,
                decoration: const InputDecoration(labelText: "Cylinder Size"),
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: "Location"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _postExchange();
            },
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cylinder Exchange"),
        actions: [
          if (widget.currentUser.role == "vendor")
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddDialog,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _exchanges.isEmpty
              ? const Center(child: Text("No cylinder exchange offers"))
              : ListView.builder(
                  itemCount: _exchanges.length,
                  itemBuilder: (context, index) {
                    final exchange = _exchanges[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(
                            "${exchange['gasType']} - ${exchange['cylinderSize']}"),
                        subtitle: Text(
                            "Price: ${exchange['price']}\nLocation: ${exchange['location']}\nVendor: ${exchange['vendorName']}"),
                      ),
                    );
                  },
                ),
    );
  }
}
