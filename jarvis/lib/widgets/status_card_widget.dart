// lib/widgets/status_card_widget.dart
// Status Dashboard Card Widget

import 'package:flutter/material.dart';
import '../config/colors.dart';

class StatusCardWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? color;
  final VoidCallback? onTap;
  
  const StatusCardWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    this.color,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              JarvisColors.bgCard.withOpacity(0.8),
              JarvisColors.bgSecondary.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (color ?? JarvisColors.accentCyan).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: color ?? JarvisColors.accentCyan,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color ?? JarvisColors.accentCyan,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: JarvisColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class HorizontalStatusScroll extends StatelessWidget {
  final List<StatusCardData> items;
  
  const HorizontalStatusScroll({
    Key? key,
    required this.items,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: StatusCardWidget(
              icon: item.icon,
              title: item.title,
              value: item.value,
              color: item.color,
              onTap: item.onTap,
            ),
          );
        },
      ),
    );
  }
}

class StatusCardData {
  final IconData icon;
  final String title;
  final String value;
  final Color? color;
  final VoidCallback? onTap;
  
  StatusCardData({
    required this.icon,
    required this.title,
    required this.value,
    this.color,
    this.onTap,
  });
}