class OrderModel {
  final String orderId;
  final String serviceName;
  final int itemCount;
  final double price;
  final String status; // 'Out for Delivery', 'Processing', 'Completed'
  final double progress; // 0.0 to 1.0
  final String dateTime;
  final String emoji;

  const OrderModel({
    required this.orderId,
    required this.serviceName,
    required this.itemCount,
    required this.price,
    required this.status,
    required this.progress,
    required this.dateTime,
    this.emoji = '🧺',
  });

  static const List<OrderModel> activeOrders = [
    OrderModel(
      orderId: '#QW-88219',
      serviceName: 'Premium Wash & Fold',
      itemCount: 12,
      price: 42.50,
      status: 'Out for Delivery',
      progress: 0.85,
      dateTime: 'Today, 2:30 PM',
      emoji: '🧺',
    ),
    OrderModel(
      orderId: '#QW-88224',
      serviceName: 'Delicate Dry Cleaning',
      itemCount: 4,
      price: 28.00,
      status: 'Processing',
      progress: 0.30,
      dateTime: 'Yesterday, 10:15 AM',
      emoji: '👔',
    ),
  ];

  static const List<OrderModel> pastOrders = [
    OrderModel(
      orderId: '#QW-88200',
      serviceName: 'Weekly Laundry',
      itemCount: 12,
      price: 35.00,
      status: 'Completed',
      progress: 1.0,
      dateTime: 'Yesterday, 6:30 PM',
      emoji: '🧺',
    ),
    OrderModel(
      orderId: '#QW-88195',
      serviceName: 'Office Formals',
      itemCount: 5,
      price: 45.00,
      status: 'Completed',
      progress: 1.0,
      dateTime: '02 Oct, 10:15 AM',
      emoji: '👔',
    ),
  ];
}
