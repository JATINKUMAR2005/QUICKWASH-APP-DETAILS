import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class CategoryCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String? itemCount;
  final VoidCallback? onTap;
  final IconData? iconData;

  const CategoryCard({
    super.key,
    required this.emoji,
    required this.label,
    this.itemCount,
    this.onTap,
    this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      optimizePerformance: true,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconData != null)
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                iconData,
                color: AppColors.secondary,
                size: 28,
              ),
            )
          else
            Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
            ),
          ),
          if (itemCount != null) ...[
            const SizedBox(height: 4),
            Text(
              itemCount!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
