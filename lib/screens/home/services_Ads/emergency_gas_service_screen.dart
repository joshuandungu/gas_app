import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyGasServiceScreen extends StatelessWidget {
  const EmergencyGasServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00C853),
        title: const Text(
          'Emergency Gas Service',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha((0xFF * 0.2).round()),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withAlpha((0xFF * 0.5).round())),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 50,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '24/7 EMERGENCY SERVICE',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Emergency Contact
            const Text(
              'Immediate Assistance:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: const Color(0xFF1E1E1E),
              child: ListTile(
                leading: const Icon(
                  Icons.phone,
                  color: Colors.red,
                  size: 30,
                ),
                title: const Text(
                  'Emergency Hotline',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Call now for immediate response',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.call, color: Colors.red),
                  onPressed: () => _launchPhone('tel:+1234567890'),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Service Description
            const Text(
              'About Our Emergency Service:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Our emergency gas service is available 24 hours a day, 7 days a week to handle any urgent gas-related issues including:\n\n'
              '• Gas leaks detection and repair\n'
              '• Emergency cylinder replacement\n'
              '• Faulty equipment shutdown\n'
              '• Safety inspections\n'
              '• Immediate supply during outages\n\n'
              'Our certified technicians will respond immediately to ensure your safety and restore your gas supply.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),

            // Emergency Steps
            const Text(
              'In Case of Gas Leak:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildEmergencyStep(1, 'Evacuate the area immediately'),
            _buildEmergencyStep(2, 'Do not operate electrical switches'),
            _buildEmergencyStep(3, 'Avoid open flames or sparks'),
            _buildEmergencyStep(4, 'Call our emergency number from a safe distance'),
            const SizedBox(height: 30),

            // Emergency Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _launchPhone('tel:+1234567890'),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emergency, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'CALL EMERGENCY HOTLINE',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPhone(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}