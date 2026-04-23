// lib/widgets/particle_background.dart
// Floating Particle Animation Background

import 'dart:math';
import 'package:flutter/material.dart';
import '../config/colors.dart';

class ParticleBackground extends StatefulWidget {
  final int particleCount;
  final Color particleColor;
  
  const ParticleBackground({
    Key? key,
    this.particleCount = 60,
    this.particleColor = JarvisColors.particleColor,
  }) : super(key: key);
  
  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Particle> particles = [];
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    
    _initParticles();
    
    _controller.addListener(() {
      setState(() {
        for (var particle in particles) {
          particle.update();
        }
      });
    });
  }
  
  void _initParticles() {
    final random = Random();
    for (int i = 0; i < widget.particleCount; i++) {
      particles.add(Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        vx: (random.nextDouble() - 0.5) * 0.003,
        vy: (random.nextDouble() - 0.5) * 0.002,
        size: random.nextDouble() * 3 + 1,
        opacity: random.nextDouble() * 0.4 + 0.1,
      ));
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ParticlePainter(particles: particles, color: widget.particleColor),
      size: Size.infinite,
    );
  }
}

class Particle {
  double x, y;
  double vx, vy;
  double size;
  double opacity;
  
  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
  });
  
  void update() {
    x += vx;
    y += vy;
    
    // Wrap around screen
    if (x < 0) x = 1;
    if (x > 1) x = 0;
    if (y < 0) y = 1;
    if (y > 1) y = 0;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Color color;
  
  ParticlePainter({required this.particles, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (var particle in particles) {
      paint.color = color.withOpacity(particle.opacity);
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}