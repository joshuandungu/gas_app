import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gas/services/api_service.dart';
import 'package:gas/providers/auth_provider.dart';
import 'package:gas/models/user_model.dart';
import 'package:provider/provider.dart';

class GasInstallationMaintenanceScreen extends StatefulWidget {
  const GasInstallationMaintenanceScreen({Key? key}) : super(key: key);

  @override
  State<GasInstallationMaintenanceScreen> createState() => _GasInstallationScreenState();
}

class _GasInstallationScreenState extends State<GasInstallationMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedServiceType;
  bool _isLoading = false;

  final List<String> _serviceTypes = [
    'New Gas Installation',
    'System Maintenance',
    'Leak Detection',
    'Appliance Connection',
    'Pipe Replacement',
    'Safety Inspection'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
      setState(() => _selectedDate = picked);
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
      setState(() => _selectedTime = picked);
    }
  }

    void _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Get current user from AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user;

      if (currentUser != null) {
        // Create notification data
        final notificationData = {
          'user_id': currentUser.id,
          'title': 'Service Request Submitted',
          'body': 'A service request for ${_selectedServiceType} has been submitted by ${currentUser.fullName}.',
        };
        // Send notification to backend
        await ApiService.post('notifications', notificationData);
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Booking Confirmed',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Service: $_selectedServiceType',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}',
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                'Time: ${_selectedTime!.format(context)}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              const Text(
                'Our certified technician will contact you to confirm the appointment.',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      );

      // Reset form
      _formKey.currentState?.reset();
      _selectedServiceType = null;
      _selectedDate = null;
      _selectedTime = null;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit request: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00C853),
        title: const Text(
          'Installation & Maintenance',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Overview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.build_circle_outlined,
                    color: Color(0xFF00C853),
                    size: 50,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Professional Gas Services',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Certified technicians for all your gas installation and maintenance needs',
                    style: TextStyle(
                      color: Colors.white.withAlpha((0xFF * 0.7).round()),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Service Features
            const Text(
              'Our Services Include:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._serviceTypes.map((service) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF00C853),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      service,
                      style: TextStyle(
                        color: Colors.white.withAlpha((0xFF * 0.8).round()),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 24),

            // Booking Form
            const Text(
              'Book a Service:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Type Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedServiceType,
                    decoration: InputDecoration(
                      labelText: 'Service Type',
                      labelStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      prefixIcon: const Icon(Icons.build, color: Colors.white70),
                    ),
                    items: _serviceTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedServiceType = value);
                    },
                    validator: (value) =>
                        value == null ? 'Please select a service type' : null,
                  ),
                  const SizedBox(height: 16),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Your Name',
                      labelStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      prefixIcon: const Icon(Icons.person, color: Colors.white70),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone Field
                  TextFormField(
                    controller: _phoneController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      prefixIcon: const Icon(Icons.phone, color: Colors.white70),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Address Field
                  TextFormField(
                    controller: _addressController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Service Address',
                      labelStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      prefixIcon: const Icon(Icons.location_on, color: Colors.white70),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter service address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date & Time Selection
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Preferred Date',
                              labelStyle: const TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[700]!),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF1E1E1E),
                              prefixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
                            ),
                            child: Text(
                              _selectedDate == null
                                  ? 'Select date'
                                  : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectTime(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Preferred Time',
                              labelStyle: const TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[700]!),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF1E1E1E),
                              prefixIcon: const Icon(Icons.access_time, color: Colors.white70),
                            ),
                            child: Text(
                              _selectedTime == null
                                  ? 'Select time'
                                  : _selectedTime!.format(context),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Additional Details
                  TextFormField(
                    controller: _detailsController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Additional Details',
                      labelStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      prefixIcon: const Icon(Icons.note, color: Colors.white70),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text(
                              'BOOK SERVICE NOW',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}