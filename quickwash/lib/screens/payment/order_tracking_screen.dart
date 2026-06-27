import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_app_bar.dart';
import '../../services/local_database.dart';
import '../home/home_shell.dart';
import '../../widgets/washing_cycle_animation.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        // Retrieve order details
        final orderIndex = appState.orders.indexWhere((o) => o['orderId'] == orderId);
        final hasOrder = orderIndex != -1;
        final order = hasOrder ? appState.orders[orderIndex] : null;

        // Current status parameters
        final status = order != null ? order['status'] as String : 'Out for Delivery';
        final progress = order != null ? (order['progress'] as num).toDouble() : 0.85;
        final itemsDetail = order != null ? order['itemsDetail'] as String : 'General laundry package';

        // Match timeline highlights
        final currentStep = _getStepFromStatus(status);

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
                GlassAppBar(
                  title: 'Track Order',
                  showBack: true,
                  showAvatar: false,
                  onBackTap: () {
                    // Go back to HomeShell if popped
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeShell()),
                      (route) => false,
                    );
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // If in cleaning state, show the live washing machine simulator
                        if (status == 'In Process' || status == 'Processing') ...[
                          Center(
                            child: Column(
                              children: [
                                WashingCycleAnimation(
                                  size: 150,
                                  isWashing: status == 'In Process',
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  status == 'In Process' ? 'Washing cycle active...' : 'Preparing wash cycle...',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ] else if (status == 'Out for Delivery') ...[
                          LiveCourierMap(orderId: orderId),
                          const SizedBox(height: 24),
                        ] else ...[
                          // Dynamic Map Simulator
                          _buildMapSimulator(progress, status),
                          const SizedBox(height: 24),
                        ],

                        // Order brief card
                        GlassCard(
                          borderRadius: 16,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'SHIPPING DETAILS',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.2,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        orderId,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.white10, height: 24),
                              const Text(
                                'ITEMS',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...itemsDetail.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: AppColors.secondary,
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          item,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.onSurface,
                                            height: 1.4,
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
                        const SizedBox(height: 28),

                        // Tracking Timeline
                        const Text(
                          'Timeline Status',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTimeline(currentStep),
                      ],
                    ),
                  ),
                ),
                // Footer
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border(
                      top: BorderSide(
                        color: AppColors.glassBorder,
                        width: 1,
                      ),
                    ),
                  ),
                  child: GlassButton(
                    label: 'Return to Dashboard',
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const HomeShell()),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _getStepFromStatus(String status) {
    switch (status) {
      case 'Processing':
        return 0;
      case 'Picked Up':
        return 1;
      case 'In Process':
        return 2;
      case 'Out for Delivery':
        return 3;
      case 'Completed':
        return 4;
      default:
        return 0;
    }
  }

  Widget _buildMapSimulator(double progress, String status) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: Stack(
        children: [
          // Cyberpunk futuristic grid pattern backdrops
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: GridPaper(
                color: AppColors.secondary,
                interval: 24,
                divisions: 1,
                subdivisions: 1,
              ),
            ),
          ),
          // Delivery route line (glowing cyan path)
          Positioned(
            left: 40,
            right: 40,
            top: 90,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Covered route line
          Positioned(
            left: 40,
            width: (progress * (1 - 0.2)) * 320, // Approximate width scale
            top: 90,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
          // Start node (QuickWash hub)
          const Positioned(
            left: 30,
            top: 78,
            child: Column(
              children: [
                Icon(Icons.storefront_rounded, color: AppColors.primary, size: 24),
                SizedBox(height: 4),
                Text('Hub', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 9)),
              ],
            ),
          ),
          // End node (User home)
          const Positioned(
            right: 30,
            top: 78,
            child: Column(
              children: [
                Icon(Icons.home_work_rounded, color: AppColors.tertiary, size: 24),
                SizedBox(height: 4),
                Text('Home', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 9)),
              ],
            ),
          ),
          // Animated runner (Delivery truck/scooter)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            left: 40 + (progress * 220), // Slide position dynamically based on status progress
            top: 72,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.6),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_shipping_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          // Notification label
          Positioned(
            bottom: 12,
            left: 16,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  status == 'Completed' ? 'Order delivered safely.' : 'Driver is on the way...',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(int activeStep) {
    final List<Map<String, String>> steps = [
      {'title': 'Order Placed', 'desc': 'Successfully registered in our systems.'},
      {'title': 'Laundry Picked Up', 'desc': 'Our driver collected your clothes.'},
      {'title': 'Cleaning & Washing', 'desc': 'Clothes are being processed in the hub.'},
      {'title': 'Out for Delivery', 'desc': 'Your driver Jatin is delivering clothes.'},
      {'title': 'Delivered', 'desc': 'Completed and received.'},
    ];

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isCompleted = index < activeStep;
        final isCurrent = index == activeStep;
        final isPending = index > activeStep;

        Color timelineColor = AppColors.glassBorder;
        if (isCompleted) timelineColor = AppColors.success;
        if (isCurrent) timelineColor = AppColors.secondary;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left node indicator column
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppColors.success
                        : isCurrent
                            ? AppColors.secondary
                            : Colors.transparent,
                    border: Border.all(
                      color: isPending ? Colors.white24 : timelineColor,
                      width: 2,
                    ),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: AppColors.secondary.withValues(alpha: 0.4),
                              blurRadius: 10,
                            )
                          ]
                        : null,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : isCurrent
                          ? const Center(
                              child: SizedBox(
                                width: 8,
                                height: 8,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              ),
                            )
                          : null,
                ),
                if (index < steps.length - 1)
                  Container(
                    width: 2,
                    height: 48,
                    color: isCompleted ? AppColors.success : Colors.white12,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Right info card
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step['title']!,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isPending
                          ? AppColors.onSurfaceVariant.withValues(alpha: 0.5)
                          : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step['desc']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isPending
                          ? AppColors.onSurfaceVariant.withValues(alpha: 0.4)
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ==================== LIVE COURIER MAP WIDGETS ====================

class LiveCourierMap extends StatefulWidget {
  final String orderId;

  const LiveCourierMap({
    super.key,
    required this.orderId,
  });

  @override
  State<LiveCourierMap> createState() => _LiveCourierMapState();
}

class _LiveCourierMapState extends State<LiveCourierMap>
    with TickerProviderStateMixin {
  late AnimationController _mapController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _mapController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _mapController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  final List<Offset> _normalizedRoutePoints = const [
    Offset(0.12, 0.75), // Hub
    Offset(0.35, 0.75),
    Offset(0.35, 0.25),
    Offset(0.68, 0.25),
    Offset(0.68, 0.60),
    Offset(0.88, 0.60), // Home
  ];

  Offset _getActualOffset(Offset normalized, double width, double height) {
    return Offset(normalized.dx * width, normalized.dy * height);
  }

  Offset _getPositionOnPath(double t, double width, double height) {
    if (t <= 0) return _getActualOffset(_normalizedRoutePoints.first, width, height);
    if (t >= 1) return _getActualOffset(_normalizedRoutePoints.last, width, height);

    int numSegments = _normalizedRoutePoints.length - 1;
    double segmentProgress = t * numSegments;
    int index = segmentProgress.floor();
    double localT = segmentProgress - index;

    if (index >= numSegments) {
      return _getActualOffset(_normalizedRoutePoints.last, width, height);
    }

    Offset pA = _getActualOffset(_normalizedRoutePoints[index], width, height);
    Offset pB = _getActualOffset(_normalizedRoutePoints[index + 1], width, height);
    return Offset.lerp(pA, pB, localT)!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Map block
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF070B19),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.glassBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;
                
                final actualPoints = _normalizedRoutePoints
                    .map((p) => _getActualOffset(p, width, height))
                    .toList();

                return AnimatedBuilder(
                  animation: Listenable.merge([_mapController, _pulseController]),
                  builder: (context, _) {
                    final t = _mapController.value;
                    final courierPos = _getPositionOnPath(t, width, height);
                    
                    // Hub & Home actual coordinates
                    final hubPos = actualPoints.first;
                    final homePos = actualPoints.last;

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Map Background CustomPaint
                        Positioned.fill(
                          child: CustomPaint(
                            painter: MapPainter(
                              routePoints: actualPoints,
                              progress: t,
                            ),
                          ),
                        ),

                        // Pulsing Hub Marker
                        Positioned(
                          left: hubPos.dx - 24,
                          top: hubPos.dy - 35,
                          child: _buildLocationMarker(
                            icon: Icons.storefront_rounded,
                            color: AppColors.primary,
                            label: 'Hub',
                            pulse: _pulseController.value,
                          ),
                        ),

                        // Pulsing Home Marker
                        Positioned(
                          left: homePos.dx - 24,
                          top: homePos.dy - 35,
                          child: _buildLocationMarker(
                            icon: Icons.home_work_rounded,
                            color: AppColors.success,
                            label: 'Home',
                            pulse: _pulseController.value,
                          ),
                        ),

                        // Live Courier Marker (Scooter icon or Avatar)
                        Positioned(
                          left: courierPos.dx - 24,
                          top: courierPos.dy - 24,
                          child: _buildCourierMarker(
                            pulse: _pulseController.value,
                          ),
                        ),
                        
                        // "Live" indicator badge in top right
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.secondary.withOpacity(0.3), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.secondary.withOpacity(0.8),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'LIVE TRACKING',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Live Driver Details Panel
        AnimatedBuilder(
          animation: _mapController,
          builder: (context, _) {
            final t = _mapController.value;
            final etaMinutes = ((1.0 - t) * 12).clamp(1, 12).round();
            final distanceKm = ((1.0 - t) * 3.5).clamp(0.1, 3.5);
            // Fluctuates around 30 km/h with some sine wave
            final speedKmh = (30 + math.sin(t * math.pi * 8) * 4).round();

            return GlassCard(
              borderRadius: 20,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Driver Profile Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.secondary.withOpacity(0.5), width: 2),
                          color: AppColors.surfaceBright,
                        ),
                        child: ClipOval(
                          child: Image.network(
                            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.person_rounded, color: Colors.white, size: 24);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Driver Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'Jatin',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.verified, color: AppColors.secondary, size: 16),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'QuickWash Delivery Partner',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Call button
                      _buildActionCircle(
                        icon: Icons.phone_in_talk_rounded,
                        color: AppColors.secondary,
                        onTap: () => _simulateCall(context),
                      ),
                      const SizedBox(width: 8),
                      // Message button
                      _buildActionCircle(
                        icon: Icons.chat_bubble_outline_rounded,
                        color: Colors.white24,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Chat with Jatin is not available in demo mode.'),
                              backgroundColor: AppColors.surfaceBright,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        icon: Icons.timer_outlined,
                        label: 'ETA',
                        value: '$etaMinutes mins',
                      ),
                      _buildStatItem(
                        icon: Icons.directions_run_outlined,
                        label: 'Distance',
                        value: '${distanceKm.toStringAsFixed(1)} km',
                      ),
                      _buildStatItem(
                        icon: Icons.speed_outlined,
                        label: 'Speed',
                        value: '$speedKmh km/h',
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLocationMarker({
    required IconData icon,
    required Color color,
    required String label,
    required double pulse,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Pulse circle
            Container(
              width: 32 + (pulse * 16),
              height: 32 + (pulse * 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2 * (1.0 - pulse)),
              ),
            ),
            // Pin marker
            Icon(icon, color: color, size: 24),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withOpacity(0.3), width: 0.5),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourierMarker({required double pulse}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulse ring
        Container(
          width: 36 + (pulse * 20),
          height: 36 + (pulse * 20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.secondary.withOpacity(0.25 * (1.0 - pulse)),
          ),
        ),
        // Courier Avatar Container
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.secondary,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.6),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.directions_bike_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCircle({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color == AppColors.secondary
                ? AppColors.secondary.withOpacity(0.15)
                : color,
            border: Border.all(
              color: color == AppColors.secondary
                  ? AppColors.secondary.withOpacity(0.3)
                  : Colors.transparent,
            ),
          ),
          child: Icon(
            icon,
            color: color == AppColors.secondary ? AppColors.secondary : Colors.white70,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  void _simulateCall(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const PhoneCallScreen();
      },
    );
  }
}

class MapPainter extends CustomPainter {
  final List<Offset> routePoints;
  final double progress;

  MapPainter({required this.routePoints, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw subtle background grid
    final gridPaint = Paint()
      ..color = AppColors.secondary.withOpacity(0.04)
      ..strokeWidth = 1;
    
    double step = 20;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // 2. Draw block shapes (buildings) in the background
    final blockPaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..style = PaintingStyle.fill;
    final blockBorderPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw some sample blocks
    List<Rect> blocks = [
      Rect.fromLTRB(10, 10, size.width * 0.3, size.height * 0.2),
      Rect.fromLTRB(size.width * 0.4, 10, size.width * 0.63, size.height * 0.2),
      Rect.fromLTRB(size.width * 0.73, 10, size.width * 0.95, size.height * 0.5),
      Rect.fromLTRB(10, size.height * 0.35, size.width * 0.3, size.height * 0.65),
      Rect.fromLTRB(size.width * 0.4, size.height * 0.35, size.width * 0.63, size.height * 0.65),
      Rect.fromLTRB(size.width * 0.73, size.height * 0.7, size.width * 0.95, size.height * 0.9),
      Rect.fromLTRB(10, size.height * 0.8, size.width * 0.63, size.height * 0.95),
    ];

    for (var rect in blocks) {
      RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
      canvas.drawRRect(rrect, blockPaint);
      canvas.drawRRect(rrect, blockBorderPaint);
    }

    // 3. Draw background street lines (gray network)
    final streetPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // We can draw a grid of streets
    // Horizontal streets
    canvas.drawLine(Offset(0, size.height * 0.25), Offset(size.width, size.height * 0.25), streetPaint);
    canvas.drawLine(Offset(0, size.height * 0.75), Offset(size.width, size.height * 0.75), streetPaint);
    canvas.drawLine(Offset(0, size.height * 0.60), Offset(size.width, size.height * 0.60), streetPaint);
    // Vertical streets
    canvas.drawLine(Offset(size.width * 0.35, 0), Offset(size.width * 0.35, size.height), streetPaint);
    canvas.drawLine(Offset(size.width * 0.68, 0), Offset(size.width * 0.68, size.height), streetPaint);
    canvas.drawLine(Offset(size.width * 0.12, size.height * 0.5), Offset(size.width * 0.12, size.height), streetPaint);
    canvas.drawLine(Offset(size.width * 0.88, 0), Offset(size.width * 0.88, size.height * 0.8), streetPaint);

    // 4. Draw route path background (active route outline and active route progress)
    if (routePoints.isNotEmpty) {
      final routePath = Path();
      routePath.moveTo(routePoints.first.dx, routePoints.first.dy);
      for (int i = 1; i < routePoints.length; i++) {
        routePath.lineTo(routePoints[i].dx, routePoints[i].dy);
      }

      // Draw gray route background
      final routeBgPaint = Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(routePath, routeBgPaint);

      // Now draw active path according to progress
      final activePath = Path();
      activePath.moveTo(routePoints.first.dx, routePoints.first.dy);

      // Calculate path up to progress
      int numSegments = routePoints.length - 1;
      double segmentProgress = progress * numSegments;
      int activeIndex = segmentProgress.floor();
      double localT = segmentProgress - activeIndex;

      for (int i = 1; i <= activeIndex && i < routePoints.length; i++) {
        activePath.lineTo(routePoints[i].dx, routePoints[i].dy);
      }
      if (activeIndex < numSegments && activeIndex + 1 < routePoints.length) {
        Offset pA = routePoints[activeIndex];
        Offset pB = routePoints[activeIndex + 1];
        Offset pMid = Offset.lerp(pA, pB, localT)!;
        activePath.lineTo(pMid.dx, pMid.dy);
      }

      // Draw active glow
      final glowPaint = Paint()
        ..color = AppColors.secondary.withOpacity(0.3)
        ..strokeWidth = 12
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(activePath, glowPaint);

      // Draw active solid path
      final activeSolidPaint = Paint()
        ..color = AppColors.secondary
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(activePath, activeSolidPaint);
    }
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.routePoints != routePoints;
  }
}

class PhoneCallScreen extends StatefulWidget {
  const PhoneCallScreen({super.key});

  @override
  State<PhoneCallScreen> createState() => _PhoneCallScreenState();
}

class _PhoneCallScreenState extends State<PhoneCallScreen> {
  int _seconds = 0;
  Timer? _timer;
  bool _isMuted = false;
  bool _isSpeaker = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    // Simulate connection after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isConnected = true;
        });
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFF0F1A3A), Color(0xFF060B18)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Details
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Column(
                  children: [
                    // Network Signal Label
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi, color: AppColors.secondary, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'QuickWash Voice Link'.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Driver Avatar with glowing borders
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.secondary.withOpacity(0.3), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                        color: AppColors.surfaceBright,
                      ),
                      child: ClipOval(
                        child: Image.network(
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person_rounded, color: Colors.white, size: 54);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Jatin',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isConnected ? _formatDuration(_seconds) : 'Ringing...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isConnected ? AppColors.secondary : Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),

              // Voice wave visualization (only when connected)
              if (_isConnected)
                SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(8, (index) {
                      return _VoiceBar(index: index);
                    }),
                  ),
                )
              else
                const SizedBox(height: 60),

              // Bottom buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 60.0),
                child: Column(
                  children: [
                    // Mute and Speaker Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCallOptionButton(
                          icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                          label: 'Mute',
                          isActive: _isMuted,
                          onTap: () {
                            setState(() {
                              _isMuted = !_isMuted;
                            });
                          },
                        ),
                        const SizedBox(width: 48),
                        _buildCallOptionButton(
                          icon: _isSpeaker ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                          label: 'Speaker',
                          isActive: _isSpeaker,
                          onTap: () {
                            setState(() {
                              _isSpeaker = !_isSpeaker;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    // End call button
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.errorContainer,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.errorContainer.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.call_end_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallOptionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.08),
              border: Border.all(
                color: isActive ? Colors.white : Colors.white.withOpacity(0.15),
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.black : Colors.white,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _VoiceBar extends StatefulWidget {
  final int index;
  const _VoiceBar({required this.index});

  @override
  State<_VoiceBar> createState() => _VoiceBarState();
}

class _VoiceBarState extends State<_VoiceBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + (widget.index * 100)),
    )..repeat(reverse: true);

    _heightAnimation = Tween<double>(begin: 8.0, end: 45.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, _) {
        return Container(
          width: 4,
          height: _heightAnimation.value,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.7),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }
}

