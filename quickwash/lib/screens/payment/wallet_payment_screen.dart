import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_app_bar.dart';
import '../../services/local_database.dart';
import 'wallet_payment_success_screen.dart';

class WalletPaymentScreen extends StatefulWidget {
  final double amount;

  const WalletPaymentScreen({
    super.key,
    required this.amount,
  });

  @override
  State<WalletPaymentScreen> createState() => _WalletPaymentScreenState();
}

class _WalletPaymentScreenState extends State<WalletPaymentScreen> {
  int _selectedMethod = 0; // Default to UPI
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
      'icon': Icons.account_balance_rounded,
      'title': 'Net Banking',
      'subtitle': 'Pay securely through your bank',
    },
  ];

  Future<void> _handlePayment() async {
    setState(() => _isProcessing = true);

    // Simulate payment processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Update wallet balance in persistent database
    await AppState().addWalletCredits(widget.amount);

    setState(() => _isProcessing = false);

    if (mounted) {
      final selectedOption = _paymentOptions[_selectedMethod];
      final String method = selectedOption['title'] as String;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WalletPaymentSuccessScreen(
            amount: widget.amount,
            paymentMethod: method,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double gstAmount = 0.00;
    final double totalAmount = widget.amount + gstAmount;

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
                  title: 'Wallet Invoice',
                  showBack: true,
                  showAvatar: false,
                  showNotification: false,
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
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Box
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'TOTAL TOP-UP AMOUNT',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '₹${totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Adding credits directly to wallet balance',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Bill Breakdown Details
                        const Text(
                          'Payment Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GlassCard(
                          borderRadius: 16,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildBillRow('Top-up Credits', '₹${widget.amount.toStringAsFixed(2)}'),
                              const SizedBox(height: 10),
                              _buildBillRow('Processing Fee (GST)', '₹${gstAmount.toStringAsFixed(2)}'),
                              const Divider(color: Colors.white12, height: 20),
                              _buildBillRow('Total Payable', '₹${totalAmount.toStringAsFixed(2)}', isTotal: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Select payment method label
                        const Text(
                          'Select Payment Method',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // List of options (excluding wallet payment itself)
                        ...List.generate(_paymentOptions.length, (index) {
                          final opt = _paymentOptions[index];
                          final isSelected = _selectedMethod == index;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedMethod = index),
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
                                        opt['icon'] as IconData,
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
                                          Text(
                                            opt['title'] as String,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            opt['subtitle'] as String,
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
                                      width: 20,
                                      height: 20,
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
                                                width: 10,
                                                height: 10,
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
                            ),
                          );
                        }),
                        const SizedBox(height: 16),

                        // Secure badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              size: 16,
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '100% SECURE GATEWAY TRANSACTION',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom bar container protecting gesture bar
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
                            'Payable Amount',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '₹${totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GlassButton(
                        label: 'Pay & Add Credits  →',
                        onPressed: _handlePayment,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Processing Loader Overlay
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
                          const SizedBox(height: 20),
                          Text(
                            'Processing Transaction...',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Securing your credits addition. Please wait.',
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

  Widget _buildBillRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isTotal ? AppColors.onSurface : AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: isTotal ? AppColors.secondary : AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
