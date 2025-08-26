import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:gas/services/api_service.dart';
import 'package:gas/providers/auth_provider.dart';
import 'package:provider/provider.dart';

const String BACKEND_BASE = 'http://192.168.40.70:5000'; // Change to your backend server

class PostGasScreen extends StatefulWidget {
  const PostGasScreen({Key? key}) : super(key: key);

  @override
  State<PostGasScreen> createState() => _PostGasScreenState();
}

class _PostGasScreenState extends State<PostGasScreen> {
  final _formKey = GlobalKey<FormState>();

  // Common fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Category-specific
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _minOrderQtyController = TextEditingController();
  final TextEditingController _deliveryFeeController = TextEditingController();
  final TextEditingController _subscriptionPlanController = TextEditingController();
  final TextEditingController _corporateContactController = TextEditingController();

  // Vendor details
  final TextEditingController _vendorShopNameController = TextEditingController();
  final TextEditingController _vendorPhoneController = TextEditingController();

  // Promo fields
  final TextEditingController _promoPercentageController = TextEditingController();
  final TextEditingController _promoDescriptionController = TextEditingController();
  final TextEditingController _promoEndDateController = TextEditingController();
  DateTime? _promoEndDate;

  String? _selectedCategory;
  final List<String> _categories = [
    "Gas Product",
    "Bulk Gas Supply",
    "Cylinder Exchange",
    "Cylinder Delivery",
    "Subscription Plan",
    "Corporate Supply"
  ];

  XFile? _pickedFile;
  Uint8List? _pickedBytes;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _minOrderQtyController.dispose();
    _deliveryFeeController.dispose();
    _subscriptionPlanController.dispose();
    _corporateContactController.dispose();
    _vendorShopNameController.dispose();
    _vendorPhoneController.dispose();
    _promoPercentageController.dispose();
    _promoDescriptionController.dispose();
    _promoEndDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (file == null) return;

