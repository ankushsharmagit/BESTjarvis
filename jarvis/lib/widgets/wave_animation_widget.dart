// lib/widgets/wave_animation_widget.dart
// Audio Wave Animation for Speaking State

import 'dart:math';
import 'package:flutter/material.dart';
import '../config/colors.dart';

class WaveAnimationWidget extends StatefulWidget {
  final bool isActive;
  final int barCount;
  final Color? color;
  
  const WaveAnimationWidget({
    Key? key,
    required this.isActive,
    this.barCount = 20,
    this.color,
  }) : super(key: key);
  
  @override
  State<WaveAnimationWidget> createState() => _WaveAnimationWidgetState();
}

class _WaveAnimationWidgetState extends State<WaveAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<double> heights = [];
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
    
    _initHeights();
    
    _controller.addListener(() {
      setState(() {
        for (int i = 0; i < widget.barCount; i++) {
          heights[i] = 10 + (sin(i * 0.3 + _controller.value * 2 * pi) * 25).abs();
        }
      });
    });
  }
  
  void _initHeights() {
    for (int i = 0; i < widget.barCount; i++) {
      heights.add(10.0);
    }
  }
  
  @override
  void didUpdateWidget(WaveAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
      _initHeights();
      setState(() {});
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.barCount, (index) {
        return Container(
          width: 3,
          height: heights[index],
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.color ?? JarvisColors.accentCyan,
                (widget.color ?? JarvisColors.accentBlue),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

class VoiceVisualizer extends StatelessWidget {
  final double soundLevel;
  final bool isListening;
  
  const VoiceVisualizer({
    Key? key,
    required this.soundLevel,
    this.isListening = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(25, (index) {
            final intensity = isListening 
                ? (soundLevel * (1 - (index - 12).abs() / 12)).clamp(0.1, 1.0)
                : 0.2;
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 50),
              width: 3,
              height: 15 * intensity,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: JarvisColors.accentCyan.withOpacity(intensity),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ),
    );
  }
}