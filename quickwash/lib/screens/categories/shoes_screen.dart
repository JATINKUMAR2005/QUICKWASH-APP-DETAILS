import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_app_bar.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/quantity_selector.dart';
import '../../services/local_database.dart';

class ShoesCategoryScreen extends StatefulWidget {
  const ShoesCategoryScreen({super.key});

  @override
  State<ShoesCategoryScreen> createState() => _ShoesCategoryScreenState();
}

class _ShoesCategoryScreenState extends State<ShoesCategoryScreen> {
  final Map<String, int> _quantities = {
    'Sports Shoes': 0,
    'Leather Shoes': 0,
    'Sneakers': 0,
    'Suede/Nubuck': 0,
  };

  final Map<String, double> _prices = {
    'Sports Shoes': 180.0,
    'Leather Shoes': 250.0,
    'Sneakers': 150.0,
    'Suede/Nubuck': 280.0,
  };

  final Map<String, String> _emojis = {
    'Sports Shoes': '👟',
    'Leather Shoes': '👞',
    'Sneakers': '👟',
    'Suede/Nubuck': '👢',
  };

  String _selectedCareLevel = 'Deep Clean'; // 'Basic', 'Deep Clean', 'Premium Restore'

  @override
  void initState() {
    super.initState();
    final cart = AppState().cartItems;
    for (final cartItem in cart) {
      if (cartItem['category'] == 'Shoes' && _quantities.containsKey(cartItem['item'])) {
        _quantities[cartItem['item']] = cartItem['quantity'] as int;
        if (cartItem['services'].isNotEmpty) {
          _selectedCareLevel = cartItem['services'][0] as String;
        }
      }
    }
  }

  void _syncItemToCart(String itemName, int qty) async {
    final appState = AppState();
    final price = _prices[itemName]!;
    final emoji = _emojis[itemName]!;

    // Compute display price based on select treatment
    double displayPrice = price;
    if (_selectedCareLevel == 'Basic') {
      displayPrice -= 30;
    } else if (_selectedCareLevel == 'Premium Restore') {
      displayPrice += 100;
    }

    await appState.addToCart(
      category: 'Shoes',
      item: itemName,
      emoji: emoji,
      quantity: qty,
      services: [_selectedCareLevel],
      basePrice: displayPrice,
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
              ? 'Added $addedCount pair(s) of Shoes to order!' 
              : 'Shoes items updated.'),
          backgroundColor: AppColors.secondary,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
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
              title: 'Shoe Spa',
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
                    // Care level selector
                    const Text(
                      'Choose Spa Treatment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildCareLevelButton('Basic', '₹-30'),
                        const SizedBox(width: 8),
                        _buildCareLevelButton('Deep Clean', 'Std'),
                        const SizedBox(width: 8),
                        _buildCareLevelButton('Premium Restore', '₹+100'),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Item listing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Footwear',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          '${_quantities.values.fold(0, (sum, val) => sum + val)} selected',
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: isSmallScreen ? 0.70 : 0.82,
                      children: [
                        _buildFootwearCard('Sports Shoes'),
                        _buildFootwearCard('Leather Shoes'),
                        _buildFootwearCard('Sneakers'),
                        _buildFootwearCard('Suede/Nubuck'),
                      ],
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

  Widget _buildCareLevelButton(String level, String priceMod) {
    final isSelected = _selectedCareLevel == level;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCareLevel = level;
          });
          // Sync all non-zero items to cart with updated price/treatment
          _quantities.forEach((itemName, qty) {
            if (qty > 0) {
              _syncItemToCart(itemName, qty);
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.secondary.withValues(alpha: 0.15) 
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.secondary : AppColors.glassBorder,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                level,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.secondary : AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                priceMod,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? AppColors.secondary : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFootwearCard(String name) {
    final qty = _quantities[name]!;
    final basePrice = _prices[name]!;
    final emoji = _emojis[name]!;

    // Compute display price based on select treatment
    double displayPrice = basePrice;
    if (_selectedCareLevel == 'Basic') {
      displayPrice -= 30;
    } else if (_selectedCareLevel == 'Premium Restore') {
      displayPrice += 100;
    }

    return GlassCard(
      padding: const EdgeInsets.all(12),
      optimizePerformance: true,
      borderColor: qty > 0 ? AppColors.secondary : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              name,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
          Text(
            '₹${displayPrice.toInt()}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: qty > 0 ? AppColors.secondary : AppColors.onSurfaceVariant,
            ),
          ),
          QuantitySelector(
            quantity: qty,
            onChanged: (v) {
              setState(() => _quantities[name] = v);
              _syncItemToCart(name, v);
            },
            size: 30,
          ),
        ],
      ),
    );
  }
}
