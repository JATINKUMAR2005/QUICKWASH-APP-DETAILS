import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_app_bar.dart';
import '../../models/notification_model.dart';
import '../../services/local_database.dart';
import '../payment/order_tracking_screen.dart';
import '../home/promos_screen.dart';
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _getIconForStatus(String? status) {
    switch (status) {
      case 'Processing': return Icons.sync_rounded;
      case 'Picked Up': return Icons.local_shipping_outlined;
      case 'In Process': return Icons.local_laundry_service_outlined;
      case 'Out for Delivery': return Icons.directions_bike_rounded;
      case 'Completed': return Icons.check_circle_outline;
      default: return Icons.notifications_none_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final notifications = appState.notifications;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: const GlassAppBar(
            avatarUrl:
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCKRTE9bK_hyA9-2U9HmReb_l9KQ4vQGsWt2sqIRc3YTyfdcFE6NdId_kV9OhrshxJYWakj7S2pf-fcloGfukf4lCIGH6Wvilgvvg6ubQrnI7f1FBhHh3iEqKgfzxIQPM9_0kWRjC5nZU26sSkNZfL06nqJtOT5EsAbxJnjvMHc5AVYcx-OFwPlYrHYsP6c75-ye-6drm2tfhDitWUUK90-PPloCAwNNc4CYcwKnnTG0mN0_RH4nq98-sPICSlJhgjwYqt8t_AZRl0',
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20).copyWith(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alerts',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stay updated with your latest laundry activities\nand exclusive offers.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                // Notification cards
                if (notifications.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Text(
                        'No alerts or notifications yet.',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  ...notifications.map((n) {
                    final status = n['status'] as String?;
                    final title = n['title'] as String? ?? 'Alert';
                    final description = n['description'] as String? ?? '';
                    final timeAgo = n['timeAgo'] as String? ?? 'Just now';

                    final model = NotificationModel(
                      title: title,
                      description: description,
                      timeAgo: timeAgo,
                      icon: _getIconForStatus(status),
                      actionLabel: (status != null && status != 'Completed') ? 'Track Live' : null,
                      hasIndicator: true,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _NotificationCard(notification: model),
                    );
                  }),
                const SizedBox(height: 8),
                // Premium service promo
                GlassCard(
                  borderRadius: 16,
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF0D4B6E),
                              const Color(0xFF0A2540),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: 16,
                              bottom: 16,
                              child: Icon(
                                Icons.dry_cleaning_rounded,
                                size: 48,
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'PREMIUM DRY CLEANING',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Premium Dry Cleaning',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Special care for your premium woolens, silks, and delicates. Get them returned fresh and pristine within 48 hours.',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 14),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const PromosScreen()),
                                );
                              },
                              child: const Text(
                                'Explore Premium Services →',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Refer & Earn
                GlassCard(
                  borderRadius: 16,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.card_giftcard_rounded,
                        size: 40,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Refer & Earn',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Get ₹500 for every friend you refer to\nQuickWash.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Share link: quickwash.in/refer/JATIN500'),
                              backgroundColor: AppColors.secondary,
                            ),
                          );
                        },
                        child: Text(
                          'Invite Friends',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.glassBorder,
                width: 1,
              ),
            ),
            child: Icon(
              notification.icon,
              color: AppColors.onSurface,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          notification.timeAgo,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (notification.hasIndicator)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notification.description,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                if (notification.actionLabel != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (notification.actionLabel != null)
                        GestureDetector(
                          onTap: () => _handleAction(context, notification.actionLabel!),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.gradientBlueStart,
                                  AppColors.gradientCyanEnd,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              notification.actionLabel!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      if (notification.secondaryActionLabel != null) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _handleAction(context, notification.secondaryActionLabel!),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.glassBorder,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              notification.secondaryActionLabel!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                // Delivery person chip for delivery notifications
                if (notification.title.contains('Delivery')) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.surfaceContainerHigh,
                          child: const Icon(
                            Icons.person,
                            size: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Marcus is on his way',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'Track Live':
        final appState = AppState();
        final userOrders = appState.getUserOrders();
        final activeOrder = userOrders.firstWhere(
          (o) => o['status'] != 'Completed',
          orElse: () => userOrders.isNotEmpty ? userOrders.first : <String, dynamic>{},
        );
        if (activeOrder.isNotEmpty) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OrderTrackingScreen(
                orderId: activeOrder['orderId'] as String,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No active orders to track.'),
              backgroundColor: AppColors.onSurfaceVariant,
            ),
          );
        }
        break;
      case 'Claim Offer':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PromosScreen()),
        );
        break;
      case 'Details':
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF0F1A30),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Offer Details', style: TextStyle(color: AppColors.onSurface)),
            content: const Text(
              '20% off on all ethnic wear dry cleaning services.\n\n'
              'Use code: ETHNIC20\n'
              'Min order: ₹300\n'
              'Valid till: 30 Jun 2026\n\n'
              'Applicable on Saree, Kurta, Lehenga & Sherwani.',
              style: TextStyle(color: AppColors.onSurfaceVariant, height: 1.6),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close', style: TextStyle(color: AppColors.secondary)),
              ),
            ],
          ),
        );
        break;
    }
  }
}
