import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gas/services/api_service.dart';
import 'package:gas/providers/auth_provider.dart';
import 'package:gas/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:gas/services/api_service.dart';
import 'package:gas/providers/auth_provider.dart';
import 'package:gas/models/user_model.dart';
import 'package:provider/provider.dart';

class CorporateContractsScreen extends StatefulWidget {
  const CorporateContractsScreen({Key? key}) : super(key: key);

  @override
  State<CorporateContractsScreen> createState() => _CorporateContractsScreenState();
}

class _CorporateContractsScreenState extends State<CorporateContractsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _contactPersonController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _estimatedConsumptionController = TextEditingController();
  final TextEditingController _specialRequirementsController = TextEditingController();

  String? _selectedContractType;
  DateTime? _contractStartDate;
  DateTime? _contractEndDate;
  bool _isLoading = false;

  final List<String> _contractTypes = [
    'Annual Bulk Supply',
    'Monthly Scheduled Delivery',
    'On-Demand Priority Service',
    'Full Maintenance Contract',
    'Equipment Lease + Supply'
  ];

  @override
  void dispose() {
    _companyNameController.dispose();
    _contactPersonController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _estimatedConsumptionController.dispose();
    _specialRequirementsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00C853),
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF121212),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _contractStartDate = picked;
          if (_contractEndDate != null && _contractEndDate!.isBefore(picked)) {
            _contractEndDate = null;
          }
        } else {
          _contractEndDate = picked;
        }
      });
    }
  }

  void _submitProposal() async {
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
          'title': 'Corporate Proposal Submitted',
          'body': 'A corporate contract proposal has been submitted by ${currentUser.fullName} for ${_companyNameController.text.trim()}.',
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
            'Proposal Submitted',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thank you for your corporate contract request!',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Our corporate team will:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildListTile(Icons.assignment, 'Review your requirements'),
                _buildListTile(Icons.people, 'Assign a dedicated account manager'),
                _buildListTile(Icons.description, 'Prepare a customized proposal'),
                _buildListTile(Icons.phone, 'Contact you within 2 business days'),
                const SizedBox(height: 16),
                Text(
                  'For immediate assistance, call our corporate line:',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                const SizedBox(height: 8),
                const Text(
                  '+254 700 123 456',
                  style: TextStyle(
                    color: Color(0xFF00C853),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _formKey.currentState?.reset();
                setState(() {
                  _selectedContractType = null;
                  _contractStartDate = null;
                  _contractEndDate = null;
                });
              },
              child: const Text('CLOSE'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit proposal: ${e.toString()}')),
      );
    }
  }

  Widget _buildListTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00C853), size: 20),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00C853),
        title: const Text(
          'Corporate Gas Contracts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Corporate Services Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00C853).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.business_center,
                    color: Color(0xFF00C853),
                    size: 50,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Larry Enterprises Corporate Solutions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tailored gas supply contracts for businesses, hotels, restaurants, and industrial clients',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Benefits Section
            const Text(
              'Benefits of Our Corporate Contracts:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildBenefitItem('Competitive bulk pricing'),
            _buildBenefitItem('Priority delivery scheduling'),
            _buildBenefitItem('Dedicated account manager'),
            _buildBenefitItem('Regular automatic refills'),
            _buildBenefitItem('Equipment leasing options'),
            _buildBenefitItem('24/7 emergency support'),
            const SizedBox(height: 24),

            // Contract Request Form
            const Text(
              'Request a Corporate Proposal:',
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
                  // Company Information
                  TextFormField(
                    controller: _companyNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Company Name',
                      labelStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      prefixIcon: const Icon(Icons.business, color: Colors.white70),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter company name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Contact Person
                  TextFormField(
                    controller: _contactPersonController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Contact Person',
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
                        return 'Please enter contact person';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Contact Information Row
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: const TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[700]!),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF1E1E1E),
                            prefixIcon: const Icon(Icons.email, color: Colors.white70),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter email';
                            }
                            if (!value.contains('@')) {
                              return 'Enter valid email';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _phoneController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Phone',
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
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Business Address
                  TextFormField(
                    controller: _addressController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Business Address',
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
                        return 'Please enter business address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Contract Type Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedContractType,
                    decoration: InputDecoration(
                      labelText: 'Contract Type',
                      labelStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      prefixIcon: const Icon(Icons.assignment, color: Colors.white70),
                    ),
                    items: _contractTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedContractType = value);
                    },
                    validator: (value) =>
                        value == null ? 'Please select contract type' : null,
                  ),
                  const SizedBox(height: 16),

                  // Contract Dates
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Preferred Start Date',
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
                              _contractStartDate == null
                                  ? 'Select date'
                                  : DateFormat('MMM dd, yyyy').format(_contractStartDate!),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Preferred End Date',
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
                              _contractEndDate == null
                                  ? 'Select date'
                                  : DateFormat('MMM dd, yyyy').format(_contractEndDate!),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Estimated Consumption
                  TextFormField(
                    controller: _estimatedConsumptionController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Estimated Monthly Consumption (kg)',
                      labelStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      prefixIcon: const Icon(Icons.scale, color: Colors.white70),
                      suffixText: 'kg/month',
                      suffixStyle: const TextStyle(color: Colors.white70),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please estimate consumption';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Enter valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Special Requirements
                  TextFormField(
                    controller: _specialRequirementsController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Special Requirements',
                      labelStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      prefixIcon: const Icon(Icons.note_add, color: Colors.white70),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitProposal,
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
                              'REQUEST CORPORATE PROPOSAL',
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

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}