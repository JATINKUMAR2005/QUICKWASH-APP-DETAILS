import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_app_bar.dart';
import '../../services/local_database.dart';
import 'payment_methods_screen.dart';

class CartReviewScreen extends StatefulWidget {
  const CartReviewScreen({super.key});

  @override
  State<CartReviewScreen> createState() => _CartReviewScreenState();
}

class _CartReviewScreenState extends State<CartReviewScreen> {
  DateTime? _pickupDate;
  String? _pickupTime;
  DateTime? _dropoffDate;
  String? _dropoffTime;

  final List<String> _timeSlots = const [
    '09:00 AM - 12:00 PM',
    '12:00 PM - 03:00 PM',
    '03:00 PM - 06:00 PM',
    '06:00 PM - 09:00 PM',
  ];

  List<DateTime> _getPickupDates() {
    final now = DateTime.now();
    return List.generate(5, (index) => now.add(Duration(days: index)));
  }

  List<DateTime> _getDropoffDates(DateTime? pickup) {
    final startDate = pickup ?? DateTime.now();
    final minDate = startDate.add(const Duration(days: 1));
    return List.generate(5, (index) => minDate.add(Duration(days: index)));
  }

  String _getMonthName(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.month - 1];
  }

  String _getDayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  Widget _buildDatePicker({
    required List<DateTime> dates,
    required DateTime? selectedDate,
    required ValueChanged<DateTime> onDateSelected,
  }) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = selectedDate != null &&
              selectedDate.year == date.year &&
              selectedDate.month == date.month &&
              selectedDate.day == date.day;
          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              decoration: isSelected
                  ? BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.secondary,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    )
                  : BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getMonthName(date),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.secondary : AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.secondary : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getDayName(date),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.secondary : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlots({
    required List<String> slots,
    required String? selectedSlot,
    required ValueChanged<String> onSlotSelected,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: slots.map((slot) {
        final isSelected = selectedSlot == slot;
        return GestureDetector(
          onTap: () => onSlotSelected(slot),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: isSelected
                ? BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.secondary,
                      width: 1.5,
                    ),
                  )
                : BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
            child: Text(
              slot,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.secondary : AppColors.onSurface,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        final cartItems = appState.cartItems;
        final cartTotal = appState.getCartTotal();
        final itemCount = appState.getCartItemCount();

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
                  title: 'Your Cart',
                  showBack: true,
                  showAvatar: false,
                  showNotification: false,
                ),
                Expanded(
              child: cartItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 72,
                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Your cart is empty',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add items from categories to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        ...cartItems.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _CartItemCard(
                              item: item,
                              onQuantityChanged: (newQty) {
                                appState.updateCartItemQuantity(
                                  item['category'] as String,
                                  item['item'] as String,
                                  newQty,
                                );
                              },
                              onRemove: () {
                                appState.removeFromCart(
                                  item['category'] as String,
                                  item['item'] as String,
                                );
                              },
                            ),
                          );
                        }).toList(),
                        
                        const SizedBox(height: 8),
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 16),

                        // Schedule Title
                        Row(
                          children: const [
                            Icon(Icons.calendar_today_rounded, color: AppColors.secondary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Schedule Pickup & Delivery',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Pickup Section
                        const Text(
                          'Select Pickup Slot',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDatePicker(
                          dates: _getPickupDates(),
                          selectedDate: _pickupDate,
                          onDateSelected: (date) {
                            setState(() {
                              _pickupDate = date;
                              // Reset dropoff if it's no longer valid
                              if (_dropoffDate != null && !_dropoffDate!.isAfter(date)) {
                                _dropoffDate = null;
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildTimeSlots(
                          slots: _timeSlots,
                          selectedSlot: _pickupTime,
                          onSlotSelected: (slot) {
                            setState(() {
                              _pickupTime = slot;
                            });
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 16),

                        // Dropoff Section
                        const Text(
                          'Select Delivery Slot',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDatePicker(
                          dates: _getDropoffDates(_pickupDate),
                          selectedDate: _dropoffDate,
                          onDateSelected: (date) {
                            setState(() {
                              _dropoffDate = date;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildTimeSlots(
                          slots: _timeSlots,
                          selectedSlot: _dropoffTime,
                          onSlotSelected: (slot) {
                            setState(() {
                              _dropoffTime = slot;
                            });
                          },
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
            ),
                // Bottom bar
                if (cartItems.isNotEmpty)
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.glassBorder,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Summary row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$itemCount Items',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₹${cartTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            // Clear cart button
                            GestureDetector(
                              onTap: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: const Color(0xFF0F1A30),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    title: const Text('Clear Cart?', style: TextStyle(color: AppColors.onSurface)),
                                    content: const Text(
                                      'This will remove all items from your cart.',
                                      style: TextStyle(color: AppColors.onSurfaceVariant),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant)),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text('Clear', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await appState.clearCart();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                                ),
                                child: const Text(
                                  'Clear All',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Opacity(
                          opacity: (_pickupDate != null &&
                                  _pickupTime != null &&
                                  _dropoffDate != null &&
                                  _dropoffTime != null)
                              ? 1.0
                              : 0.5,
                          child: GlassButton(
                            label: 'Proceed to Payment  →',
                            onPressed: (_pickupDate != null &&
                                    _pickupTime != null &&
                                    _dropoffDate != null &&
                                    _dropoffTime != null)
                                ? () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => PaymentMethodsScreen(
                                          pickupDate: "${_pickupDate!.day} ${_getMonthName(_pickupDate!)}",
                                          pickupTime: _pickupTime,
                                          dropoffDate: "${_dropoffDate!.day} ${_getMonthName(_dropoffDate!)}",
                                          dropoffTime: _dropoffTime,
                                        ),
                                      ),
                                    );
                                  }
                                : null,
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

class _CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final itemName = item['item'] as String? ?? 'Item';
    final emoji = item['emoji'] as String? ?? '🧺';
    final category = item['category'] as String? ?? '';
    final qty = item['quantity'] as int? ?? 1;
    final basePrice = (item['price'] as num?)?.toDouble() ?? 0.0;
    final services = (item['services'] as List?)?.cast<String>() ?? [];
    final servicesCount = services.length;
    final serviceMultiplier = servicesCount > 0 ? (1.0 + (servicesCount - 1) * 0.5) : 1.0;
    final totalItemPrice = qty * basePrice * serviceMultiplier;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        borderRadius: 14,
        padding: const EdgeInsets.all(16),
        borderColor: AppColors.secondary.withValues(alpha: 0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Remove button
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Services
            if (services.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: services.map((s) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    s,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondary,
                    ),
                  ),
                )).toList(),
              ),
            const SizedBox(height: 12),
            // Quantity & Price row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantity controls
                Row(
                  children: [
                    _qtyButton(Icons.remove, qty > 1 ? () => onQuantityChanged(qty - 1) : null),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        '$qty',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    _qtyButton(Icons.add, () => onQuantityChanged(qty + 1), isPrimary: true),
                  ],
                ),
                // Price breakdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${basePrice.toInt()} × $qty${servicesCount > 1 ? ' × ${serviceMultiplier.toStringAsFixed(1)}' : ''}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '₹${totalItemPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback? onTap, {bool isPrimary = false}) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primaryContainer.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: isEnabled ? 0.08 : 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPrimary ? AppColors.primaryContainer : AppColors.glassBorder,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isEnabled
              ? (isPrimary ? AppColors.onPrimaryContainer : AppColors.onSurface)
              : AppColors.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
