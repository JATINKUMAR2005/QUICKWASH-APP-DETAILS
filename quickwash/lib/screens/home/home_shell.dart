import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_bottom_nav.dart';
import '../../widgets/glass_app_bar.dart';
import '../home/home_screen.dart';
import '../orders/orders_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;
  bool _isBottomNavVisible = true;

  final List<Widget> _screens = const [
    HomeScreen(),
    OrdersScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: NotificationListener<Notification>(
        onNotification: (notification) {
          if (notification is TabNavigationNotification) {
            setState(() {
              _currentIndex = notification.index;
              _isBottomNavVisible = true;
            });
            return true;
          } else if (notification is UserScrollNotification) {
            if (notification.direction == ScrollDirection.reverse) {
              if (_isBottomNavVisible) {
                setState(() {
                  _isBottomNavVisible = false;
                });
              }
            } else if (notification.direction == ScrollDirection.forward) {
              if (!_isBottomNavVisible) {
                setState(() {
                  _isBottomNavVisible = true;
                });
              }
            }
          }
          return false;
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.5,
              colors: [Color(0xFF0A1535), Color(0xFF0A0F1E)],
            ),
          ),
          child: Stack(
            children: [
              IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: 0,
                right: 0,
                bottom: _isBottomNavVisible ? 0 : -100 - MediaQuery.of(context).padding.bottom,
                child: GlassBottomNav(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                      _isBottomNavVisible = true;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
