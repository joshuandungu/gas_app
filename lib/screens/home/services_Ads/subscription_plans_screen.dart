import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gas/services/api_service.dart';
import 'package:gas/providers/auth_provider.dart';
import 'package:gas/models/user_model.dart';
import 'package:provider/provider.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState extends State<SubscriptionPlansScreen> {
  List<dynamic> _plans = [];
  bool _isLoading = true;
  bool _isSubscribing = false;
  String? _selectedPlanId;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchSubscriptionPlans();
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  Future<void> _fetchSubscriptionPlans() async {
    try {
      final List<dynamic> fetchedPlans = await ApiService.get('subscription-plans');

      if (!mounted) return;
      setState(() {
        _plans = fetchedPlans;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching plans: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _subscribeToPlan(String planId) async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to subscribe'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubscribing = true);

    try {
      // Get current user from AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user;

      final body = {
        'userId': _userId,
        'planId': planId,
        'subscriptionDate': DateTime.now().toIso8601String(),
      };

      await ApiService.post('subscriptions', body);

      if (currentUser != null) {
        // Create notification data
        final notificationData = {
          'user_id': currentUser.id,
          'title': 'New Subscription',
          'body': 'You have successfully subscribed to a new plan!',
        };
        // Send notification to backend
        await ApiService.post('notifications', notificationData);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subscription successful!'),
          backgroundColor: Colors.green,
        ),
      );
      // Refresh plans to show updated subscription status
      _fetchSubscriptionPlans();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Subscription error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubscribing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00C853),
        title: const Text(
          'Subscription Plans',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose Your Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Subscribe and enjoy regular deliveries at discounted rates',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Plans List
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _plans.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final plan = _plans[index];
                      return _buildPlanCard(plan);
                    },
                  ),

                  const SizedBox(height: 32),
                  // How It Works Section
                  const Text(
                    'How Subscription Works:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStepItem(1, 'Choose your preferred plan'),
                  _buildStepItem(2, 'Complete the subscription process'),
                  _buildStepItem(3, 'Get regular deliveries as scheduled'),
                  _buildStepItem(4, 'Modify or cancel anytime'),
                ],
              ),
            ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final isSelected = _selectedPlanId == plan['id'];
    final isSubscribed = plan['isSubscribed'] == true;

    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF00C853) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isSubscribed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              plan['description'],
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.local_shipping, color: Color(0xFF00C853), size: 20),
                const SizedBox(width: 8),
                Text(
                  '${plan['deliveriesPerMonth']} deliveries/month',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.money, color: Color(0xFF00C853), size: 20),
                const SizedBox(width: 8),
                Text(
                  '${plan['discountPercentage']}% discount per delivery',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF00C853), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Billed ${plan['billingCycle']}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'KES ${plan['price'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isSubscribed)
                  ElevatedButton(
                    onPressed: _isSubscribing
                        ? null
                        : () {
                            setState(() => _selectedPlanId = plan['id']);
                            _subscribeToPlan(plan['id']);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubscribing && _selectedPlanId == plan['id']
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Subscribe'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(int stepNumber, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF00C853),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                stepNumber.toString(),
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
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}