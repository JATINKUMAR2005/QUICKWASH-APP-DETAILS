import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/glass_decorations.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? borderColor;
  final bool elevated;
  final bool glowBlue;
  final bool optimizePerformance;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 12,
    this.padding,
    this.margin,
    this.borderColor,
    this.elevated = false,
    this.glowBlue = false,
    this.optimizePerformance = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration;
    if (glowBlue) {
      decoration = GlassDecorations.glassGlowBlue(borderRadius: borderRadius);
    } else if (elevated) {
      decoration = GlassDecorations.glassElevated(borderRadius: borderRadius);
    } else {
      decoration = GlassDecorations.glassPanel(
        borderRadius: borderRadius,
        borderColor: borderColor,
      );
    }

    Widget content;
    if (optimizePerformance) {
      final Color? baseColor = decoration.color;
      final double currentOpacity = baseColor != null ? (baseColor.alpha / 255.0) : 0.0;
      content = Container(
        decoration: decoration.copyWith(
          // Slightly increase opacity of background since there is no blur
          color: baseColor?.withValues(alpha: currentOpacity + 0.08),
        ),
        padding: padding ?? const EdgeInsets.all(16),
        margin: margin,
        child: child,
      );
    } else {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: elevated ? 12 : 8,
            sigmaY: elevated ? 12 : 8,
          ),
          child: Container(
            decoration: decoration,
            padding: padding ?? const EdgeInsets.all(16),
            margin: margin,
            child: child,
          ),
        ),
      );
    }

    content = RepaintBoundary(child: content);

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
