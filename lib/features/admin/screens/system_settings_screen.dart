import 'package:ecommerce_app_fluterr_nodejs/common/widgets/custom_button.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/error_handling.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/global_variables.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/utils.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/admin/services/admin_services.dart';
import 'package:ecommerce_app_fluterr_nodejs/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

class SystemSettingsScreen extends StatefulWidget {
  static const String routeName = '/system-settings';
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  final AdminServices _adminServices = AdminServices();
  final _formKey = GlobalKey<FormState>();

  // Controllers for contact information
  final TextEditingController _contactEmailController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final TextEditingController _supportEmailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = false;
  Map<String, dynamic>? _aboutAppData;

  @override
  void initState() {
    super.initState();
    _fetchAboutAppData();
  }

  @override
  void dispose() {
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _supportEmailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchAboutAppData() async {
    setState(() => _isLoading = true);
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/about-app'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          setState(() {
            _aboutAppData = jsonDecode(res.body);
            _contactEmailController.text = _aboutAppData?['contactEmail'] ?? '';
            _contactPhoneController.text = _aboutAppData?['contactPhone'] ?? '';
            _supportEmailController.text = _aboutAppData?['supportEmail'] ?? '';
            _addressController.text = _aboutAppData?['address'] ?? '';
          });
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateContactInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _adminServices.updateAboutApp(
        context: context,
        contactEmail: _contactEmailController.text.trim(),
        contactPhone: _contactPhoneController.text.trim(),
        supportEmail: _supportEmailController.text.trim(),
        address: _addressController.text.trim(),
        onSuccess: () {
          showSnackBar(context, 'Contact information updated successfully');
          _fetchAboutAppData(); // Refresh data
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
      ),
      body: _isLoading && _aboutAppData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Information Section
                  const Text(
                    'App Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text('App Name'),
                            subtitle: Text(_aboutAppData?['appName'] ?? 'Loading...'),
                          ),
                          ListTile(
                            title: const Text('Version'),
                            subtitle: Text(_aboutAppData?['version'] ?? 'Loading...'),
                          ),
                          ListTile(
                            title: const Text('Developer'),
                            subtitle: Text(_aboutAppData?['developer'] ?? 'Loading...'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Contact Information Section
                  const Text(
                    'Contact Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _contactEmailController,
                              decoration: const InputDecoration(
                                labelText: 'Contact Email',
                                hintText: 'support@company.com',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter contact email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _contactPhoneController,
                              decoration: const InputDecoration(
                                labelText: 'Contact Phone',
                                hintText: '+1234567890',
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter contact phone';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _supportEmailController,
                              decoration: const InputDecoration(
                                labelText: 'Support Email',
                                hintText: 'help@company.com',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter support email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _addressController,
                              decoration: const InputDecoration(
                                labelText: 'Business Address',
                                hintText: '123 Business Street, City, Country',
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter business address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            _isLoading
                                ? const CircularProgressIndicator()
                                : CustomButton(
                                    text: 'Update Contact Information',
                                    function: _updateContactInfo,
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // System Status Section
                  const Text(
                    'System Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Server Status'),
                          subtitle: const Text('Online'),
                          trailing: const Icon(Icons.check_circle, color: Colors.green),
                        ),
                        ListTile(
                          title: const Text('Database Status'),
                          subtitle: const Text('Connected'),
                          trailing: const Icon(Icons.check_circle, color: Colors.green),
                        ),
                        ListTile(
                          title: const Text('Maintenance Mode'),
                          trailing: Switch(
                            value: false, // Manage state
                            onChanged: (value) {
                              // Handle maintenance mode toggle
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text('Dark Mode'),
                          trailing: Switch(
                            value: themeProvider.isDarkMode,
                            onChanged: (value) {
                              themeProvider.toggleTheme();
                            },
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
