import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WashingCycleAnimation extends StatefulWidget {
  final double size;
  final bool isWashing;

  const WashingCycleAnimation({
    super.key,
    this.size = 180.0,
    this.isWashing = true,
  });

  @override
  State<WashingCycleAnimation> createState() => _WashingCycleAnimationState();
}

class _WashingCycleAnimationState extends State<WashingCycleAnimation>
    with TickerProviderStateMixin {
  late AnimationController _drumController;
  late AnimationController _waveController;
  late AnimationController _foamController;

  @override
  void initState() {
    super.initState();

    _drumController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _foamController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    if (widget.isWashing) {
      _drumController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant WashingCycleAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isWashing != oldWidget.isWashing) {
      if (widget.isWashing) {
        _drumController.repeat();
      } else {
        _drumController.stop();
      }
    }
  }

  @override
  void dispose() {
    _drumController.dispose();
    _waveController.dispose();
    _foamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: const Color(0xFF131D33),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.3),
          width: 6,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.2),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Water waves inside
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _WashingWaterPainter(
                      wavePhase: _waveController.value,
                      waterLevel: 0.55, // Fill 55%
                    ),
                  );
                },
              ),
            ),

            // 2. Rising foam and suds bubbles
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _foamController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _FoamBubblesPainter(
                      progress: _foamController.value,
                    ),
                  );
                },
              ),
            ),

            // 3. Rotating Clothes/Laundry (Drum)
            RotationTransition(
              turns: _drumController,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Item 1: T-Shirt emoji
                  Transform.translate(
                    offset: Offset(0, -widget.size * 0.22),
                    child: Transform.rotate(
                      angle: 0.2,
                      child: const Text('👕', style: TextStyle(fontSize: 28)),
                    ),
                  ),
                  // Item 2: Sock emoji
                  Transform.translate(
                    offset: Offset(widget.size * 0.2, widget.size * 0.15),
                    child: Transform.rotate(
                      angle: -0.5,
                      child: const Text('🧦', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  // Item 3: Towel emoji
                  Transform.translate(
                    offset: Offset(-widget.size * 0.22, widget.size * 0.08),
                    child: Transform.rotate(
                      angle: 1.1,
                      child: const Text('🧼', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ],
              ),
            ),

            // 4. Glass reflection & highlights overlay
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.02),
                      Colors.black.withValues(alpha: 0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WashingWaterPainter extends CustomPainter {
  final double wavePhase;
  final double waterLevel; // 0 to 1

  const _WashingWaterPainter({
    required this.wavePhase,
    required this.waterLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..color = const Color(0xFF03B5D3).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final deepWaterPaint = Paint()
      ..color = const Color(0xFF0E4A7D).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final double baseHeight = size.height * (1.0 - waterLevel);
    
    // Primary Wave
    final Path wavePath = Path();
    wavePath.moveTo(0, size.height);
    wavePath.lineTo(0, baseHeight);
    
    for (double x = 0; x <= size.width; x++) {
      final double waveHeight = math.sin((x / size.width * 2 * math.pi) + (wavePhase * 2 * math.pi)) * 8;
      wavePath.lineTo(x, baseHeight + waveHeight);
    }
    wavePath.lineTo(size.width, size.height);
    wavePath.close();

    // Secondary Wave (slower/offset)
    final Path secondaryPath = Path();
    secondaryPath.moveTo(0, size.height);
    secondaryPath.lineTo(0, baseHeight + 4);
    
    for (double x = 0; x <= size.width; x++) {
      final double waveHeight = math.cos((x / size.width * 2 * math.pi) - (wavePhase * 2 * math.pi)) * 6;
      secondaryPath.lineTo(x, baseHeight + 4 + waveHeight);
    }
    secondaryPath.lineTo(size.width, size.height);
    secondaryPath.close();

    canvas.drawPath(secondaryPath, wavePaint);
    canvas.drawPath(wavePath, deepWaterPaint);
  }

  @override
  bool shouldRepaint(covariant _WashingWaterPainter oldDelegate) =>
      oldDelegate.wavePhase != wavePhase || oldDelegate.waterLevel != waterLevel;
}

class _FoamBubblesPainter extends CustomPainter {
  final double progress;
  final List<_FoamBubble> _bubbles;

  _FoamBubblesPainter({required this.progress})
      : _bubbles = List.generate(
          12,
          (i) => _FoamBubble(
            startXFraction: (i + 1) / 13.0,
            speedFraction: 0.5 + (i % 4) * 0.15,
            radius: 3.0 + (i % 3) * 2.0,
            amplitude: 4.0 + (i % 2) * 4.0,
            offsetFraction: i * 0.08,
          ),
        );

  @override
  void paint(Canvas canvas, Size size) {
    final bubblePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final fillPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    for (final b in _bubbles) {
      // Linear bubble rise
      final double t = (progress * b.speedFraction + b.offsetFraction) % 1.0;
      final double y = size.height - (t * size.height);
      
      // Horizontal drift (sine wave)
      final double x = size.width * b.startXFraction +
          math.sin(t * 4 * math.pi + b.offsetFraction) * b.amplitude;

      // Opacity fades out towards top half
      final double opacity = (1.0 - t).clamp(0.0, 1.0);
      bubblePaint.color = Colors.white.withValues(alpha: opacity * 0.7);
      fillPaint.color = Colors.white.withValues(alpha: opacity * 0.15);

      canvas.drawCircle(Offset(x, y), b.radius, fillPaint);
      canvas.drawCircle(Offset(x, y), b.radius, bubblePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FoamBubblesPainter oldDelegate) => true;
}

class _FoamBubble {
  final double startXFraction;
  final double speedFraction;
  final double radius;
  final double amplitude;
  final double offsetFraction;

  const _FoamBubble({
    required this.startXFraction,
    required this.speedFraction,
    required this.radius,
    required this.amplitude,
    required this.offsetFraction,
  });
}
