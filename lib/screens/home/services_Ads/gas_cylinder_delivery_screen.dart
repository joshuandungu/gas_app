import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gas/services/api_service.dart';
import 'package:gas/providers/auth_provider.dart';
import 'package:gas/models/user_model.dart';
import 'package:provider/provider.dart';

class GasCylinderDeliveryScreen extends StatefulWidget {
  const GasCylinderDeliveryScreen({Key? key}) : super(key: key);

  @override
  State<GasCylinderDeliveryScreen> createState() => _GasDeliveryScreenState();
}

class _GasDeliveryScreenState extends State<GasCylinderDeliveryScreen> {
  int _quantity = 1;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedSize = '12kg';
  final List<String> _cylinderSizes = ['6kg', '12kg', '15kg', '45kg'];
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00C853),
        title: const Text(
          'Gas Cylinder Delivery',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withAlpha((0xFF * 0.1).round()),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00C853).withAlpha((0xFF * 0.3).round())),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      color: Color(0xFF00C853),
                      size: 50,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'FAST & RELIABLE DELIVERY',
                      style: TextStyle(
                        color: Color(0xFF00C853),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Cylinder Size Selection
              const Text(
                'Select Cylinder Size:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: _cylinderSizes.map((size) {
                  return ChoiceChip(
                    label: Text(size),
                    selected: _selectedSize == size,
                    selectedColor: const Color(0xFF00C853),
                    onSelected: (selected) {
                      setState(() {
                        _selectedSize = size;
                      });
                    },
                    labelStyle: TextStyle(
                      color: _selectedSize == size ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Quantity Selector
              const Text(
                'Quantity:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.white),
                    onPressed: () {
                      if (_quantity > 1) {
                        setState(() {
                          _quantity--;
                        });
                      }
                    },
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$_quantity',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _quantity++;
                      });
                    },
                  ),
                  const Spacer(),
                  Text(
                    _calculatePrice(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Delivery Details
              const Text(
                'Delivery Details:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Delivery Address',
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withAlpha((0xFF * 0.3).round())),
                  ),
                  prefixIcon: const Icon(Icons.location_on, color: Colors.white70),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter delivery address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Delivery Date',
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white.withAlpha((0xFF * 0.3).round())),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
                        hintText: _selectedDate == null 
                            ? 'Select date' 
                            : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                        hintStyle: const TextStyle(color: Colors.white),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) {
                        if (_selectedDate == null) {
                          return 'Please select delivery date';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Delivery Time',
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white.withAlpha((0xFF * 0.3).round())),
                        ),
                        prefixIcon: const Icon(Icons.access_time, color: Colors.white70),
                        hintText: _selectedTime == null
                            ? 'Select time'
                            : _selectedTime!.format(context),
                        hintStyle: const TextStyle(color: Colors.white),
                      ),
                      readOnly: true,
                      onTap: () => _selectTime(context),
                      validator: (value) {
                        if (_selectedTime == null) {
                          return 'Please select delivery time';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Special Instructions
              TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Special Instructions (Optional)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withAlpha((0xFF * 0.3).round())),
                  ),
                  prefixIcon: const Icon(Icons.note, color: Colors.white70),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 30),

              // Order Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _placeOrder,
                  child: const Text(
                    'PLACE ORDER',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculatePrice() {
    // Simple pricing logic - adjust based on your actual pricing
    double basePrice = 0;
    switch (_selectedSize) {
      case '6kg':
        basePrice = 1500;
        break;
      case '12kg':
        basePrice = 2500;
        break;
      case '15kg':
        basePrice = 3200;
        break;
      case '45kg':
        basePrice = 8500;
        break;
    }
    final total = basePrice * _quantity;
    return '₦${NumberFormat('#,###').format(total)}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00C853),
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF121212)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00C853),
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF121212)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      // Process the order
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Order Confirmation',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_quantity}x $_selectedSize cylinder(s)',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Delivery on ${DateFormat('MMM dd, yyyy').format(_selectedDate!)} at ${_selectedTime!.format(context)}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Total: ${_calculatePrice()}',
                style: const TextStyle(
                  color: Color(0xFF00C853),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
              ),
              onPressed: () async {
                Navigator.pop(context);

                // Get current user from AuthProvider
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final currentUser = authProvider.user;

                if (currentUser != null) {
                  // Create notification data
                  final notificationData = {
                    'user_id': currentUser.id,
                    'title': 'Gas Cylinder Delivery Order Placed',
                    'body': 'Your order for ${_quantity}x $_selectedSize cylinder(s) has been placed.',
                  };
                  // Send notification to backend
                  await ApiService.post('notifications', notificationData);
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order placed successfully!'),
                    backgroundColor: Color(0xFF00C853),
                  ),
                );
                // Here you would typically navigate to order confirmation screen
              },
              child: const Text('CONFIRM'),
            ),
          ],
        ),
      );
    }
  }
}