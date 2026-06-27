import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_app_bar.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/quantity_selector.dart';
import '../../services/local_database.dart';

class BeddingScreen extends StatefulWidget {
  const BeddingScreen({super.key});

  @override
  State<BeddingScreen> createState() => _BeddingScreenState();
}

class _BeddingScreenState extends State<BeddingScreen> {
  final Map<String, int> _quantities = {
    'Bed Sheet': 0,
    'Blanket/Quilt': 0,
    'Pillow Cover': 0,
    'Curtain': 0,
  };

  final Map<String, double> _prices = {
    'Bed Sheet': 120.0,
    'Blanket/Quilt': 250.0,
    'Pillow Cover': 40.0,
    'Curtain': 200.0,
  };

  final Map<String, String> _emojis = {
    'Bed Sheet': '🛏️',
    'Blanket/Quilt': '🧣',
    'Pillow Cover': '🛌',
    'Curtain': '🪟',
  };

  String _selectedBedSheetSize = 'Double'; // Only applies to Bed Sheet

  @override
  void initState() {
    super.initState();
    final cart = AppState().cartItems;
    for (final cartItem in cart) {
      if (cartItem['category'] == 'Bedding' && _quantities.containsKey(cartItem['item'])) {
        _quantities[cartItem['item']] = cartItem['quantity'] as int;
        // Only restore size for Bed Sheet
        if (cartItem['item'] == 'Bed Sheet' && cartItem['services'].isNotEmpty) {
          _selectedBedSheetSize = cartItem['services'][0] as String;
        }
      }
    }
  }

  void _syncItemToCart(String itemName, int qty) async {
    final appState = AppState();
    final price = _prices[itemName]!;
    final emoji = _emojis[itemName]!;

    // Only Bed Sheet gets size-adjusted pricing
    double finalPrice = price;
    List<String> services;
    if (itemName == 'Bed Sheet') {
      services = [_selectedBedSheetSize];
      if (_selectedBedSheetSize == 'Single') {
        finalPrice -= 30.0;
      } else if (_selectedBedSheetSize == 'King') {
        finalPrice += 60.0;
      }
    } else {
      services = ['Standard'];
    }

    await appState.addToCart(
      category: 'Bedding',
      item: itemName,
      emoji: emoji,
      quantity: qty,
      services: services,
      basePrice: finalPrice,
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
              ? 'Added $addedCount Bedding items to order!' 
              : 'Bedding items updated.'),
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
              title: 'Bedding & Linen',
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
                    // Items Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Items',
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

                    // Bed Sheet card with size selector inline
                    _buildBedSheetCard(),
                    const SizedBox(height: 16),

                    // Other items grid (no size selector)
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: isSmallScreen ? 0.75 : 0.82,
                      children: [
                        _buildBeddingCard('Blanket/Quilt'),
                        _buildBeddingCard('Pillow Cover'),
                        _buildBeddingCard('Curtain'),
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

  // Special card for Bed Sheet with size selector
  Widget _buildBedSheetCard() {
    final qty = _quantities['Bed Sheet']!;
    final basePrice = _prices['Bed Sheet']!;

    double displayPrice = basePrice;
    if (_selectedBedSheetSize == 'Single') {
      displayPrice -= 30;
    } else if (_selectedBedSheetSize == 'King') {
      displayPrice += 60;
    }

    return GlassCard(
      padding: const EdgeInsets.all(16),
      optimizePerformance: true,
      borderColor: qty > 0 ? AppColors.secondary : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🛏️', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bed Sheet',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      '₹${displayPrice.toInt()} per sheet',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: qty > 0 ? AppColors.secondary : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              QuantitySelector(
                quantity: qty,
                onChanged: (v) {
                  setState(() => _quantities['Bed Sheet'] = v);
                  _syncItemToCart('Bed Sheet', v);
                },
                size: 34,
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Size selector — only for Bed Sheet
          Row(
            children: [
              Text(
                'Size:  ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              _buildSizeChip('Single', '₹-30'),
              const SizedBox(width: 6),
              _buildSizeChip('Double', 'Std'),
              const SizedBox(width: 6),
              _buildSizeChip('King', '₹+60'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSizeChip(String size, String priceMod) {
    final isSelected = _selectedBedSheetSize == size;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBedSheetSize = size;
        });
        // Sync Bed Sheet if in order
        final qty = _quantities['Bed Sheet']!;
        if (qty > 0) {
          _syncItemToCart('Bed Sheet', qty);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.secondary.withValues(alpha: 0.15) 
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.glassBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              size,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.secondary : AppColors.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              priceMod,
              style: TextStyle(
                fontSize: 9,
                color: isSelected ? AppColors.secondary : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeddingCard(String name) {
    final qty = _quantities[name]!;
    final basePrice = _prices[name]!;
    final emoji = _emojis[name]!;

    return GlassCard(
      padding: const EdgeInsets.all(12),
      optimizePerformance: true,
      borderColor: qty > 0 ? AppColors.secondary : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          Text(
            name,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          Text(
            '₹${basePrice.toInt()}',
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
