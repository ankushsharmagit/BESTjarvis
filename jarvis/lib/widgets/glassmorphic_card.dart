// lib/widgets/glassmorphic_card.dart
// Glassmorphism Effect Card Widget

import 'package:flutter/material.dart';
import '../config/colors.dart';

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurStrength;
  final Color? borderColor;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  
  const GlassmorphicCard({
    Key? key,
    required this.child,
    this.borderRadius = 16,
    this.blurStrength = 10,
    this.borderColor,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.width,
    this.height,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? JarvisColors.borderColor,
          width: 1,
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x1AFFFFFF),
            Color(0x0FFFFFFF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: JarvisColors.glowColor.withOpacity(0.1),
            blurRadius: blurStrength,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: blurStrength > 0 
              ? ImageFilter.blur(sigmaX: blurStrength, sigmaY: blurStrength)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              child: Padding(
                padding: padding,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double height;
  final double width;
  final double borderRadius;
  final bool hasBorder;
  
  const GlassmorphicContainer({
    Key? key,
    required this.child,
    this.height = double.infinity,
    this.width = double.infinity,
    this.borderRadius = 16,
    this.hasBorder = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: hasBorder ? Border.all(
          color: JarvisColors.borderColor,
          width: 1,
        ) : null,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x33FFFFFF),
            Color(0x0FFFFFFF),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }
}