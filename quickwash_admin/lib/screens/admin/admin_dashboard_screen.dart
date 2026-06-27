import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/glass_decorations.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_input.dart';
import '../../services/local_database.dart';
import '../auth/sign_in_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Map<String, dynamic>> _allProfiles = [];
  List<Map<String, dynamic>> _deliveryBoys = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    AppState().addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    AppState().removeListener(_onAppStateChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onAppStateChanged() {
    if (mounted) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final profiles = await AppState().getAllProfiles();
    final drivers = await AppState().getDeliveryPersonnel();
    if (mounted) {
      setState(() {
        _allProfiles = profiles;
        _deliveryBoys = drivers;
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
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
                child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.secondary, size: 24),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QuickWash Admin',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  Text(
                    'Control Center',
                    style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.secondary),
              onPressed: _loadData,
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              onPressed: _handleLogout,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.secondary,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white38,
            tabs: const [
              Tab(icon: Icon(Icons.receipt_long_rounded), text: 'Orders'),
              Tab(icon: Icon(Icons.people_alt_rounded), text: 'Users'),
              Tab(icon: Icon(Icons.analytics_rounded), text: 'Stats'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildOrdersTab(),
                  _buildUsersTab(),
                  _buildStatsTab(),
                ],
              ),
      ),
    );
  }

  // --- ORDERS TAB ---
  Widget _buildOrdersTab() {
    final orders = AppState().orders;
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            const Text(
              'No orders found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Orders placed by users will appear here.',
              style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final orderId = order['orderId'] as String? ?? 'N/A';
        final serviceName = order['serviceName'] as String? ?? 'Laundry';
        final itemCount = order['itemCount'] as int? ?? 0;
        final price = (order['price'] as num?)?.toDouble() ?? 0.0;
        final status = order['status'] as String? ?? 'Processing';
        final dateTime = order['dateTime'] as String? ?? '';
        final driverId = order['delivery_boy_id'] as String?;
        final emoji = order['emoji'] as String? ?? '🧺';
        final details = order['itemsDetail'] as String? ?? '';

        // Find assigned driver profile name
        final driverName = _deliveryBoys.firstWhere(
          (d) => d['id'] == driverId,
          orElse: () => {'name': 'Unassigned'},
        )['name'] as String;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      orderId,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 15),
                    ),
                    _buildStatusChip(status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '$emoji ',
                      style: const TextStyle(fontSize: 20),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serviceName,
                            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14),
                          ),
                          Text(
                            '$itemCount items • ₹${price.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    details,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ASSIGNED DRIVER',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant, letterSpacing: 1.1),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          driverName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: driverId != null ? Colors.white : Colors.white38,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.local_shipping_rounded, color: AppColors.secondary, size: 20),
                          tooltip: 'Assign Driver',
                          onPressed: () => _showAssignDriverModal(orderId, driverId),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_note_rounded, color: Colors.white70, size: 22),
                          tooltip: 'Change Status',
                          onPressed: () => _showChangeStatusModal(orderId, status),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status) {
      case 'Processing':
        chipColor = Colors.orange;
      case 'Picked Up':
        chipColor = Colors.blue;
      case 'In Process':
        chipColor = Colors.indigo;
      case 'Out for Delivery':
        chipColor = Colors.purple;
      case 'Completed':
        chipColor = Colors.green;
      default:
        chipColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.4), width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(color: chipColor, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showAssignDriverModal(String orderId, String? currentDriverId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1A30),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assign Delivery Partner',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Order: $orderId',
                      style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    if (_deliveryBoys.isEmpty) ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'No delivery personnel profiles found.\nPromote users to "delivery" role first!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      )
                    ] else ...[
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _deliveryBoys.length,
                          itemBuilder: (c, idx) {
                            final driver = _deliveryBoys[idx];
                            final driverId = driver['id'] as String;
                            final name = driver['name'] as String? ?? 'Unnamed';
                            final phone = driver['phone'] as String? ?? '';
                            final isAssigned = currentDriverId == driverId;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.secondary.withOpacity(0.1),
                                child: const Icon(Icons.person, color: AppColors.secondary),
                              ),
                              title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              subtitle: Text(phone, style: const TextStyle(color: Colors.white30, fontSize: 12)),
                              trailing: isAssigned
                                  ? const Icon(Icons.check_circle, color: AppColors.secondary)
                                  : null,
                              onTap: () async {
                                final success = await AppState().assignDeliveryBoy(orderId, driverId);
                                if (success) {
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Delivery partner assigned successfully!')),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    GlassButton(
                      label: 'Remove Assignment',
                      outlined: true,
                      onPressed: currentDriverId == null
                          ? null
                          : () async {
                              final success = await AppState().assignDeliveryBoy(orderId, null);
                              if (success) {
                                if (ctx.mounted) Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Assignment removed.')),
                                );
                              }
                            },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showChangeStatusModal(String orderId, String currentStatus) {
    final statuses = [
      {'name': 'Processing', 'progress': 0.1},
      {'name': 'Picked Up', 'progress': 0.35},
      {'name': 'In Process', 'progress': 0.60},
      {'name': 'Out for Delivery', 'progress': 0.85},
      {'name': 'Completed', 'progress': 1.0},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1A30),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Update Order Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Order: $orderId',
                  style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: statuses.length,
                  itemBuilder: (c, idx) {
                    final statusObj = statuses[idx];
                    final name = statusObj['name'] as String;
                    final progress = statusObj['progress'] as double;
                    final isCurrent = currentStatus == name;

                    return ListTile(
                      title: Text(
                        name,
                        style: TextStyle(
                          color: isCurrent ? AppColors.secondary : Colors.white,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isCurrent ? const Icon(Icons.check, color: AppColors.secondary) : null,
                      onTap: () async {
                        final success = await AppState().updateOrderStatus(orderId, name, progress);
                        if (success) {
                          if (ctx.mounted) Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Order status set to $name.')),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- USERS TAB ---
  Widget _buildUsersTab() {
    if (_allProfiles.isEmpty) {
      return const Center(child: Text('No registered profiles found.', style: TextStyle(color: Colors.white54)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allProfiles.length,
      itemBuilder: (context, index) {
        final profile = _allProfiles[index];
        final id = profile['id'] as String;
        final name = profile['name'] as String? ?? 'Unnamed';
        final email = profile['email'] as String? ?? 'No email';
        final phone = profile['phone'] as String? ?? 'No phone';
        final balance = (profile['balance'] as num?)?.toDouble() ?? 0.0;
        final role = profile['role'] as String? ?? 'customer';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: 16,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          _buildRoleBadge(role),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(email, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      Text(phone.isNotEmpty ? '+91 $phone' : '', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text(
                        'Wallet Balance: ₹${balance.toStringAsFixed(2)}',
                        style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.manage_accounts_rounded, color: AppColors.secondary),
                      tooltip: 'Change Role',
                      onPressed: () => _showChangeRoleModal(id, name, role),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_card_rounded, color: Colors.green),
                      tooltip: 'Top-up Wallet',
                      onPressed: () => _showAddBalanceDialog(id, name, balance),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleBadge(String role) {
    Color badgeColor;
    IconData icon;
    switch (role) {
      case 'admin':
        badgeColor = AppColors.error;
        icon = Icons.admin_panel_settings_rounded;
      case 'delivery':
        badgeColor = AppColors.secondary;
        icon = Icons.local_shipping_rounded;
      default:
        badgeColor = Colors.white54;
        icon = Icons.person_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: badgeColor, size: 10),
          const SizedBox(width: 4),
          Text(
            role.toUpperCase(),
            style: TextStyle(color: badgeColor, fontSize: 9, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showChangeRoleModal(String targetId, String targetName, String currentRole) {
    final roles = ['customer', 'delivery', 'admin'];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1A30),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Change User Role',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'User: $targetName',
                  style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: roles.length,
                  itemBuilder: (c, idx) {
                    final role = roles[idx];
                    final isCurrent = currentRole == role;

                    return ListTile(
                      title: Text(
                        role.toUpperCase(),
                        style: TextStyle(
                          color: isCurrent ? AppColors.secondary : Colors.white,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isCurrent ? const Icon(Icons.check, color: AppColors.secondary) : null,
                      onTap: () async {
                        final success = await AppState().updateAnyUserProfile(targetId, role: role);
                        if (success) {
                          if (ctx.mounted) Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$targetName role set to $role.')),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddBalanceDialog(String targetId, String targetName, double currentBalance) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F1A30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Top-up Wallet: $targetName', style: const TextStyle(color: Colors.white, fontSize: 16)),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter amount (e.g. 500)',
              hintStyle: TextStyle(color: Colors.white30),
              prefixText: '₹',
              prefixStyle: TextStyle(color: AppColors.secondary),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.secondary)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                final input = controller.text.trim();
                final amount = double.tryParse(input);
                if (amount == null || amount <= 0) {
                  return;
                }
                
                final success = await AppState().updateAnyUserProfile(
                  targetId,
                  balance: currentBalance + amount,
                );
                
                if (success) {
                  // Add a transaction record in wallet_transactions table
                  if (AppState().isSupabaseEnabled) {
                    await AppState().supabase.from('wallet_transactions').insert({
                      'user_id': targetId,
                      'type': 'credit',
                      'amount': amount,
                      'description': 'Admin Direct Top-up',
                      'date': 'Admin Added',
                    });
                  }
                  
                  if (ctx.mounted) Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added ₹${amount.toStringAsFixed(2)} to $targetName\'s wallet.')),
                  );
                }
              },
              child: const Text('Add Funds', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- STATS TAB ---
  Widget _buildStatsTab() {
    final orders = AppState().orders;
    
    double totalRevenue = 0.0;
    int completedCount = 0;
    int activeCount = 0;
    
    for (final order in orders) {
      final price = (order['price'] as num?)?.toDouble() ?? 0.0;
      final status = order['status'] as String? ?? '';
      
      if (status == 'Completed') {
        totalRevenue += price;
        completedCount++;
      } else {
        activeCount++;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL REVENUE',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.1, color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${totalRevenue.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL ORDERS',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.1, color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${orders.length}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'COMPLETED',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.1, color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$completedCount',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'IN PROGRESS',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.1, color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$activeCount',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GlassCard(
            padding: const EdgeInsets.all(20),
            borderRadius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Operations Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                _buildSummaryRow(Icons.local_shipping_rounded, 'Active Drivers', '${_deliveryBoys.length} available'),
                _buildSummaryRow(Icons.group_rounded, 'Registered Users', '${_allProfiles.length} profiles'),
                _buildSummaryRow(Icons.check_circle_rounded, 'Completion Rate', 
                    orders.isNotEmpty ? '${((completedCount / orders.length) * 100).toStringAsFixed(0)}%' : '0%'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.secondary.withOpacity(0.1),
            child: Icon(icon, color: AppColors.secondary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
