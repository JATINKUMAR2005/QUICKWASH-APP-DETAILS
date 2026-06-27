import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_button.dart';
import '../../services/local_database.dart';
import '../home/home_shell.dart';

class WalletPaymentSuccessScreen extends StatelessWidget {
  final double amount;
  final String paymentMethod;
  final String transactionId;

  WalletPaymentSuccessScreen({
    super.key,
    required this.amount,
    required this.paymentMethod,
  }) : transactionId = 'TXN-WLT${math.Random().nextInt(900000) + 100000}';

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final balance = (appState.currentUser?['balance'] as num?)?.toDouble() ?? 0.0;

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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Success Glowing Indicator
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.25),
                        blurRadius: 32,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 56,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 32),

                const Text(
                  'Top-up Successful!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your QuickWash wallet has been updated.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                // Invoice details receipt card
                GlassCard(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildReceiptRow('TRANSACTION ID', transactionId, isHighlight: true),
                      const Divider(color: Colors.white12, height: 24),
                      _buildReceiptRow('AMOUNT CREDITED', '₹${amount.toStringAsFixed(2)}'),
                      const SizedBox(height: 12),
                      _buildReceiptRow('PAYMENT METHOD', paymentMethod),
                      const SizedBox(height: 12),
                      _buildReceiptRow('UPDATED BALANCE', '₹${balance.toStringAsFixed(2)}', isBalance: true),
                    ],
                  ),
                ),
                const Spacer(flex: 2),

                // Nav Action buttons
                GlassButton(
                  label: 'Go to Wallet',
                  onPressed: () {
                    // Navigate back to HomeShell with Wallet Screen active
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const HomeShell(), // It will launch HomeShell at Home index, user can switch or we go to HomeShell
                      ),
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 12),
                GlassButton(
                  label: 'Back to Home Dashboard',
                  outlined: true,
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeShell()),
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isHighlight = false, bool isBalance = false}) {
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
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight || isBalance ? 16 : 14,
            fontWeight: isHighlight || isBalance ? FontWeight.w700 : FontWeight.w500,
            color: isHighlight
                ? AppColors.secondary
                : isBalance
                    ? AppColors.success
                    : AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
