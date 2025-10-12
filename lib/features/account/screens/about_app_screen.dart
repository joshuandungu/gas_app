import 'package:ecommerce_app_fluterr_nodejs/features/account/services/account_services.dart';
import 'package:ecommerce_app_fluterr_nodejs/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AboutAppScreen extends StatefulWidget {
  static const String routeName = '/about-app';
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  final AccountServices accountServices = AccountServices();
  Map<String, String> aboutData = {};
  bool isLoading = true;
  bool isEditing = false;

  final TextEditingController _appNameController = TextEditingController();
  final TextEditingController _versionController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _developerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAboutData();
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _versionController.dispose();
    _descriptionController.dispose();
    _developerController.dispose();
    super.dispose();
  }

  Future<void> _fetchAboutData() async {
    setState(() => isLoading = true);
    aboutData = await accountServices.fetchAboutApp(context);
    if (mounted) {
      setState(() {
        isLoading = false;
        _appNameController.text = aboutData['appName'] ?? 'Revos E-commerce App';
        _versionController.text = aboutData['version'] ?? '1.0.0';
        _descriptionController.text = aboutData['description'] ?? 'This app allows you to shop from various sellers, manage your orders, and more.';
        _developerController.text = aboutData['developer'] ?? 'Your Company';
      });
    }
  }

  Future<void> _saveAboutData() async {
    final updatedData = {
      'appName': _appNameController.text,
      'version': _versionController.text,
      'description': _descriptionController.text,
      'developer': _developerController.text,
    };
    await accountServices.updateAboutApp(context, updatedData);
    setState(() {
      aboutData = updatedData;
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final isAdmin = user.type == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('About App'),
        actions: isAdmin && !isLoading
            ? [
                IconButton(
                  icon: Icon(isEditing ? Icons.save : Icons.edit),
                  onPressed: () {
                    if (isEditing) {
                      _saveAboutData();
                    } else {
                      setState(() => isEditing = true);
                    }
                  },
                ),
              ]
            : null,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isEditing && isAdmin
                      ? TextField(
                          controller: _appNameController,
                          decoration: const InputDecoration(labelText: 'App Name'),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        )
                      : Text(
                          _appNameController.text,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                  const SizedBox(height: 16),
                  isEditing && isAdmin
                      ? TextField(
                          controller: _versionController,
                          decoration: const InputDecoration(labelText: 'Version'),
                          style: const TextStyle(fontSize: 16),
                        )
                      : Text(
                          'Version: ${_versionController.text}',
                          style: const TextStyle(fontSize: 16),
                        ),
                  const SizedBox(height: 16),
                  isEditing && isAdmin
                      ? TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(labelText: 'Description'),
                          maxLines: 3,
                          style: const TextStyle(fontSize: 16),
                        )
                      : Text(
                          _descriptionController.text,
                          style: const TextStyle(fontSize: 16),
                        ),
                  const SizedBox(height: 16),
                  isEditing && isAdmin
                      ? TextField(
                          controller: _developerController,
                          decoration: const InputDecoration(labelText: 'Developed by'),
                          style: const TextStyle(fontSize: 16),
                        )
                      : Text(
                          'Developed by: ${_developerController.text}',
                          style: const TextStyle(fontSize: 16),
                        ),
                ],
              ),
            ),
    );
  }
}
