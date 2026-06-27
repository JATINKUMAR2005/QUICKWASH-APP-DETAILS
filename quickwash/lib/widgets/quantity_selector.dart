import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final double size;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleButton(
          icon: Icons.remove,
          onTap: quantity > 0 ? () => onChanged(quantity - 1) : null,
          size: size,
        ),
        SizedBox(
          width: size,
          child: Center(
            child: Text(
              '$quantity',
              style: TextStyle(
                fontSize: size * 0.44,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ),
        _CircleButton(
          icon: Icons.add,
          onTap: () => onChanged(quantity + 1),
          size: size,
          isPrimary: true,
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final bool isPrimary;

  const _CircleButton({
    required this.icon,
    this.onTap,
    required this.size,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primaryContainer.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: isEnabled ? 0.08 : 0.04),
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(
            color: isPrimary
                ? AppColors.primaryContainer
                : AppColors.glassBorder,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: size * 0.5,
          color: isEnabled
              ? (isPrimary ? AppColors.onPrimaryContainer : AppColors.onSurface)
              : AppColors.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
