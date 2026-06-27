import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/glass_decorations.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_button.dart';
import '../../services/local_database.dart';
import '../auth/sign_in_screen.dart';

class DeliveryDashboardScreen extends StatefulWidget {
  const DeliveryDashboardScreen({super.key});

  @override
  State<DeliveryDashboardScreen> createState() => _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends State<DeliveryDashboardScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    AppState().addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    AppState().removeListener(_onAppStateChanged);
    super.dispose();
  }

  void _onAppStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleLogout() async {
    await AppState().logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    // Reload state which triggers fetching assigned orders
    if (AppState().isSupabaseEnabled) {
      await AppState().init(); 
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final assignedOrders = AppState().orders;
    final driverName = AppState().currentUser?['name'] ?? 'Partner';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF090E1C),
            Color(0xFF0E1322),
            Color(0xFF161B2B),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: const Color(0xFF090E1C).withOpacity(0.6),
          elevation: 0,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                ),
                child: const Icon(Icons.delivery_dining_rounded, color: AppColors.secondary, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, $driverName',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const Text(
                    'Delivery Partner Dashboard',
                    style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.secondary),
              onPressed: _refreshData,
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              onPressed: _handleLogout,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
            : RefreshIndicator(
                onRefresh: _refreshData,
                color: AppColors.secondary,
                backgroundColor: const Color(0xFF0F1A30),
                child: assignedOrders.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: assignedOrders.length,
                        itemBuilder: (context, index) {
                          final order = assignedOrders[index];
                          return _buildOrderCard(order);
                        },
                      ),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_turned_in_outlined, size: 72, color: Colors.white.withOpacity(0.2)),
              const SizedBox(height: 16),
              const Text(
                'No assigned tasks',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'When the admin assigns a pickup or delivery to you, it will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderId = order['orderId'] as String? ?? 'N/A';
    final serviceName = order['serviceName'] as String? ?? 'Laundry';
    final itemCount = order['itemCount'] as int? ?? 0;
    final price = (order['price'] as num?)?.toDouble() ?? 0.0;
    final status = order['status'] as String? ?? 'Processing';
    final emoji = order['emoji'] as String? ?? '🧺';
    final itemsDetail = order['itemsDetail'] as String? ?? '';
    final paymentMethod = order['paymentMethod'] as String? ?? 'Cash on Delivery';

    final pickupDate = order['pickupDate'] as String? ?? 'Today';
    final pickupTime = order['pickupTime'] as String? ?? 'Flexible';
    final dropoffDate = order['dropoffDate'] as String? ?? 'Within 48h';
    final dropoffTime = order['dropoffTime'] as String? ?? 'Flexible';

    // Address and contact details (mocked or loaded from profile)
    final clientPhone = order['userPhone'] as String? ?? '9876543210';
    final clientAddress = AppState().currentUser?['address'] ?? 'Sector 45, Gurgaon, Haryana, 122003';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderId,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 16),
                ),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 12),

            // Service & Items
            Row(
              children: [
                Text(
                  '$emoji ',
                  style: const TextStyle(fontSize: 24),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceName,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15),
                      ),
                      Text(
                        '$itemCount Items • ₹${price.toStringAsFixed(2)} • $paymentMethod',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (itemsDetail.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                itemsDetail,
                style: const TextStyle(color: Colors.white30, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 12),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 12),

            // Schedule info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PICKUP',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant, letterSpacing: 1.1),
                      ),
                      Text(
                        '$pickupDate • $pickupTime',
                        style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DELIVERY',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant, letterSpacing: 1.1),
                      ),
                      Text(
                        '$dropoffDate • $dropoffTime',
                        style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 12),

            // Address & Maps / Calls
            const Text(
              'CLIENT ADDRESS',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant, letterSpacing: 1.1),
            ),
            const SizedBox(height: 4),
            Text(
              clientAddress,
              style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.3),
            ),
            const SizedBox(height: 12),

            // Action Buttons (Call, Navigate, Update Status)
            Row(
              children: [
                // Call Client
                IconButton(
                  icon: const Icon(Icons.phone_rounded, color: Colors.green),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.1),
                    padding: const EdgeInsets.all(12),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling customer: +91 $clientPhone (Mocked)')),
                    );
                  },
                ),
                const SizedBox(width: 8),

                // Map route
                IconButton(
                  icon: const Icon(Icons.map_rounded, color: AppColors.secondary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.secondary.withOpacity(0.1),
                    padding: const EdgeInsets.all(12),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening Navigation Route to: $clientAddress (Mocked)')),
                    );
                  },
                ),
                const SizedBox(width: 12),

                // Update Status Button
                Expanded(
                  child: _buildActionButton(orderId, status),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    switch (status) {
      case 'Processing':
        badgeColor = Colors.orange;
      case 'Picked Up':
        badgeColor = Colors.blue;
      case 'In Process':
        badgeColor = Colors.indigo;
      case 'Out for Delivery':
        badgeColor = Colors.purple;
      case 'Completed':
        badgeColor = Colors.green;
      default:
        badgeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withOpacity(0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActionButton(String orderId, String status) {
    String label = '';
    String nextStatus = '';
    double nextProgress = 0.0;
    Color buttonColor = AppColors.secondary;

    if (status == 'Processing') {
      label = 'Mark Picked Up';
      nextStatus = 'Picked Up';
      nextProgress = 0.35;
      buttonColor = Colors.blue;
    } else if (status == 'Picked Up') {
      label = 'Mark In Process';
      nextStatus = 'In Process';
      nextProgress = 0.60;
      buttonColor = Colors.indigo;
    } else if (status == 'In Process') {
      label = 'Mark Out for Delivery';
      nextStatus = 'Out for Delivery';
      nextProgress = 0.85;
      buttonColor = Colors.purple;
    } else if (status == 'Out for Delivery') {
      label = 'Mark Delivered';
      nextStatus = 'Completed';
      nextProgress = 1.0;
      buttonColor = Colors.green;
    } else {
      // Completed, disable action
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              SizedBox(width: 8),
              Text(
                'Task Completed',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return GlassButton(
      label: label,
      onPressed: () async {
        final success = await AppState().updateOrderStatus(orderId, nextStatus, nextProgress);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order status updated to $nextStatus.')),
          );
        }
      },
    );
  }
}
