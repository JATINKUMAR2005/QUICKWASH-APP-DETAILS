import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_app_bar.dart';

class PromosScreen extends StatelessWidget {
  const PromosScreen({super.key});

  static const List<Map<String, dynamic>> _promos = [
    {
      'code': 'ETHNIC20',
      'title': '20% Off Ethnic Wear',
      'description': 'Get 20% off on all ethnic wear dry cleaning services. Valid on Saree, Kurta, Lehenga & Sherwani.',
      'discount': '20%',
      'minOrder': '₹300',
      'expiry': '30 Jun 2026',
      'gradient': [Color(0xFF7E22CE), Color(0xFF4338CA)],
      'icon': Icons.sell_rounded,
    },
    {
      'code': 'FIRST50',
      'title': '50% Off First Order',
      'description': 'New user welcome bonus! 50% off your first order up to ₹200.',
      'discount': '50%',
      'minOrder': '₹100',
      'expiry': '31 Jul 2026',
      'gradient': [Color(0xFF0D9488), Color(0xFF047857)],
      'icon': Icons.celebration_rounded,
    },
    {
      'code': 'WASH100',
      'title': '₹100 Off on ₹500+',
      'description': 'Flat ₹100 off on orders above ₹500. Applicable on all categories.',
      'discount': '₹100',
      'minOrder': '₹500',
      'expiry': '25 Jun 2026',
      'gradient': [Color(0xFF1A6BCC), Color(0xFF06B6D4)],
      'icon': Icons.local_offer_rounded,
    },
    {
      'code': 'PREMIUM30',
      'title': '30% Off Premium Services',
      'description': 'Get 30% off on Stain Removal and Premium Restore services.',
      'discount': '30%',
      'minOrder': '₹200',
      'expiry': '15 Jul 2026',
      'gradient': [Color(0xFFF59E0B), Color(0xFFEA580C)],
      'icon': Icons.workspace_premium_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
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
              title: 'Promos & Offers',
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
                    const Text(
                      'Available Offers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Apply promo codes at checkout for exciting discounts!',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),

                    ..._promos.map((promo) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _PromoCard(promo: promo),
                    )),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final Map<String, dynamic> promo;

  const _PromoCard({required this.promo});

  @override
  Widget build(BuildContext context) {
    final gradient = promo['gradient'] as List<Color>;

    return GlassCard(
      borderRadius: 16,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Promo header with gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    promo['icon'] as IconData,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promo['discount'] as String,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        promo['title'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Promo details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promo['description'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _infoChip('Min: ${promo['minOrder']}'),
                    const SizedBox(width: 8),
                    _infoChip('Valid till: ${promo['expiry']}'),
                  ],
                ),
                const SizedBox(height: 14),
                // Promo code row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Text(
                          promo['code'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: promo['code'] as String));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Promo code "${promo['code']}" copied!'),
                            backgroundColor: AppColors.secondary,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.gradientBlueStart, AppColors.gradientCyanEnd],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Copy',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
