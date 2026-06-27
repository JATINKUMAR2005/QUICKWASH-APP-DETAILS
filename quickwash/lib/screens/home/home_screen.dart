import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_app_bar.dart';
import '../../widgets/category_card.dart';
import '../../services/local_database.dart';
import '../categories/all_categories_screen.dart';
import '../categories/tops_category_screen.dart';
import '../categories/bottoms_category_screen.dart';
import '../categories/ethnic_wear_screen.dart';
import '../categories/formals_screen.dart';
import '../categories/shoes_screen.dart';
import '../categories/bedding_screen.dart';
import '../payment/cart_review_screen.dart';
import '../payment/order_tracking_screen.dart';
import 'wallet_screen.dart';
import 'promos_screen.dart';
import '../../widgets/video_background.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> _searchResults = [];
  bool _showSearchResults = false;

  // All searchable items
  static final List<Map<String, dynamic>> _searchIndex = [
    // Categories
    {'name': 'Tops', 'type': 'Category', 'emoji': '👕', 'route': 'Tops'},
    {'name': 'Bottoms', 'type': 'Category', 'emoji': '👖', 'route': 'Bottoms'},
    {'name': 'Ethnic Wear', 'type': 'Category', 'emoji': '🥻', 'route': 'Ethnic'},
    {'name': 'Formals', 'type': 'Category', 'emoji': '👔', 'route': 'Formals'},
    {'name': 'Shoes', 'type': 'Category', 'emoji': '👟', 'route': 'Shoes'},
    {'name': 'Bedding & Linen', 'type': 'Category', 'emoji': '🛏', 'route': 'Bedding'},
    // Items
    {'name': 'T-Shirt', 'type': 'Item • Tops', 'emoji': '👕', 'route': 'Tops'},
    {'name': 'Shirt', 'type': 'Item • Tops', 'emoji': '👔', 'route': 'Tops'},
    {'name': 'Polo', 'type': 'Item • Tops', 'emoji': '👕', 'route': 'Tops'},
    {'name': 'Sweater', 'type': 'Item • Tops', 'emoji': '🧥', 'route': 'Tops'},
    {'name': 'Jeans', 'type': 'Item • Bottoms', 'emoji': '👖', 'route': 'Bottoms'},
    {'name': 'Trousers', 'type': 'Item • Bottoms', 'emoji': '👖', 'route': 'Bottoms'},
    {'name': 'Shorts', 'type': 'Item • Bottoms', 'emoji': '🩳', 'route': 'Bottoms'},
    {'name': 'Skirt', 'type': 'Item • Bottoms', 'emoji': '👗', 'route': 'Bottoms'},
    {'name': 'Saree', 'type': 'Item • Ethnic', 'emoji': '🥻', 'route': 'Ethnic'},
    {'name': 'Kurta Set', 'type': 'Item • Ethnic', 'emoji': '🥻', 'route': 'Ethnic'},
    {'name': 'Lehenga', 'type': 'Item • Ethnic', 'emoji': '👗', 'route': 'Ethnic'},
    {'name': 'Sherwani', 'type': 'Item • Ethnic', 'emoji': '🧥', 'route': 'Ethnic'},
    {'name': 'Suit / Blazer', 'type': 'Item • Formals', 'emoji': '🧥', 'route': 'Formals'},
    {'name': 'Formal Shirt', 'type': 'Item • Formals', 'emoji': '👔', 'route': 'Formals'},
    {'name': 'Sports Shoes', 'type': 'Item • Shoes', 'emoji': '👟', 'route': 'Shoes'},
    {'name': 'Leather Shoes', 'type': 'Item • Shoes', 'emoji': '👞', 'route': 'Shoes'},
    {'name': 'Sneakers', 'type': 'Item • Shoes', 'emoji': '👟', 'route': 'Shoes'},
    {'name': 'Bed Sheet', 'type': 'Item • Bedding', 'emoji': '🛏️', 'route': 'Bedding'},
    {'name': 'Blanket', 'type': 'Item • Bedding', 'emoji': '🧣', 'route': 'Bedding'},
    {'name': 'Pillow Cover', 'type': 'Item • Bedding', 'emoji': '🛌', 'route': 'Bedding'},
    {'name': 'Curtain', 'type': 'Item • Bedding', 'emoji': '🪟', 'route': 'Bedding'},
    // Services
    {'name': 'Wash & Fold', 'type': 'Service', 'emoji': '🧺', 'route': 'Categories'},
    {'name': 'Dry Clean', 'type': 'Service', 'emoji': '🧹', 'route': 'Categories'},
    {'name': 'Steam Press', 'type': 'Service', 'emoji': '♨️', 'route': 'Categories'},
    {'name': 'Stain Removal', 'type': 'Service', 'emoji': '✨', 'route': 'Categories'},
    // Pages
    {'name': 'My Orders', 'type': 'Page', 'emoji': '📦', 'route': 'Orders'},
    {'name': 'Profile', 'type': 'Page', 'emoji': '👤', 'route': 'Profile'},
    {'name': 'Wallet', 'type': 'Page', 'emoji': '💰', 'route': 'Wallet'},
    {'name': 'Promos & Offers', 'type': 'Page', 'emoji': '🎟️', 'route': 'Promos'},
    {'name': 'Notifications', 'type': 'Page', 'emoji': '🔔', 'route': 'Notifications'},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && _searchController.text.isEmpty) {
        setState(() => _showSearchResults = false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    final results = _searchIndex
        .where((item) => (item['name'] as String).toLowerCase().contains(query) ||
                         (item['type'] as String).toLowerCase().contains(query))
        .toList();

    setState(() {
      _searchResults = results;
      _showSearchResults = true;
    });
  }

  void _navigateFromSearch(String route) {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() => _showSearchResults = false);

    switch (route) {
      case 'Wallet':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WalletScreen()));
        return;
      case 'Promos':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PromosScreen()));
        return;
      case 'Categories':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AllCategoriesScreen()));
        return;
      default:
        _navigateToCategory(context, route);
    }
  }

  void _navigateToCategory(BuildContext context, String category) {
    Widget screen;
    switch (category) {
      case 'Tops':
        screen = const TopsCategoryScreen();
        break;
      case 'Bottoms':
        screen = const BottomsCategoryScreen();
        break;
      case 'Ethnic Wear':
      case 'Ethnic':
        screen = const EthnicWearScreen();
        break;
      case 'Formals':
        screen = const FormalsScreen();
        break;
      case 'Shoes':
        screen = const ShoesCategoryScreen();
        break;
      case 'Bedding':
        screen = const BeddingScreen();
        break;
      default:
        screen = const AllCategoriesScreen();
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final greetingFontSize = isSmallScreen ? 20.0 : 24.0;
    final promoCardWidth = (screenWidth * 0.72).clamp(220.0, 320.0);

    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        
        // Dynamic User Details
        final user = appState.currentUser ?? {
          'name': 'Jatin',
          'balance': 1240.0,
        };
        final String name = user['name'] ?? 'Jatin';
        final double walletBalance = (user['balance'] as num?)?.toDouble() ?? 1240.0;

        // Find active order from db (user-specific)
        final userOrders = appState.getUserOrders();
        final activeOrderIndex = userOrders.indexWhere((o) => o['status'] != 'Completed');
        final hasActiveOrder = activeOrderIndex != -1;
        final activeOrder = hasActiveOrder ? userOrders[activeOrderIndex] : null;

        // Fetch completed orders for history
        final cartCount = appState.getCartItemCount();

        return VideoBackground(
          overlayOpacity: 0.78,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: const GlassAppBar(
              avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCKRTE9bK_hyA9-2U9HmReb_l9KQ4vQGsWt2sqIRc3YTyfdcFE6NdId_kV9OhrshxJYWakj7S2pf-fcloGfukf4lCIGH6Wvilgvvg6ubQrnI7f1FBhHh3iEqKgfzxIQPM9_0kWRjC5nZU26sSkNZfL06nqJtOT5EsAbxJnjvMHc5AVYcx-OFwPlYrHYsP6c75-ye-6drm2tfhDitWUUK90-PPloCAwNNc4CYcwKnnTG0mN0_RH4nq98-sPICSlJhgjwYqt8t_AZRl0',
            ),
            body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Greeting — responsive
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${_getGreeting()}, $name 👋',
                          style: TextStyle(
                            fontSize: greetingFontSize,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'What needs cleaning today?',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13.0 : 15.0,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Search bar — functional
                      GlassCard(
                        borderRadius: 999,
                        optimizePerformance: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                decoration: InputDecoration(
                                  hintText: 'Search for items, categories...',
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                style: const TextStyle(color: AppColors.onSurface),
                                onTap: () {
                                  if (_searchController.text.isNotEmpty) {
                                    setState(() => _showSearchResults = true);
                                  }
                                },
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  _searchFocusNode.unfocus();
                                },
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: AppColors.onSurfaceVariant,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Active order card
                      if (hasActiveOrder && activeOrder != null)
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OrderTrackingScreen(
                                  orderId: activeOrder['orderId'] as String,
                                ),
                              ),
                            );
                          },
                          child: GlassCard(
                            glowBlue: true,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      activeOrder['emoji'] as String? ?? '🧺',
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ACTIVE ORDER',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 10.0 : 11.0,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        activeOrder['orderId'] as String? ?? '#QW-1042',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 16.0 : 18.0,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                      Text(
                                        activeOrder['status'] as String? ?? 'Out for Delivery',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 12.0 : 13.0,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        GlassCard(
                          padding: const EdgeInsets.all(16),
                          optimizePerformance: true,
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.local_laundry_service_outlined,
                                  color: AppColors.onSurfaceVariant,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'NO ACTIVE ORDERS',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "Let's schedule a pickup!",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Promo carousel — responsive width
                      SizedBox(
                        height: 144,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          children: [
                            _PromoCard(
                              title: '40% OFF',
                              subtitle: 'On first 5 orders this week',
                              icon: Icons.loyalty_rounded,
                              gradient: const [Color(0xFF4338CA), Color(0xFF7E22CE)],
                              width: promoCardWidth,
                            ),
                            const SizedBox(width: 12),
                            _PromoCard(
                              title: 'Eco-Wash',
                              subtitle: 'Sustainable detergent options',
                              icon: Icons.eco_rounded,
                              gradient: const [Color(0xFF0D9488), Color(0xFF047857)],
                              width: promoCardWidth,
                            ),
                            const SizedBox(width: 12),
                            _PromoCard(
                              title: 'Gold Member',
                              subtitle: 'Priority 12-hour delivery',
                              icon: Icons.stars_rounded,
                              gradient: const [Color(0xFFF59E0B), Color(0xFFEA580C)],
                              width: promoCardWidth,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Categories Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Categories',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 18.0 : 20.0,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AllCategoriesScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Categories Grid — responsive aspect ratio
                      GridView.count(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: isSmallScreen ? 0.85 : 0.95,
                        children: [
                          CategoryCard(
                            emoji: '👕',
                            label: 'Tops',
                            onTap: () => _navigateToCategory(context, 'Tops'),
                          ),
                          CategoryCard(
                            emoji: '👖',
                            label: 'Bottoms',
                            onTap: () => _navigateToCategory(context, 'Bottoms'),
                          ),
                          CategoryCard(
                            emoji: '🥻',
                            label: 'Ethnic',
                            onTap: () => _navigateToCategory(context, 'Ethnic'),
                          ),
                          CategoryCard(
                            emoji: '👔',
                            label: 'Formals',
                            onTap: () => _navigateToCategory(context, 'Formals'),
                          ),
                          CategoryCard(
                            emoji: '👟',
                            label: 'Shoes',
                            onTap: () => _navigateToCategory(context, 'Shoes'),
                          ),
                          CategoryCard(
                            emoji: '🛏',
                            label: 'Bedding',
                            onTap: () => _navigateToCategory(context, 'Bedding'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // More categories button
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AllCategoriesScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.glassWhite6,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 1,
                              strokeAlign: BorderSide.strokeAlignInside,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'More Categories',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Wallet & Promos — now tappable
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const WalletScreen()),
                                );
                              },
                              child: GlassCard(
                                padding: const EdgeInsets.all(16),
                                optimizePerformance: true,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'WALLET',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '₹${walletBalance.toInt()}',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Add Credits',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.secondary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 14,
                                          color: AppColors.secondary,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const PromosScreen()),
                                );
                              },
                              child: GlassCard(
                                padding: const EdgeInsets.all(16),
                                optimizePerformance: true,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PROMOS',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      '04',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'View Tickets',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.tertiary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.confirmation_number_outlined,
                                          size: 14,
                                          color: AppColors.tertiary,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Trust markers
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                            horizontal: BorderSide(
                              color: Colors.white.withValues(alpha: 0.05),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _TrustMarker(
                              icon: Icons.bolt_rounded,
                              label: 'Express',
                              color: AppColors.primary,
                            ),
                            _TrustMarker(
                              icon: Icons.savings_rounded,
                              label: 'Save 30%',
                              color: AppColors.secondary,
                            ),
                            _TrustMarker(
                              icon: Icons.verified_rounded,
                              label: 'Guaranteed',
                              color: AppColors.tertiary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const HomepageVideoCard(),
                      const SizedBox(height: 24),

                      // Latest News list
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Latest News',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 18.0 : 20.0,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const Icon(
                            Icons.newspaper_rounded,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const _NewsCard(
                        title: 'Now Serving Sector 56, Gurgaon!',
                        description: 'We have expanded our operations. Enjoy 12-hour express pickup and delivery starting today.',
                        time: '2 hours ago',
                        category: 'Expansion',
                      ),
                      const SizedBox(height: 12),
                      const _NewsCard(
                        title: 'How to Care for Ethnic Silk Wear',
                        description: 'Specialized fabric tips from our master dry cleaners on preserving luster and strength.',
                        time: '5 hours ago',
                        category: 'Care Tips',
                      ),
                      const SizedBox(height: 12),
                      const _NewsCard(
                        title: '100% Eco-Friendly Detergents',
                        description: 'All our laundry cycles now exclusively use organic, biodegradable cleaning agents.',
                        time: '1 day ago',
                        category: 'Sustainability',
                      ),
                    ],
                  ),
                ),
              ),
              // Search results overlay
              if (_showSearchResults)
                Positioned(
                  top: 96, // Below search bar
                  left: 20,
                  right: 20,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      constraints: BoxConstraints(maxHeight: screenHeight * 0.45),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141B2F),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.glassBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _searchResults.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(24),
                                child: Center(
                                  child: Text(
                                    'No results found',
                                    style: TextStyle(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                itemCount: _searchResults.length,
                                separatorBuilder: (_, __) => const Divider(
                                  color: Colors.white10,
                                  height: 1,
                                ),
                                itemBuilder: (context, index) {
                                  final result = _searchResults[index];
                                  return ListTile(
                                    dense: true,
                                    leading: Text(
                                      result['emoji'] as String,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                    title: Text(
                                      result['name'] as String,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    subtitle: Text(
                                      result['type'] as String,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.onSurfaceVariant,
                                      size: 20,
                                    ),
                                    onTap: () => _navigateFromSearch(result['route'] as String),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Cart FAB — now goes to CartReviewScreen
          floatingActionButton: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56,
                height: 56,
                margin: const EdgeInsets.only(bottom: 80),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gradientBlueStart, AppColors.gradientCyanEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CartReviewScreen(),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
              // Cart items indicator badge
              if (cartCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.error,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '$cartCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
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

class _PromoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final double width;

  const _PromoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    this.width = 280,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -8,
            right: -8,
            child: Opacity(
              opacity: 0.2,
              child: Icon(icon, size: 64, color: Colors.white),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrustMarker extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TrustMarker({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}


class _NewsCard extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final String category;

  const _NewsCard({
    required this.title,
    required this.description,
    required this.time,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class HomepageVideoCard extends StatefulWidget {
  const HomepageVideoCard({super.key});

  @override
  State<HomepageVideoCard> createState() => _HomepageVideoCardState();
}

class _HomepageVideoCardState extends State<HomepageVideoCard> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse('https://assets.mixkit.co/videos/preview/mixkit-washing-machine-drum-spinning-43019-large.mp4'),
      );
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller!.setLooping(true);
        _controller!.setVolume(0.0);
        _controller!.play();
      }
    } catch (e) {
      debugPrint('HomepageVideoCard initialization failed: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) return const SizedBox.shrink();

    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 24,
      optimizePerformance: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Icon(Icons.play_circle_outline_rounded, color: AppColors.secondary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Watch Our Process',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 160,
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isInitialized && _controller != null)
                    Positioned.fill(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller!.value.size.width,
                          height: _controller!.value.size.height,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                    )
                  else
                    const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(AppColors.secondary),
                      ),
                    ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        if (_controller != null) {
                          setState(() {
                            if (_isPlaying) {
                              _controller!.pause();
                              _isPlaying = false;
                            } else {
                              _controller!.play();
                              _isPlaying = true;
                            }
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black54,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 16,
                    bottom: 16,
                    right: 48,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Automated Drum Care',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Delicate handling with high-spin moisture extraction.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
