import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/glass_decorations.dart';

class GlassButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final IconData? icon;
  final double borderRadius;
  final double? width;
  final double height;

  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.outlined = false,
    this.icon,
    this.borderRadius = 12,
    this.width,
    this.height = 56,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed == null ? null : (_) => _controller.forward(),
      onTapUp: widget.onPressed == null ? null : (_) {
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: widget.onPressed == null ? null : () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: widget.outlined
              ? GlassDecorations.outlinedButton(
                  borderRadius: widget.borderRadius,
                )
              : GlassDecorations.gradientButton(
                  borderRadius: widget.borderRadius,
                ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: widget.outlined
                      ? AppColors.onSurface
                      : Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 10),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: widget.outlined
                      ? AppColors.onSurface
                      : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
