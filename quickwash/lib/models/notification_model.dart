import 'package:flutter/material.dart';

class NotificationModel {
  final String title;
  final String description;
  final String timeAgo;
  final IconData icon;
  final String? actionLabel;
  final String? secondaryActionLabel;
  final bool hasIndicator;

  const NotificationModel({
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.icon,
    this.actionLabel,
    this.secondaryActionLabel,
    this.hasIndicator = true,
  });

  static const List<NotificationModel> samples = [
    NotificationModel(
      title: 'Order Picked Up',
      description: 'Your order #QW-9842 has been successfully picked up by our partner, Marcus.',
      timeAgo: '2m ago',
      icon: Icons.local_shipping_outlined,
      actionLabel: 'Track Live',
    ),
    NotificationModel(
      title: 'Offer: 20% off on Ethnic Wear',
      description: 'Special care for your special garments. Use code ETHNIC20 for premium dry cleaning services.',
      timeAgo: '1h ago',
      icon: Icons.sell_outlined,
      actionLabel: 'Claim Offer',
      secondaryActionLabel: 'Details',
    ),
    NotificationModel(
      title: 'Delivery arriving in 15 mins',
      description: 'Our delivery executive is nearing your location. Please keep the pickup/delivery code ready.',
      timeAgo: 'Now',
      icon: Icons.check_circle_outline,
    ),
  ];
}
