import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_app_bar.dart';
import '../../services/local_database.dart';
import 'payment_success_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final String? pickupDate;
  final String? pickupTime;
  final String? dropoffDate;
  final String? dropoffTime;

  const PaymentMethodsScreen({
    super.key,
    this.pickupDate,
    this.pickupTime,
    this.dropoffDate,
    this.dropoffTime,
  });

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  int _selectedMethod = 3; // Default to Cash on Delivery
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _paymentOptions = [
    {
      'icon': Icons.account_balance_wallet_outlined,
      'title': 'UPI (Paytm, GPay, PhonePe)',
      'subtitle': 'Instant bank transfer using UPI app',
    },
    {
      'icon': Icons.credit_card_rounded,
      'title': 'Credit/Debit Cards',
      'subtitle': 'Visa, Mastercard, RuPay & more',
    },
    {
      'icon': Icons.account_balance_wallet_rounded,
      'title': 'QuickWash Wallet',
      'subtitle': 'Pay from preloaded balance',
      'badge': 'FASTEST',
    },
    {
      'icon': Icons.money_rounded,
      'title': 'Cash on Delivery',
      'subtitle': 'Pay in cash or UPI at delivery',
    },
  ];

  Future<void> _handlePayment() async {
    final appState = AppState();
    final cartTotal = appState.getCartTotal();
    final double finalAmount = cartTotal > 0 ? cartTotal : 849.00;

    final selectedOption = _paymentOptions[_selectedMethod];
    final String method = selectedOption['title'] as String;

    // If using wallet, check if balance is sufficient
    if (method == 'QuickWash Wallet' && appState.currentUser != null) {
      final balance = (appState.currentUser!['balance'] as num).toDouble();
      if (balance < finalAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insufficient Wallet Balance! Choose another method or top up.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() => _isProcessing = true);

    // Dynamic processing overlay simulator
    await Future.delayed(const Duration(seconds: 2));

    // Place the order in the persistent database
    final order = await appState.createOrder(
      method,
      pickupDate: widget.pickupDate,
      pickupTime: widget.pickupTime,
      dropoffDate: widget.dropoffDate,
      dropoffTime: widget.dropoffTime,
    );

    setState(() => _isProcessing = false);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            orderId: order['orderId'] as String,
            totalAmount: (order['price'] as num).toDouble(),
            paymentMethod: method,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final cartTotal = appState.getCartTotal();
    final double finalAmount = cartTotal > 0 ? cartTotal : 849.00;
    final int itemCount = cartTotal > 0 ? appState.getCartItemCount() : 3;

    final userWalletBalance = appState.currentUser != null 
        ? (appState.currentUser!['balance'] as num).toDouble() 
        : 1240.0;

    // Update wallet subtitle dynamic balance
    _paymentOptions[2]['subtitle'] = 'Available: ₹${userWalletBalance.toInt()}';

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
        child: Stack(
          children: [
            Column(
              children: [
                GlassAppBar(
                  title: 'Select Payment',
                  showBack: true,
                  showAvatar: false,
                  trailing: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Amount header
                        Text(
                          'TOTAL AMOUNT TO PAY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${finalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$itemCount Items • Premium Service',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Payment options list
                        ...List.generate(_paymentOptions.length, (index) {
                          final opt = _paymentOptions[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PaymentOption(
                              icon: opt['icon'] as IconData,
                              title: opt['title'] as String,
                              subtitle: opt['subtitle'] as String,
                              badge: opt['badge'] as String?,
                              isSelected: _selectedMethod == index,
                              onTap: () => setState(() => _selectedMethod = index),
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                        // Secure badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              size: 18,
                              color: AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '100% SECURE TRANSACTION',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom bar
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Payable',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '₹${finalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GlassButton(
                        label: 'Pay Now  →',
                        onPressed: _selectedMethod >= 0 ? _handlePayment : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Translucent Processing Loader Overlay
            if (_isProcessing)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: GlassCard(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(32),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Processing Payment...',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Please do not press back or close the app.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.glassWhite6,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryContainer
                : AppColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppColors.secondary
                    : AppColors.onSurfaceVariant,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.secondary
                      : AppColors.outlineVariant,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.secondary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
