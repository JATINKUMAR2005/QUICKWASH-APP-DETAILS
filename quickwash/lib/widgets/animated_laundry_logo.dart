import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedLaundryLogo extends StatefulWidget {
  final double size;

  const AnimatedLaundryLogo({
    super.key,
    this.size = 88.0,
  });

  @override
  State<AnimatedLaundryLogo> createState() => _AnimatedLaundryLogoState();
}

class _AnimatedLaundryLogoState extends State<AnimatedLaundryLogo>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _bubbleController;

  @override
  void initState() {
    super.initState();
    
    // Rotation of the washing machine drum
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Pulsing glow effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Floating soap bubbles animation
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final double pulseVal = _pulseController.value;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: AppColors.primaryContainer.withValues(
                alpha: 0.3 + (pulseVal * 0.3),
              ),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(
                  alpha: 0.15 + (pulseVal * 0.15),
                ),
                blurRadius: 16 + (pulseVal * 16),
                spreadRadius: pulseVal * 2,
              ),
            ],
          ),
          child: ClipOval(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Floating bubbles inside the logo
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _bubbleController,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _LogoBubblesPainter(
                          progress: _bubbleController.value,
                        ),
                      );
                    },
                  ),
                ),

                // 2. Spinning Laundry Icon (Drum simulation)
                RotationTransition(
                  turns: _rotationController,
                  child: Icon(
                    Icons.local_laundry_service_rounded,
                    size: widget.size * 0.5,
                    color: AppColors.primary,
                  ),
                ),

                // 3. Subtle inner glow ring
                IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                        width: 4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LogoBubblesPainter extends CustomPainter {
  final double progress;
  final List<_LogoBubble> _bubbles;

  _LogoBubblesPainter({required this.progress})
      : _bubbles = List.generate(
          8,
          (i) => _LogoBubble(
            startXFraction: (i + 1) / 9.0,
            speed: 0.6 + (i % 3) * 0.2,
            radius: 2.0 + (i % 2) * 1.5,
            phase: i * 1.2,
          ),
        );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final fillPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    for (final bubble in _bubbles) {
      final double x = size.width * bubble.startXFraction +
          math.sin(progress * 2 * math.pi + bubble.phase) * 6;
      
      // Bubble rises up and loops
      double y = size.height - ((progress * bubble.speed + (bubble.phase / 10.0)) % 1.0) * size.height;
      
      // Calculate opacity based on height (fades out near the top)
      final double opacity = (y / size.height).clamp(0.0, 1.0);
      paint.color = AppColors.secondary.withValues(alpha: opacity * 0.5);
      fillPaint.color = AppColors.secondary.withValues(alpha: opacity * 0.15);

      canvas.drawCircle(Offset(x, y), bubble.radius, fillPaint);
      canvas.drawCircle(Offset(x, y), bubble.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LogoBubblesPainter oldDelegate) => true;
}

class _LogoBubble {
  final double startXFraction;
  final double speed;
  final double radius;
  final double phase;

  const _LogoBubble({
    required this.startXFraction,
    required this.speed,
    required this.radius,
    required this.phase,
  });
}
