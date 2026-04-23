// lib/widgets/quick_action_button.dart
// Quick Action Button Widget

import 'package:flutter/material.dart';
import '../config/colors.dart';

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  
  const QuickActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (color ?? JarvisColors.accentCyan),
                  (color ?? JarvisColors.accentBlue),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: (color ?? JarvisColors.accentCyan).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: JarvisColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionGrid extends StatelessWidget {
  final List<QuickActionItem> actions;
  
  const QuickActionGrid({
    Key? key,
    required this.actions,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.9,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return QuickActionButton(
          icon: action.icon,
          label: action.label,
          onTap: action.onTap,
          color: action.color,
        );
      },
    );
  }
}

class QuickActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  
  QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
}