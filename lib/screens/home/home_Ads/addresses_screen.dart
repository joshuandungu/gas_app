import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final List<Map<String, dynamic>> _addresses = [];
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;

  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services.')),
      );
      return;
    }

    // Check for permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Location permissions are permanently denied. Please enable them from settings.')),
      );
      return;
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _selectedLocation = LatLng(position.latitude, position.longitude);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
      );
    });
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _addresses.add({
          'address': _addressController.text,
          'location': _selectedLocation,
        });
        _addressController.clear();
        _selectedLocation = null;
      });
      Navigator.pop(context);
    }
  }

  void _showAddAddressDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add New Address',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address Description',
                      hintText: 'e.g. Home, Office, etc.',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter address description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 200,
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(-1.286389, 36.817223), // Nairobi default
                        zoom: 12,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      onTap: (LatLng position) {
                        setState(() {
                          _selectedLocation = position;
                        });
                      },
                      markers: _selectedLocation != null
                          ? {
                              Marker(
                                markerId: const MarkerId('selected'),
                                position: _selectedLocation!,
                              ),
                            }
                          : {},
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _getCurrentLocation,
                          icon: const Icon(Icons.my_location),
                          label: const Text('Use My Location'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveAddress,
                      child: const Text('Save Address'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Addresses'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _addresses.isEmpty
          ? const Center(
              child: Text(
                'No saved addresses yet.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final address = _addresses[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.green),
                    title: Text(address['address']),
                    subtitle: address['location'] != null
                        ? Text(
                            'Lat: ${address['location'].latitude}, Lng: ${address['location'].longitude}',
                            style: const TextStyle(fontSize: 12),
                          )
                        : null,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAddressDialog,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add_location_alt),
      ),
    );
  }
}
