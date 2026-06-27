import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_app_bar.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailScreen({super.key, required this.order});

  Color get _statusColor {
    switch (order['status']) {
      case 'Out for Delivery':
        return AppColors.success;
      case 'Processing':
        return AppColors.primaryContainer;
      case 'Picked Up':
        return AppColors.secondary;
      case 'In Process':
        return AppColors.primary;
      case 'Completed':
        return AppColors.success;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = (order['price'] as num).toDouble();
    final paymentMethod = order['paymentMethod'] as String? ?? 'Cash on Delivery';
    final cartSnapshot = order['cartSnapshot'] as List<dynamic>? ?? [];
    final itemsDetail = order['itemsDetail'] as String? ?? '';
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [Color(0xFF0A1535), Color(0xFF0A0F1E)],
          ),
        ),
        child: Column(
          children: [
            const GlassAppBar(
              title: 'Order Details',
              showBack: true,
              showAvatar: false,
              showNotification: false,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Header
                    GlassCard(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ORDER ID',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.2,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      order['orderId'] as String? ?? '#QW-1000',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _statusColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      order['status'] as String? ?? 'Completed',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 6),
                              Text(
                                order['dateTime'] as String? ?? '',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Items Section
                    const Text(
                      'Items Ordered',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (cartSnapshot.isNotEmpty)
                      ...cartSnapshot.map((item) {
                        final itemName = item['item'] as String? ?? 'Item';
                        final emoji = item['emoji'] as String? ?? '🧺';
                        final category = item['category'] as String? ?? '';
                        final qty = item['quantity'] as int? ?? 1;
                        final itemPrice = (item['price'] as num?)?.toDouble() ?? 0.0;
                        final services = (item['services'] as List?)?.cast<String>() ?? [];
                        final servicesCount = services.length;
                        final serviceMultiplier = servicesCount > 0 ? (1.0 + (servicesCount - 1) * 0.5) : 1.0;
                        final totalItemPrice = qty * itemPrice * serviceMultiplier;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GlassCard(
                            padding: const EdgeInsets.all(14),
                            optimizePerformance: true,
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$itemName  ×$qty',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                      if (category.isNotEmpty)
                                        Text(
                                          category,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      if (services.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: services.map((s) => Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.secondary.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                s,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.secondary,
                                                ),
                                              ),
                                            )).toList(),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₹${totalItemPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      })
                    else if (itemsDetail.isNotEmpty)
                      // Fallback: parse the itemsDetail string
                      ..._parseItemsDetail(itemsDetail).map((parsedItem) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GlassCard(
                            padding: const EdgeInsets.all(14),
                            optimizePerformance: true,
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Text('🧺', style: TextStyle(fontSize: 18)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    parsedItem,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                    // Scheduled Slots Section
                    if (order['pickupDate'] != null && order['dropoffDate'] != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'SCHEDULED TIMESLOTS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GlassCard(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.drive_eta_rounded, color: AppColors.secondary, size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Pickup Schedule',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${order['pickupDate']} @ ${order['pickupTime']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white10, height: 24),
                            Row(
                              children: [
                                const Icon(Icons.local_shipping_rounded, color: AppColors.success, size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Delivery Schedule',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${order['dropoffDate']} @ ${order['dropoffTime']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Payment & Total Section
                    GlassCard(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildReceiptRow('PAYMENT METHOD', paymentMethod),
                          const Divider(color: Colors.white10, height: 24),
                          _buildReceiptRow('ITEMS', '${order['itemCount']} items'),
                          const SizedBox(height: 10),
                          _buildReceiptRow('SERVICE', order['serviceName'] as String? ?? 'General'),
                          const Divider(color: Colors.white10, height: 24),
                          _buildReceiptRow(
                            'TOTAL PAID',
                            '₹${price.toStringAsFixed(2)}',
                            isHighlight: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Bottom Bar - Download Receipt
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                border: Border(
                  top: BorderSide(
                    color: AppColors.glassBorder,
                    width: 1,
                  ),
                ),
              ),
              child: GlassButton(
                label: '📄 Download Receipt',
                onPressed: () => _showReceiptDialog(context, price, paymentMethod),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _parseItemsDetail(String detail) {
    return detail.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  void _showReceiptDialog(BuildContext context, double price, String paymentMethod) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F1A30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: AppColors.secondary, size: 24),
              const SizedBox(width: 10),
              const Text('Order Receipt', style: TextStyle(color: AppColors.onSurface, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: Colors.white10),
                _receiptLine('Order ID', order['orderId'] as String? ?? ''),
                _receiptLine('Date', order['dateTime'] as String? ?? ''),
                _receiptLine('Status', order['status'] as String? ?? ''),
                _receiptLine('Items', '${order['itemCount']} items'),
                _receiptLine('Service', order['serviceName'] as String? ?? ''),
                _receiptLine('Payment', paymentMethod),
                const Divider(color: Colors.white10),
                _receiptLine('Total', '₹${price.toStringAsFixed(2)}', bold: true),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Stitch QuickWash 2.0\nThank you for your order!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close', style: TextStyle(color: AppColors.secondary)),
            ),
          ],
        );
      },
    );
  }

  Widget _receiptLine(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: bold ? 16 : 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: bold ? AppColors.secondary : AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isHighlight ? 17 : 14,
              fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
              color: isHighlight ? AppColors.secondary : AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
