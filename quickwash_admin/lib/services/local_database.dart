import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  SharedPreferences? _prefs;
  bool _initialized = false;

  // Cache fields
  Map<String, dynamic>? _currentUser;
  List<dynamic> _users = [];
  List<dynamic> _cartItems = [];
  List<dynamic> _orders = [];
  List<dynamic> _walletTransactions = [];
  List<dynamic> _notifications = [];

  bool get isInitialized => _initialized;
  Map<String, dynamic>? get currentUser => _currentUser;
  List<dynamic> get cartItems => _cartItems;
  List<dynamic> get orders => _orders;
  List<dynamic> get walletTransactions => _walletTransactions;
  List<dynamic> get notifications => _notifications;

  // Check if Supabase should be used
  bool get isSupabaseEnabled => SupabaseConfig.isConfigured;

  // Access Supabase Client safely
  SupabaseClient get supabase {
    if (!isSupabaseEnabled) {
      throw StateError('Supabase is not configured. Please fill in supabase_config.dart.');
    }
    return Supabase.instance.client;
  }

  // Initialize DB and load default data if empty
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();

    if (isSupabaseEnabled) {
      final session = supabase.auth.currentSession;
      if (session != null) {
        try {
          await _loadDataFromSupabase();
        } catch (e) {
          debugPrint('Error loading Supabase data at init: $e');
        }
      }
      _initialized = true;
      notifyListeners();
      return;
    }

    // --- FALLBACK (SharedPreferences) initialization ---
    // Load users
    final usersStr = _prefs!.getString('qw_users') ?? '[]';
    _users = jsonDecode(usersStr);

    // Load current user session
    final userStr = _prefs!.getString('qw_current_user');
    if (userStr != null) {
      _currentUser = jsonDecode(userStr);
    }

    // Load cart
    _loadCartForCurrentUser();

    // Load notifications
    final notificationsStr = _prefs!.getString('qw_notifications');
    if (notificationsStr != null) {
      _notifications = jsonDecode(notificationsStr);
    } else {
      _notifications = [];
    }

    // Load orders
    final ordersStr = _prefs!.getString('qw_orders');
    if (ordersStr != null) {
      _orders = jsonDecode(ordersStr);
    } else {
      // Seed default orders attributed to default user
      _orders = [
        {
          'orderId': '#QW-IN-88219',
          'serviceName': 'Premium Wash & Fold',
          'itemCount': 12,
          'price': 420.0,
          'status': 'Out for Delivery',
          'progress': 0.85,
          'dateTime': 'Today, 2:30 PM',
          'emoji': '🧺',
          'itemsDetail': '6 T-Shirts, 4 Shirts, 2 Bed Sheets',
          'userPhone': '9876543210',
          'paymentMethod': 'Cash on Delivery',
          'cartSnapshot': [
            {'item': 'T-Shirt', 'emoji': '👕', 'category': 'Tops', 'quantity': 6, 'services': ['Wash & Fold'], 'price': 60.0},
            {'item': 'Shirt', 'emoji': '👔', 'category': 'Tops', 'quantity': 4, 'services': ['Wash & Fold'], 'price': 80.0},
            {'item': 'Bed Sheet', 'emoji': '🛏️', 'category': 'Bedding', 'quantity': 2, 'services': ['Double'], 'price': 120.0},
          ],
        },
        {
          'orderId': '#QW-IN-88224',
          'serviceName': 'Delicate Dry Cleaning',
          'itemCount': 4,
          'price': 480.0,
          'status': 'Processing',
          'progress': 0.30,
          'dateTime': 'Yesterday, 10:15 AM',
          'emoji': '👔',
          'itemsDetail': '2 Sweaters, 2 Shirts',
          'userPhone': '9876543210',
          'paymentMethod': 'UPI (Paytm, GPay, PhonePe)',
          'cartSnapshot': [
            {'item': 'Sweater', 'emoji': '🧥', 'category': 'Tops', 'quantity': 2, 'services': ['Dry Clean'], 'price': 120.0},
            {'item': 'Shirt', 'emoji': '👔', 'category': 'Tops', 'quantity': 2, 'services': ['Dry Clean'], 'price': 80.0},
          ],
        },
        {
          'orderId': '#QW-IN-88200',
          'serviceName': 'Weekly Laundry',
          'itemCount': 12,
          'price': 350.0,
          'status': 'Completed',
          'progress': 1.0,
          'dateTime': 'Yesterday, 6:30 PM',
          'emoji': '🧺',
          'itemsDetail': '12 T-Shirts',
          'userPhone': '9876543210',
          'paymentMethod': 'QuickWash Wallet',
          'cartSnapshot': [
            {'item': 'T-Shirt', 'emoji': '👕', 'category': 'Tops', 'quantity': 12, 'services': ['Wash & Fold'], 'price': 60.0},
          ],
        },
        {
          'orderId': '#QW-IN-88195',
          'serviceName': 'Office Formals',
          'itemCount': 5,
          'price': 450.0,
          'status': 'Completed',
          'progress': 1.0,
          'dateTime': '02 Oct, 10:15 AM',
          'emoji': '👔',
          'itemsDetail': '5 Formal Shirts',
          'userPhone': '9876543210',
          'paymentMethod': 'Credit/Debit Cards',
          'cartSnapshot': [
            {'item': 'Formal Shirt', 'emoji': '👔', 'category': 'Formals', 'quantity': 5, 'services': ['Dry Clean', 'Steam Press'], 'price': 80.0},
          ],
        }
      ];
      await _saveOrders();
    }

    // Load wallet transactions
    final txnStr = _prefs!.getString('qw_wallet_txns');
    if (txnStr != null) {
      _walletTransactions = jsonDecode(txnStr);
    } else {
      _walletTransactions = [
        {'type': 'credit', 'amount': 500.0, 'description': 'Welcome Bonus', 'date': '15 Jun, 10:00 AM'},
        {'type': 'credit', 'amount': 1000.0, 'description': 'Wallet Top-up', 'date': '16 Jun, 2:30 PM'},
        {'type': 'debit', 'amount': 260.0, 'description': 'Order #QW-IN-88200', 'date': 'Yesterday, 6:30 PM'},
      ];
      await _prefs!.setString('qw_wallet_txns', jsonEncode(_walletTransactions));
    }

    _initialized = true;
    notifyListeners();
  }

  // --- SUPABASE DATA FETCHING ---
  Future<void> _loadDataFromSupabase() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    // 1. Fetch Profile
    final profileRes = await supabase.from('profiles').select().eq('id', user.id).maybeSingle();
    if (profileRes != null) {
      _currentUser = Map<String, dynamic>.from(profileRes);
    } else {
      // Seed missing profile row
      final metadata = user.userMetadata ?? {};
      final name = metadata['name'] ?? 'Guest User';
      final phone = metadata['phone'] ?? '';
      _currentUser = {
        'id': user.id,
        'name': name,
        'email': user.email,
        'phone': phone,
        'balance': 0.0,
        'address': '',
        'role': 'customer',
      };
      await supabase.from('profiles').insert(_currentUser!);
    }

    final role = _currentUser?['role'] ?? 'customer';

    // 2. Fetch Cart Items
    final cartRes = await supabase.from('cart_items').select().eq('user_id', user.id);
    _cartItems = cartRes.map((item) => {
      'category': item['category'],
      'item': item['item'],
      'emoji': item['emoji'] ?? '👕',
      'quantity': item['quantity'],
      'services': List<String>.from(item['services'] ?? []),
      'price': (item['price'] as num).toDouble(),
    }).toList();

    // 3. Fetch Notifications
    var notifQuery = supabase.from('notifications').select();
    if (role != 'admin') {
      notifQuery = notifQuery.eq('user_id', user.id);
    }
    final notificationsRes = await notifQuery
        .order('created_at', ascending: false)
        .limit(30);
    _notifications = notificationsRes.map((n) => {
      'title': n['title'],
      'description': n['description'],
      'timeAgo': 'Just now',
      'status': n['status'],
      'orderId': n['order_id'],
      'type': n['type'],
      'timestamp': n['timestamp'],
    }).toList();

    // 4. Fetch Orders
    var orderQuery = supabase.from('orders').select();
    if (role == 'delivery') {
      orderQuery = orderQuery.eq('delivery_boy_id', user.id);
    } else if (role == 'customer') {
      orderQuery = orderQuery.eq('user_id', user.id);
    }
    
    final ordersRes = await orderQuery.order('created_at', ascending: false);
    _orders = ordersRes.map((o) => {
      'orderId': o['order_id'],
      'serviceName': o['service_name'],
      'itemCount': o['item_count'],
      'price': (o['price'] as num).toDouble(),
      'status': o['status'],
      'progress': (o['progress'] as num).toDouble(),
      'dateTime': o['date_time'],
      'emoji': o['emoji'] ?? '🧺',
      'itemsDetail': o['items_detail'],
      'paymentMethod': o['payment_method'],
      'userPhone': _currentUser?['phone'] ?? 'unknown',
      'cartSnapshot': o['cart_snapshot'],
      'pickupDate': o['pickup_date'],
      'pickupTime': o['pickup_time'],
      'dropoffDate': o['dropoff_date'],
      'dropoffTime': o['dropoff_time'],
      'delivery_boy_id': o['delivery_boy_id'],
    }).toList();

    // 5. Fetch Wallet Transactions
    var txnsQuery = supabase.from('wallet_transactions').select();
    if (role != 'admin') {
      txnsQuery = txnsQuery.eq('user_id', user.id);
    }
    final txnsRes = await txnsQuery.order('created_at', ascending: false);
    _walletTransactions = txnsRes.map((t) => {
      'type': t['type'],
      'amount': (t['amount'] as num).toDouble(),
      'description': t['description'],
      'date': t['date'],
    }).toList();
  }

  void _loadCartForCurrentUser() {
    final phone = _currentUser?['phone'] as String?;
    final cartKey = phone != null ? 'qw_cart_$phone' : 'qw_cart';
    final cartStr = _prefs!.getString(cartKey) ?? '[]';
    _cartItems = jsonDecode(cartStr);
  }

  Future<void> _saveCartForCurrentUser() async {
    final phone = _currentUser?['phone'] as String?;
    final cartKey = phone != null ? 'qw_cart_$phone' : 'qw_cart';
    await _prefs!.setString(cartKey, jsonEncode(_cartItems));
  }

  // --- USER AUTHENTICATION ---
  Future<bool> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (isSupabaseEnabled) {
      try {
        final emailToUse = email.isNotEmpty ? email : 'user_$phone@quickwash.in';
        final passwordToUse = password.isNotEmpty ? password : 'default_password';

        // Sign up with Supabase Auth
        final authRes = await supabase.auth.signUp(
          email: emailToUse,
          password: passwordToUse,
          data: {
            'name': name,
            'phone': phone,
          },
        );

        if (authRes.user == null) return false;

        // Create profile details mapping to user id
        final newUser = {
          'id': authRes.user!.id,
          'name': name,
          'email': emailToUse,
          'phone': phone,
          'balance': 0.0, // Initial wallet balance set to 0.0
          'address': '',
          'role': 'customer',
        };

        await supabase.from('profiles').insert(newUser);
        return true;
      } catch (e) {
        debugPrint('Supabase registration error: $e');
        return false;
      }
    }

    // --- FALLBACK (SharedPreferences) ---
    final exists = _users.any((u) => u['email'] == email || u['phone'] == phone);
    if (exists) return false;

    final newUser = {
      'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'balance': 0.0, // Initial wallet balance in Rupees set to 0.0
      'address': 'Flat 405, Block B, Cyber Heights, Hitec City, Hyderabad, 500081',
      'role': 'customer',
    };

    _users.add(newUser);
    await _prefs!.setString('qw_users', jsonEncode(_users));
    notifyListeners();
    return true;
  }

  Future<bool> loginUser(String emailOrPhone, String password) async {
    if (isSupabaseEnabled) {
      try {
        String emailToUse = emailOrPhone;
        String passwordToUse = password;

        if (!emailOrPhone.contains('@')) {
          emailToUse = 'user_$emailOrPhone@quickwash.in';
          if (password.isEmpty) {
            passwordToUse = 'default_password'; // Password fallback for OTP flow
          }
        }

        if (passwordToUse.isEmpty) {
          passwordToUse = 'default_password';
        }

        AuthResponse authRes;
        try {
          authRes = await supabase.auth.signInWithPassword(
            email: emailToUse,
            password: passwordToUse,
          );
        } catch (e) {
          // If login fails and we are using default password, register the user (auto OTP signup)
          if (passwordToUse == 'default_password') {
            authRes = await supabase.auth.signUp(
              email: emailToUse,
              password: passwordToUse,
              data: {
                'name': 'Guest User',
                'phone': emailOrPhone,
              },
            );

            if (authRes.user != null) {
              final newUserProfile = {
                'id': authRes.user!.id,
                'name': 'Guest User',
                'email': emailToUse,
                'phone': emailOrPhone,
                'balance': 0.0,
                'address': '',
              };
              await supabase.from('profiles').insert(newUserProfile);
            } else {
              rethrow;
            }
          } else {
            rethrow;
          }
        }

        if (authRes.user != null) {
          await _loadDataFromSupabase();
          notifyListeners();
          return true;
        }
        return false;
      } catch (e) {
        debugPrint('Supabase login error: $e');
        return false;
      }
    }

    // --- FALLBACK (SharedPreferences) ---
    for (final u in _users) {
      if ((u['email'] == emailOrPhone || u['phone'] == emailOrPhone) &&
          u['password'] == password) {
        _currentUser = Map<String, dynamic>.from(u);
        await _prefs!.setString('qw_current_user', jsonEncode(_currentUser));
        _loadCartForCurrentUser();
        notifyListeners();
        return true;
      }
    }
    // Hardcoded fallback for Jatin (default profile) with balance 0.0
    if (emailOrPhone == 'jatin' || emailOrPhone == '9876543210') {
      _currentUser = {
        'id': 'default_jatin',
        'name': 'Jatin',
        'email': 'jatin@quickwash.in',
        'phone': '9876543210',
        'balance': 0.0, // Set to 0.0
        'address': 'Sector 45, Gurgaon, Haryana, 122003',
        'role': 'customer',
      };
      await _prefs!.setString('qw_current_user', jsonEncode(_currentUser));
      _loadCartForCurrentUser();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    if (isSupabaseEnabled) {
      await supabase.auth.signOut();
      _currentUser = null;
      _cartItems = [];
      _orders = [];
      _walletTransactions = [];
      _notifications = [];
      notifyListeners();
      return;
    }

    // --- FALLBACK ---
    _currentUser = null;
    _cartItems = [];
    await _prefs!.remove('qw_current_user');
    notifyListeners();
  }

  Future<void> updateUserProfile({String? name, String? address, double? balance}) async {
    if (_currentUser == null) return;
    if (name != null) _currentUser!['name'] = name;
    if (address != null) _currentUser!['address'] = address;
    if (balance != null) _currentUser!['balance'] = balance;

    if (isSupabaseEnabled) {
      final userId = supabase.auth.currentUser!.id;
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (address != null) updates['address'] = address;
      if (balance != null) updates['balance'] = balance;
      updates['updated_at'] = DateTime.now().toUtc().toIso8601String();

      await supabase.from('profiles').update(updates).eq('id', userId);
    } else {
      // Update in users list as well
      for (var i = 0; i < _users.length; i++) {
        if (_users[i]['email'] == _currentUser!['email']) {
          _users[i] = _currentUser;
          break;
        }
      }
      await _prefs!.setString('qw_users', jsonEncode(_users));
      await _prefs!.setString('qw_current_user', jsonEncode(_currentUser));
    }
    notifyListeners();
  }

  // --- CART MANAGEMENT ---
  Future<void> addToCart({
    required String category,
    required String item,
    required String emoji,
    required int quantity,
    required List<String> services,
    required double basePrice,
  }) async {
    // Remove if already in cart to avoid duplicates
    _cartItems.removeWhere((c) => c['category'] == category && c['item'] == item);

    if (quantity > 0) {
      final newCartItem = {
        'category': category,
        'item': item,
        'emoji': emoji,
        'quantity': quantity,
        'services': services,
        'price': basePrice,
      };
      _cartItems.add(newCartItem);

      if (isSupabaseEnabled) {
        final userId = supabase.auth.currentUser!.id;
        // Delete if item already exists
        await supabase.from('cart_items').delete().eq('user_id', userId).eq('category', category).eq('item', item);
        // Insert new cart item
        await supabase.from('cart_items').insert({
          'user_id': userId,
          'category': category,
          'item': item,
          'emoji': emoji,
          'quantity': quantity,
          'services': services,
          'price': basePrice,
        });
      }
    } else {
      if (isSupabaseEnabled) {
        final userId = supabase.auth.currentUser!.id;
        await supabase.from('cart_items').delete().eq('user_id', userId).eq('category', category).eq('item', item);
      }
    }

    if (!isSupabaseEnabled) {
      await _saveCartForCurrentUser();
    }
    notifyListeners();
  }

  Future<void> updateCartItemQuantity(String category, String item, int newQuantity) async {
    if (newQuantity <= 0) {
      _cartItems.removeWhere((c) => c['category'] == category && c['item'] == item);
      if (isSupabaseEnabled) {
        final userId = supabase.auth.currentUser!.id;
        await supabase.from('cart_items').delete().eq('user_id', userId).eq('category', category).eq('item', item);
      }
    } else {
      final index = _cartItems.indexWhere((c) => c['category'] == category && c['item'] == item);
      if (index != -1) {
        _cartItems[index]['quantity'] = newQuantity;
        if (isSupabaseEnabled) {
          final userId = supabase.auth.currentUser!.id;
          await supabase.from('cart_items').update({
            'quantity': newQuantity,
          }).eq('user_id', userId).eq('category', category).eq('item', item);
        }
      }
    }

    if (!isSupabaseEnabled) {
      await _saveCartForCurrentUser();
    }
    notifyListeners();
  }

  Future<void> removeFromCart(String category, String item) async {
    _cartItems.removeWhere((c) => c['category'] == category && c['item'] == item);

    if (isSupabaseEnabled) {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('cart_items').delete().eq('user_id', userId).eq('category', category).eq('item', item);
    } else {
      await _saveCartForCurrentUser();
    }
    notifyListeners();
  }

  double getCartTotal() {
    double total = 0;
    for (final item in _cartItems) {
      final qty = item['quantity'] as int;
      final price = (item['price'] as num).toDouble();
      final servicesCount = (item['services'] as List).length;
      final serviceMultiplier = servicesCount > 0 ? (1.0 + (servicesCount - 1) * 0.5) : 1.0;
      total += qty * price * serviceMultiplier;
    }
    return total;
  }

  int getCartItemCount() {
    int total = 0;
    for (final item in _cartItems) {
      total += item['quantity'] as int;
    }
    return total;
  }

  Future<void> clearCart() async {
    _cartItems.clear();
    if (isSupabaseEnabled) {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('cart_items').delete().eq('user_id', userId);
    } else {
      await _saveCartForCurrentUser();
    }
    notifyListeners();
  }

  // --- USER-SPECIFIC ORDERS ---
  List<dynamic> getUserOrders() {
    if (isSupabaseEnabled) {
      return _orders;
    }
    final phone = _currentUser?['phone'] as String?;
    if (phone == null) return [];
    return _orders.where((o) => o['userPhone'] == phone).toList();
  }

  // --- ORDERS MANAGEMENT ---
  Future<Map<String, dynamic>> createOrder(
    String paymentMethod, {
    String? pickupDate,
    String? pickupTime,
    String? dropoffDate,
    String? dropoffTime,
  }) async {
    final int count = getCartItemCount();
    final double total = getCartTotal();

    final detailsList = _cartItems.map((item) {
      return "${item['quantity']}x ${item['item']} (${(item['services'] as List).join(', ')})";
    }).join(', ');

    final orderId = "#QW-IN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
    final cartSnapshot = _cartItems.map((item) => Map<String, dynamic>.from(item)).toList();

    final newOrder = {
      'orderId': orderId,
      'serviceName': _cartItems.isNotEmpty ? "${_cartItems[0]['category']} Care" : 'General Care',
      'itemCount': count,
      'price': total,
      'status': 'Processing',
      'progress': 0.1,
      'dateTime': _getFormattedNow(),
      'emoji': _cartItems.isNotEmpty ? _cartItems[0]['emoji'] : '🧺',
      'itemsDetail': detailsList,
      'paymentMethod': paymentMethod,
      'userPhone': _currentUser?['phone'] ?? 'unknown',
      'cartSnapshot': cartSnapshot,
      'pickupDate': pickupDate,
      'pickupTime': pickupTime,
      'dropoffDate': dropoffDate,
      'dropoffTime': dropoffTime,
    };

    _orders.insert(0, newOrder);

    if (isSupabaseEnabled) {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('orders').insert({
        'order_id': orderId,
        'user_id': userId,
        'service_name': newOrder['serviceName'],
        'item_count': count,
        'price': total,
        'status': 'Processing',
        'progress': 0.1,
        'date_time': newOrder['dateTime'],
        'emoji': newOrder['emoji'],
        'items_detail': detailsList,
        'payment_method': paymentMethod,
        'pickup_date': pickupDate,
        'pickup_time': pickupTime,
        'dropoff_date': dropoffDate,
        'dropoff_time': dropoffTime,
        'cart_snapshot': cartSnapshot,
      });
      await clearCart();
    } else {
      await _saveOrders();
      await clearCart();
    }

    await addNotification(
      title: 'Order Placed Successfully',
      description: 'Your order $orderId has been placed. We will pick up your garments soon.',
      orderId: orderId,
      status: 'Processing',
    );

    if (paymentMethod == 'QuickWash Wallet' && _currentUser != null) {
      final currentBalance = (_currentUser!['balance'] as num).toDouble();
      await updateUserProfile(balance: currentBalance - total);

      final txn = {
        'type': 'debit',
        'amount': total,
        'description': 'Order $orderId',
        'date': _getFormattedNow(),
      };
      _walletTransactions.insert(0, txn);

      if (isSupabaseEnabled) {
        final userId = supabase.auth.currentUser!.id;
        await supabase.from('wallet_transactions').insert({
          'user_id': userId,
          'type': 'debit',
          'amount': total,
          'description': 'Order $orderId',
          'date': txn['date'],
        });
      } else {
        await _prefs!.setString('qw_wallet_txns', jsonEncode(_walletTransactions));
      }
    }

    notifyListeners();
    if (!isSupabaseEnabled) {
      _simulateOrderStatusUpdates(orderId);
    }

    return newOrder;
  }

  Future<void> _saveOrders() async {
    await _prefs!.setString('qw_orders', jsonEncode(_orders));
  }

  String _getFormattedNow() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final minute = now.minute.toString().padLeft(2, '0');
    return "${now.day} ${months[now.month - 1]}, $hour:$minute $ampm";
  }

  // --- WALLET ---
  Future<void> addWalletCredits(double amount) async {
    if (_currentUser == null) return;
    final currentBalance = (_currentUser!['balance'] as num).toDouble();
    await updateUserProfile(balance: currentBalance + amount);

    final txn = {
      'type': 'credit',
      'amount': amount,
      'description': 'Wallet Top-up',
      'date': _getFormattedNow(),
    };
    _walletTransactions.insert(0, txn);

    if (isSupabaseEnabled) {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('wallet_transactions').insert({
        'user_id': userId,
        'type': 'credit',
        'amount': amount,
        'description': 'Wallet Top-up',
        'date': txn['date'],
      });
    } else {
      await _prefs!.setString('qw_wallet_txns', jsonEncode(_walletTransactions));
    }
    notifyListeners();
  }

  // Simulator to advance the active order in background
  void _simulateOrderStatusUpdates(String orderId) {
    int step = 0;
    Timer.periodic(const Duration(seconds: 25), (timer) async {
      final index = _orders.indexWhere((o) => o['orderId'] == orderId);
      if (index == -1) {
        timer.cancel();
        return;
      }

      step++;
      var status = 'Processing';
      var progress = 0.1;

      if (step == 1) {
        status = 'Picked Up';
        progress = 0.35;
      } else if (step == 2) {
        status = 'In Process';
        progress = 0.60;
      } else if (step == 3) {
        status = 'Out for Delivery';
        progress = 0.85;
      } else if (step == 4) {
        status = 'Completed';
        progress = 1.0;
        timer.cancel();
      }

      final updated = Map<String, dynamic>.from(_orders[index]);
      updated['status'] = status;
      updated['progress'] = progress;

      _orders[index] = updated;

      if (isSupabaseEnabled) {
        await supabase.from('orders').update({
          'status': status,
          'progress': progress,
        }).eq('order_id', orderId);
      } else {
        await _saveOrders();
      }

      await addNotification(
        title: _getTitleForStatus(status),
        description: _getDescriptionForStatus(status, orderId),
        orderId: orderId,
        status: status,
      );

      notifyListeners();
    });
  }

  // --- NOTIFICATIONS MANAGEMENT ---
  Future<void> addNotificationForUser({
    required String userId,
    required String title,
    required String description,
    required String orderId,
    required String status,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newNotification = {
      'title': title,
      'description': description,
      'timeAgo': 'Just now',
      'status': status,
      'orderId': orderId,
      'type': 'order_status',
      'timestamp': timestamp,
    };
    
    if (_currentUser != null && _currentUser!['id'] == userId) {
      _notifications.insert(0, newNotification);
      if (_notifications.length > 30) {
        _notifications = _notifications.sublist(0, 30);
      }
    }

    if (isSupabaseEnabled) {
      await supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'description': description,
        'order_id': orderId,
        'status': status,
        'type': 'order_status',
        'timestamp': timestamp,
      });
    } else {
      if (_prefs != null) {
        final notificationsStr = _prefs!.getString('qw_notifications') ?? '[]';
        final List<dynamic> localNotifs = jsonDecode(notificationsStr);
        localNotifs.insert(0, {
          'user_id': userId,
          ...newNotification,
        });
        await _prefs!.setString('qw_notifications', jsonEncode(localNotifs));
      }
    }
    notifyListeners();
  }

  Future<void> addNotification({
    required String title,
    required String description,
    required String orderId,
    required String status,
  }) async {
    final userId = _currentUser?['id'] ?? supabase.auth.currentUser?.id;
    if (userId != null) {
      await addNotificationForUser(
        userId: userId,
        title: title,
        description: description,
        orderId: orderId,
        status: status,
      );
    }
  }

  String _getTitleForStatus(String status) {
    switch (status) {
      case 'Picked Up': return 'Order Picked Up';
      case 'In Process': return 'Laundry In Process';
      case 'Out for Delivery': return 'Out for Delivery';
      case 'Completed': return 'Order Delivered';
      default: return 'Order Status Update';
    }
  }

  String _getDescriptionForStatus(String status, String orderId) {
    switch (status) {
      case 'Picked Up': return 'Your garments for order $orderId have been picked up and sent to our cleaning facility.';
      case 'In Process': return 'Your garments for order $orderId are currently undergoing washing/dry cleaning.';
      case 'Out for Delivery': return 'Your fresh clothes for order $orderId are on their way to your home.';
      case 'Completed': return 'Order $orderId has been successfully delivered and handed over.';
      default: return 'Order $orderId is currently in $status status.';
    }
  }

  // --- MULTI-ROLE HELPERS ---

  Future<List<Map<String, dynamic>>> getDeliveryPersonnel() async {
    if (isSupabaseEnabled) {
      try {
        final res = await supabase.from('profiles').select().eq('role', 'delivery');
        return List<Map<String, dynamic>>.from(res);
      } catch (e) {
        debugPrint('Error getting delivery personnel: $e');
        return [];
      }
    }
    return _users
        .where((u) => u['role'] == 'delivery')
        .map((u) => Map<String, dynamic>.from(u))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getAllProfiles() async {
    if (isSupabaseEnabled) {
      try {
        final res = await supabase.from('profiles').select().order('name');
        return List<Map<String, dynamic>>.from(res);
      } catch (e) {
        debugPrint('Error getting all profiles: $e');
        return [];
      }
    }
    return _users.map((u) => Map<String, dynamic>.from(u)).toList();
  }

  Future<bool> updateAnyUserProfile(String targetUserId, {String? name, String? address, double? balance, String? role}) async {
    if (isSupabaseEnabled) {
      try {
        final updates = <String, dynamic>{};
        if (name != null) updates['name'] = name;
        if (address != null) updates['address'] = address;
        if (balance != null) updates['balance'] = balance;
        if (role != null) updates['role'] = role;
        updates['updated_at'] = DateTime.now().toUtc().toIso8601String();

        await supabase.from('profiles').update(updates).eq('id', targetUserId);
        
        if (_currentUser != null && _currentUser!['id'] == targetUserId) {
          if (name != null) _currentUser!['name'] = name;
          if (address != null) _currentUser!['address'] = address;
          if (balance != null) _currentUser!['balance'] = balance;
          if (role != null) _currentUser!['role'] = role;
        }
        
        await _loadDataFromSupabase();
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint('Error updating target profile: $e');
        return false;
      }
    } else {
      for (var i = 0; i < _users.length; i++) {
        if (_users[i]['id'] == targetUserId || _users[i]['email'] == targetUserId || _users[i]['phone'] == targetUserId) {
          if (name != null) _users[i]['name'] = name;
          if (address != null) _users[i]['address'] = address;
          if (balance != null) _users[i]['balance'] = balance;
          if (role != null) _users[i]['role'] = role;
          
          if (_currentUser != null && (_currentUser!['email'] == _users[i]['email'] || _currentUser!['id'] == _users[i]['id'])) {
            _currentUser = Map<String, dynamic>.from(_users[i]);
          }
          break;
        }
      }
      await _prefs!.setString('qw_users', jsonEncode(_users));
      if (_currentUser != null) {
        await _prefs!.setString('qw_current_user', jsonEncode(_currentUser));
      }
      notifyListeners();
      return true;
    }
  }

  Future<bool> assignDeliveryBoy(String orderId, String? deliveryBoyId) async {
    final idx = _orders.indexWhere((o) => o['orderId'] == orderId);
    if (idx != -1) {
      _orders[idx]['delivery_boy_id'] = deliveryBoyId;
    }

    if (isSupabaseEnabled) {
      try {
        await supabase.from('orders').update({
          'delivery_boy_id': deliveryBoyId,
        }).eq('order_id', orderId);
        
        if (deliveryBoyId != null) {
          final driverProfile = await supabase.from('profiles').select('name').eq('id', deliveryBoyId).maybeSingle();
          final driverName = driverProfile?['name'] ?? 'QuickWash Partner';
          
          final orderData = await supabase.from('orders').select('user_id').eq('order_id', orderId).maybeSingle();
          if (orderData != null) {
            final customerId = orderData['user_id'];
            await addNotificationForUser(
              userId: customerId,
              title: 'Delivery Partner Assigned',
              description: '$driverName has been assigned to your order $orderId.',
              orderId: orderId,
              status: 'Processing',
            );
          }
        }
        
        await _loadDataFromSupabase();
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint('Error assigning delivery boy: $e');
        return false;
      }
    } else {
      await _saveOrders();
      notifyListeners();
      return true;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status, double progress) async {
    final index = _orders.indexWhere((o) => o['orderId'] == orderId);
    if (index != -1) {
      _orders[index]['status'] = status;
      _orders[index]['progress'] = progress;
    }

    if (isSupabaseEnabled) {
      try {
        await supabase.from('orders').update({
          'status': status,
          'progress': progress,
        }).eq('order_id', orderId);

        final orderData = await supabase.from('orders').select('user_id').eq('order_id', orderId).maybeSingle();
        if (orderData != null) {
          final customerId = orderData['user_id'];
          await addNotificationForUser(
            userId: customerId,
            title: _getTitleForStatus(status),
            description: _getDescriptionForStatus(status, orderId),
            orderId: orderId,
            status: status,
          );
        }
        
        await _loadDataFromSupabase();
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint('Error updating order status: $e');
        return false;
      }
    } else {
      await _saveOrders();
      notifyListeners();
      return true;
    }
  }

  Future<void> syncUserProfileAfterOtp(String phone) async {
    if (!isSupabaseEnabled) return;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final res = await supabase.from('profiles').select().eq('id', user.id).maybeSingle();
      if (res == null) {
        // Create new profile for this user
        final newUserProfile = {
          'id': user.id,
          'name': 'Guest User',
          'email': user.email ?? 'user_$phone@quickwash.in',
          'phone': phone,
          'balance': 0.0,
          'address': '',
          'role': 'customer',
        };
        await supabase.from('profiles').insert(newUserProfile);
      }
      await _loadDataFromSupabase();
      notifyListeners();
    } catch (e) {
      debugPrint('Sync user profile after OTP failed: $e');
    }
  }

  Future<void> refreshSession() async {
    if (!isSupabaseEnabled) return;
    try {
      await supabase.auth.refreshSession();
      if (supabase.auth.currentUser != null) {
        await _loadDataFromSupabase();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Refresh session failed: $e');
    }
  }
}
