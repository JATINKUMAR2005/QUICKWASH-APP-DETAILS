import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_theme.dart';

class GlassDecorations {
  /// Standard glass panel — rgba(255,255,255,0.06) bg, blur 20, 1px white/12 border
  static BoxDecoration glassPanel({
    double borderRadius = 12,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: AppColors.glassWhite6,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? AppColors.glassBorder,
        width: 1,
      ),
    );
  }

  /// Elevated glass panel — rgba(255,255,255,0.10) bg, blur 30, cyan glow
  static BoxDecoration glassElevated({
    double borderRadius = 12,
  }) {
    return BoxDecoration(
      color: AppColors.glassWhite10,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: AppColors.glassBorder,
        width: 1,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x26068AD4), // rgba(6, 182, 212, 0.15)
          blurRadius: 32,
          offset: Offset(0, 8),
        ),
      ],
    );
  }

  /// Glass input field — rgba(255,255,255,0.04) bg, 1px border
  static BoxDecoration glassInput({
    double borderRadius = 12,
    bool focused = false,
  }) {
    return BoxDecoration(
      color: AppColors.glassInput,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: focused ? AppColors.secondary : AppColors.glassBorder,
        width: 1,
      ),
      boxShadow: focused
          ? [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.2),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ]
          : null,
    );
  }

  /// Glass panel with blue glow on left side (active order card)
  static BoxDecoration glassGlowBlue({
    double borderRadius = 12,
  }) {
    return BoxDecoration(
      color: AppColors.glassWhite6,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: AppColors.glassBorder,
        width: 1,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x4D4CD7F6), // rgba(76, 215, 246, 0.3)
          blurRadius: 12,
          offset: Offset(-4, 0),
          spreadRadius: -2,
        ),
      ],
    );
  }

  /// Bottom navigation glass
  static BoxDecoration glassBottomNav() {
    return const BoxDecoration(
      color: AppColors.glassWhite10,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      border: Border(
        top: BorderSide(
          color: AppColors.glassBorder,
          width: 1,
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: Color(0x26068AD4),
          blurRadius: 32,
          offset: Offset(0, -8),
        ),
      ],
    );
  }

  /// Gradient button decoration (Primary Blue → Cyan)
  static BoxDecoration gradientButton({
    double borderRadius = 12,
  }) {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.gradientBlueStart, AppColors.gradientCyanEnd],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  /// Outlined glass button (for secondary actions)
  static BoxDecoration outlinedButton({
    double borderRadius = 12,
  }) {
    return BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: AppColors.glassBorder,
        width: 1,
      ),
    );
  }
}
