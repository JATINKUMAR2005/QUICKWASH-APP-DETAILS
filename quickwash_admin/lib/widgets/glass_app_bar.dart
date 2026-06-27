import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'animated_laundry_logo.dart';

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showAvatar;
  final bool showNotification;
  final bool showBack;
  final String? avatarUrl;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onBackTap;
  final Widget? trailing;
  final VoidCallback? onAvatarTap;

  const GlassAppBar({
    super.key,
    this.title = 'QuickWash',
    this.showAvatar = true,
    this.showNotification = true,
    this.showBack = false,
    this.avatarUrl,
    this.onNotificationTap,
    this.onBackTap,
    this.trailing,
    this.onAvatarTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            border: const Border(
              bottom: BorderSide(
                color: Color(0x1FFFFFFF),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (showBack) ...[
                    GestureDetector(
                      onTap: onBackTap ?? () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.onSurfaceVariant,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ] else if (showAvatar) ...[
                    GestureDetector(
                      onTap: onAvatarTap ?? () => const TabNavigationNotification(3).dispatch(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: avatarUrl != null
                              ? Image.network(
                                  avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AnimatedLaundryLogo(size: 32),
                          const SizedBox(width: 10),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              shadows: [
                                Shadow(
                                  color: AppColors.primary.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (trailing != null) trailing!,
                  if (showNotification)
                    GestureDetector(
                      onTap: onNotificationTap ?? () => const TabNavigationNotification(2).dispatch(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            const Icon(
                              Icons.notifications_outlined,
                              color: AppColors.primary,
                              size: 26,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: AppColors.surfaceDim,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TabNavigationNotification extends Notification {
  final int index;
  const TabNavigationNotification(this.index);
}
