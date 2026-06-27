import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_app_bar.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/quantity_selector.dart';
import '../../services/local_database.dart';

class TopsCategoryScreen extends StatefulWidget {
  const TopsCategoryScreen({super.key});

  @override
  State<TopsCategoryScreen> createState() => _TopsCategoryScreenState();
}

class _TopsCategoryScreenState extends State<TopsCategoryScreen> {
  final Map<String, int> _quantities = {
    'T-Shirt': 0,
    'Shirt': 0,
    'Polo': 0,
    'Sweater': 0,
  };

  final Map<String, double> _prices = {
    'T-Shirt': 60.0,
    'Shirt': 80.0,
    'Polo': 70.0,
    'Sweater': 120.0,
  };

  final Map<String, String> _emojis = {
    'T-Shirt': '👕',
    'Shirt': '👔',
    'Polo': '👕',
    'Sweater': '🧥',
  };

  // Per-item services
  final Map<String, List<String>> _itemServices = {
    'T-Shirt': ['Wash & Fold'],
    'Shirt': ['Wash & Fold'],
    'Polo': ['Wash & Fold'],
    'Sweater': ['Dry Clean'],
  };

  final List<String> _availableServices = [
    'Wash & Fold',
    'Dry Clean',
    'Steam Press',
    'Stain Removal',
  ];

  @override
  void initState() {
    super.initState();
    // Load existing items from AppState cart
    final cart = AppState().cartItems;
    for (final cartItem in cart) {
      if (cartItem['category'] == 'Tops' && _quantities.containsKey(cartItem['item'])) {
        _quantities[cartItem['item']] = cartItem['quantity'] as int;
        final List<dynamic> servicesList = cartItem['services'] ?? [];
        _itemServices[cartItem['item']] = servicesList.map((e) => e.toString()).toList();
      }
    }
  }

  void _updateItem(String item, int qty, List<String> services) async {
    setState(() {
      _quantities[item] = qty;
      _itemServices[item] = services;
    });

    final appState = AppState();
    final price = _prices[item]!;
    final emoji = _emojis[item]!;

    // Auto-sync to cart
    await appState.addToCart(
      category: 'Tops',
      item: item,
      emoji: emoji,
      quantity: qty,
      services: services.isNotEmpty ? services : ['Wash & Fold'],
      basePrice: price,
    );
  }

  void _handleAddToOrder() {
    int addedCount = 0;
    for (final qty in _quantities.values) {
      if (qty > 0) addedCount += qty;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(addedCount > 0 
              ? 'Added $addedCount Tops to order!' 
              : 'Tops items updated.'),
          backgroundColor: AppColors.secondary,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSelected = _quantities.values.fold<int>(0, (sum, val) => sum + val);

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
            const GlassAppBar(
              title: 'Tops Care',
              showBack: true,
              showAvatar: false,
              showNotification: false,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1E3A8A),
                            Color(0xFF0D9488),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Wear Care',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Custom services for each of your tops',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Item list section title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Items & Services',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          '$totalSelected selected',
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // List view instead of GridView to accommodate per-item services beautifully
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      children: _quantities.keys.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _ItemCard(
                            name: item,
                            emoji: _emojis[item]!,
                            basePrice: _prices[item]!,
                            initialQuantity: _quantities[item]!,
                            initialServices: _itemServices[item]!,
                            availableServices: _availableServices,
                            onChanged: (qty, services) => _updateItem(item, qty, services),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Bar
            Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
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
                label: 'Add to Order  →',
                onPressed: _handleAddToOrder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemCard extends StatefulWidget {
  final String name;
  final String emoji;
  final double basePrice;
  final int initialQuantity;
  final List<String> initialServices;
  final List<String> availableServices;
  final Function(int qty, List<String> services) onChanged;

  const _ItemCard({
    required this.name,
    required this.emoji,
    required this.basePrice,
    required this.initialQuantity,
    required this.initialServices,
    required this.availableServices,
    required this.onChanged,
  });

  @override
  State<_ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<_ItemCard> {
  late int _quantity;
  late List<String> _selectedServices;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
    _selectedServices = List.from(widget.initialServices);
  }

  @override
  void didUpdateWidget(covariant _ItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuantity != widget.initialQuantity) {
      _quantity = widget.initialQuantity;
    }
    if (oldWidget.initialServices != widget.initialServices) {
      _selectedServices = List.from(widget.initialServices);
    }
  }

  double get _currentPrice {
    final count = _selectedServices.length;
    final multiplier = count > 0 ? (1.0 + (count - 1) * 0.5) : 1.0;
    return widget.basePrice * multiplier;
  }

  void _toggleService(String service) {
    setState(() {
      if (_selectedServices.contains(service)) {
        _selectedServices.remove(service);
      } else {
        _selectedServices.add(service);
      }
    });
    widget.onChanged(_quantity, _selectedServices);
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = _quantity > 0;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      optimizePerformance: true,
      borderColor: isSelected ? AppColors.secondary : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${_currentPrice.toInt()} per item',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? AppColors.secondary : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              QuantitySelector(
                quantity: _quantity,
                onChanged: (val) {
                  setState(() {
                    _quantity = val;
                  });
                  widget.onChanged(val, _selectedServices);
                },
                size: 34,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Services:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.availableServices.map((service) {
              final active = _selectedServices.contains(service);
              return GestureDetector(
                onTap: () => _toggleService(service),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.secondary.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active ? AppColors.secondary : AppColors.glassBorder,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    service,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: active ? AppColors.secondary : AppColors.onSurface,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