      setState(() => _pickedFile = file);

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        setState(() => _pickedBytes = bytes);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image pick failed: $e')));
    }
  }

  Future<void> _selectPromoEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _promoEndDate = picked;
        _promoEndDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  /// Map category → backend endpoint
  String _getApiEndpoint(String category) {
    switch (category) {
      case "Gas Product":
        return "$BACKEND_BASE/api/gas-products";
      case "Bulk Gas Supply":
        return "$BACKEND_BASE/api/bulk-gas";
      case "Cylinder Exchange":
        return "$BACKEND_BASE/api/cylinder-exchange";
      case "Cylinder Delivery":
        return "$BACKEND_BASE/api/cylinder-delivery";
      case "Subscription Plan":
        return "$BACKEND_BASE/api/subscriptions";
      case "Corporate Supply":
        return "$BACKEND_BASE/api/corporate-supply".trim();
      default:
        return "$BACKEND_BASE/api/posts".trim(); // fallback
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final Map<String, String> fields = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': _priceController.text.trim(),
        'location': _locationController.text.trim(),
        'category': _selectedCategory ?? 'Gas Product',
        'capacity': _capacityController.text.trim(),
        'minOrderQty': _minOrderQtyController.text.trim(),
        'deliveryFee': _deliveryFeeController.text.trim(),
        'subscriptionPlan': _subscriptionPlanController.text.trim(),
        'corporateContact': _corporateContactController.text.trim(),
        'vendorShopName': _vendorShopNameController.text.trim(),
        'vendorPhone': _vendorPhoneController.text.trim(),
        'promoPercentage': _promoPercentageController.text.trim(),
        'promoDescription': _promoDescriptionController.text.trim(),
        'promoEndDate': _promoEndDate?.toIso8601String() ?? '',
        'promoIsActive': _promoPercentageController.text.trim().isNotEmpty ? 'true' : 'false',
      };

      final uri = Uri.parse(_getApiEndpoint(_selectedCategory ?? "Gas Product"));
      final request = http.MultipartRequest('POST', uri);
      request.fields.addAll(fields);

      if (_pickedFile != null) {
        if (kIsWeb && _pickedBytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'image',
            _pickedBytes!,
            filename: _pickedFile!.name,
            contentType: _getMediaType(_pickedFile!.name),
          ));
        } else if (!kIsWeb) {
          final file = File(_pickedFile!.path);
          final stream = http.ByteStream(Stream.castFrom(file.openRead()));
          request.files.add(http.MultipartFile(
            'image',
            stream,
            await file.length(),
            filename: _pickedFile!.path.split('/').last,
          ));
        }
      }

      final resp = await request.send();
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        // Get current user from AuthProvider
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentUser = authProvider.user;

        if (currentUser != null) {
          // Create notification data
          final notificationData = {
            'user_id': currentUser.id,
            'title': 'New Product Posted',
            'body': '${_titleController.text.trim()} has been posted by ${currentUser.fullName}',
          };
          // Send notification to backend
          await ApiService.post('notifications', notificationData);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post saved successfully!')),
        );
        _resetForm();
      } else {
        final respText = await resp.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backend error: ${resp.statusCode} - $respText')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _locationController.clear();
    _capacityController.clear();
    _minOrderQtyController.clear();
    _deliveryFeeController.clear();
    _subscriptionPlanController.clear();
    _corporateContactController.clear();
    _vendorShopNameController.clear();
    _vendorPhoneController.clear();
    _promoPercentageController.clear();
    _promoDescriptionController.clear();
    _promoEndDateController.clear();
    setState(() {
      _pickedFile = null;
      _pickedBytes = null;
      _selectedCategory = null;
      _promoEndDate = null;
    });
  }

  MediaType _getMediaType(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  Widget _categoryFields() {
    switch (_selectedCategory) {
      case 'Bulk Gas Supply':
        return Column(
          children: [
            TextFormField(
              controller: _capacityController,
              decoration: const InputDecoration(labelText: 'Capacity (Liters)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _minOrderQtyController,
              decoration: const InputDecoration(labelText: 'Minimum Order Qty'),
              keyboardType: TextInputType.number,
            ),
          ],
        );
      case 'Cylinder Exchange':
        return TextFormField(
          controller: _capacityController,
          decoration: const InputDecoration(labelText: 'Cylinder Size (Kg)'),
          keyboardType: TextInputType.number,
        );
      case 'Cylinder Delivery':
        return TextFormField(
          controller: _deliveryFeeController,
          decoration: const InputDecoration(labelText: 'Delivery Fee'),
          keyboardType: TextInputType.number,
        );
      case 'Subscription Plan':
        return TextFormField(
          controller: _subscriptionPlanController,
          decoration: const InputDecoration(labelText: 'Subscription Plan Details'),
        );
      case 'Corporate Supply':
        return TextFormField(
          controller: _corporateContactController,
          decoration: const InputDecoration(labelText: 'Corporate Contact Info'),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPromoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Promotional Offer (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _promoPercentageController,
          decoration: const InputDecoration(
            labelText: 'Discount Percentage',
            hintText: 'e.g. 20 for 20% off',
            suffixText: '%',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final percent = int.tryParse(value);
              if (percent == null || percent < 0 || percent > 100) {
                return 'Enter 0-100';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _promoDescriptionController,
          decoration: const InputDecoration(
            labelText: 'Promo Description',
            hintText: 'e.g. "Summer special discount"',
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _promoEndDateController,
          decoration: InputDecoration(
            labelText: 'Promo End Date',
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _selectPromoEndDate,
            ),
          ),
          readOnly: true,
          onTap: _selectPromoEndDate,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Gas / Service'),
        backgroundColor: primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AbsorbPointer(
          absorbing: _isSubmitting,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: _pickedFile == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_a_photo, size: 36, color: Colors.grey),
                              SizedBox(height: 6),
                              Text('Tap to pick image')
                            ],
                          )
                        : kIsWeb
                            ? Image.memory(_pickedBytes ?? Uint8List(0), fit: BoxFit.cover)
                            : Image.file(File(_pickedFile!.path), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                  validator: (v) => v == null ? 'Select a category' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _vendorShopNameController,
                  decoration: const InputDecoration(labelText: 'Shop Name (optional)'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _vendorPhoneController,
                  decoration: const InputDecoration(labelText: 'Phone (optional)'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _categoryFields(),
                _buildPromoSection(),
                const SizedBox(height: 18),
                if (_isSubmitting)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: primary,
                    ),
                    child: const Text('POST', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
