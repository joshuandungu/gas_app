import 'package:flutter/material.dart';
import 'package:gas/config/app_routes.dart';
import 'package:gas/models/user_model.dart'; // <-- Import your UserModel
import 'package:gas/screens/home/services_Ads/gas_cylinder_delivery_screen.dart';
import 'package:gas/screens/home/services_Ads/gas_installation_maintenance_screen.dart';
import 'package:gas/screens/home/services_Ads/gas_safety_checks_screen.dart';
import 'package:gas/screens/home/services_Ads/emergency_gas_service_screen.dart';
import 'package:gas/screens/home/services_Ads/gas_cylinder_exchange_screen.dart';
import 'package:gas/screens/home/services_Ads/bulk_gas_supply_screen.dart';
import 'package:gas/screens/home/services_Ads/subscription_plans_screen.dart';
import 'package:gas/screens/home/services_Ads/corporate_contracts_screen.dart';

class ServicesScreen extends StatelessWidget {
  final UserModel currentUser;

  const ServicesScreen({Key? key, required this.currentUser}) : super(key: key);

  final List<Map<String, String>> services = const [
    {
      'title': 'Gas Cylinder Delivery',
      'description': 'Fast and reliable doorstep delivery of filled gas cylinders.',
      'icon': 'local_shipping'
    },
    {
      'title': 'Cylinder Exchange',
      'description': 'Swap your empty cylinder for a full one quickly and easily.',
      'icon': 'swap_horiz'
    },
    {
      'title': 'Bulk Gas Supply',
      'description': 'Large volume supply for restaurants, hotels, and industries.',
      'icon': 'business'
    },
    {
      'title': 'Installation & Maintenance',
      'description': 'Professional setup and servicing of gas systems.',
      'icon': 'build'
    },
    {
      'title': 'Gas Safety Checks',
      'description': 'Ensure safe usage with our regular inspection service.',
      'icon': 'security'
    },
    {
      'title': 'Emergency Delivery',
      'description': '24/7 emergency gas delivery service to keep you going.',
      'icon': 'warning'
    },
    {
      'title': 'Subscription Plans',
      'description': 'Pre-scheduled deliveries at discounted rates.',
      'icon': 'schedule'
    },
    {
      'title': 'Corporate Contracts',
      'description': 'Tailored gas supply solutions for businesses.',
      'icon': 'work'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00C853),
        title: const Text(
          'Our Services',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Card(
            color: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF00C853).withOpacity(0.2),
                child: Icon(
                  _getIconData(service['icon']!),
                  color: const Color(0xFF00C853),
                ),
              ),
              title: Text(
                service['title']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                service['description']!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              onTap: () {
                switch (service['title']) {
                  case 'Gas Cylinder Delivery':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GasCylinderDeliveryScreen(),
                      ),
                    );
                    break;
                  case 'Cylinder Exchange':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GasCylinderExchangeScreen(
                          currentUser: currentUser,
                        ),
                      ),
                    );
                    break;
                  case 'Bulk Gas Supply':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BulkGasSupplyScreen(
                          currentUser: currentUser,
                        ),
                      ),
                    );
                    break;
                  case 'Installation & Maintenance':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GasInstallationMaintenanceScreen(),
                      ),
                    );
                    break;
                  case 'Gas Safety Checks':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GasSafetyChecksScreen(),
                      ),
                    );
                    break;
                  case 'Emergency Delivery':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmergencyGasServiceScreen(),
                      ),
                    );
                    break;
                  case 'Subscription Plans':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SubscriptionPlansScreen(),
                      ),
                    );
                    break;
                  case 'Corporate Contracts':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CorporateContractsScreen(),
                      ),
                    );
                    break;
                }
              },
            ),
          );
        },
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'local_shipping':
        return Icons.local_shipping;
      case 'swap_horiz':
        return Icons.swap_horiz;
      case 'business':
        return Icons.business;
      case 'build':
        return Icons.build;
      case 'security':
        return Icons.security;
      case 'warning':
        return Icons.warning;
      case 'schedule':
        return Icons.schedule;
      case 'work':
        return Icons.work;
      default:
        return Icons.help_outline;
    }
  }
}
