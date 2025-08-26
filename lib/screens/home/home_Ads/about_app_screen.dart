import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About App'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo / Banner
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.local_gas_station,
                    color: Theme.of(context).primaryColor,
                    size: 80,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Larry Enterprises (LA)',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Your Trusted Online Gas Ordering App in Kenya',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // About section
            const Text(
              'About Larry Enterprises (LA)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Larry Enterprises is a Kenyan-based company revolutionizing the way '
              'households and businesses order cooking gas. Through our mobile app, '
              'customers can easily place gas orders, track deliveries, and enjoy fast, '
              'reliable service across major towns and cities in Kenya.',
              style: TextStyle(fontSize: 15, height: 1.4),
            ),

            const SizedBox(height: 20),

            // Features
            const Text(
              'Key Features',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFeature(
              icon: Icons.shopping_cart_outlined,
              title: 'Easy Ordering',
              description: 'Order gas in just a few taps without leaving your home.',
              context: context,
            ),
            _buildFeature(
              icon: Icons.delivery_dining,
              title: 'Fast Delivery',
              description: 'Get your gas delivered quickly to your doorstep.',
              context: context,
            ),
            _buildFeature(
              icon: Icons.payment_outlined,
              title: 'Flexible Payments',
              description: 'Pay via M-Pesa, bank transfer, or cash on delivery.',
              context: context,
            ),
            _buildFeature(
              icon: Icons.location_on_outlined,
              title: 'Nationwide Coverage',
              description: 'Available in Nairobi, Mombasa, Kisumu, Eldoret, Nakuru, and more.',
              context: context,
            ),

            const SizedBox(height: 20),

            // Vision
            const Text(
              'Our Vision',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'To become Kenya’s most trusted and convenient gas delivery platform, '
              'empowering households and businesses with safe, affordable, and accessible energy.',
              style: TextStyle(fontSize: 15, height: 1.4),
            ),

            const SizedBox(height: 20),

            // Contact info
            const Text(
              'Contact Us',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildContactRow(Icons.phone, '+254 712 345 678'),
            _buildContactRow(Icons.email_outlined, 'support@larryenterprises.co.ke'),
            _buildContactRow(Icons.location_city, 'Nairobi, Kenya'),

            const SizedBox(height: 40),

            // Footer
            Center(
              child: Text(
                '© ${DateTime.now().year} Larry Enterprises. All Rights Reserved.',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildFeature({
    required IconData icon,
    required String title,
    required String description,
    required BuildContext context,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(description),
    );
  }

  static Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
