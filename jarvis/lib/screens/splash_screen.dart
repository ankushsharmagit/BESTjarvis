// lib/screens/splash_screen.dart
// JARVIS Boot Sequence Splash Screen

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/colors.dart';
import '../config/routes.dart';
import '../widgets/arc_reactor_widget.dart';
import '../utils/helpers.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List<String> _bootMessages = [
    'JARVIS v4.0 ULTIMATE',
    'Initializing core systems...',
    'Loading neural networks... ██████████ 100%',
    'Voice module online...',
    'Security protocols active...',
    'Face recognition calibrated...',
    'All systems operational.',
  ];
  
  int _currentMessageIndex = -1;
  double _progressValue = 0.0;
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    _startBootSequence();
  }
  
  void _startBootSequence() {
    _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      setState(() {
        if (_currentMessageIndex < _bootMessages.length - 1) {
          _currentMessageIndex++;
          _progressValue = (_currentMessageIndex + 1) / _bootMessages.length;
        } else {
          timer.cancel();
          _navigateToNextScreen();
        }
      });
    });
  }
  
  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('first_launch') ?? true;
    
    if (mounted) {
      if (isFirstLaunch) {
        Navigator.pushReplacementNamed(context, AppRoutes.setup);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final greeting = 'Good ${Helpers.getTimeGreeting()}, Mukul Sir.';
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Color(0xFF0A0E21),
                  Color(0xFF05080F),
                ],
              ),
            ),
          ),
          
          // Floating particles
          ...List.generate(30, (index) {
            return Positioned(
              left: (index * 37) % MediaQuery.of(context).size.width,
              top: (index * 53) % MediaQuery.of(context).size.height,
              child: Container(
                width: 2,
                height: 2,
                decoration: BoxDecoration(
                  color: JarvisColors.accentCyan.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Arc Reactor Animation
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [JarvisColors.accentCyan, JarvisColors.accentBlue],
                      stops: [0.3, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: JarvisColors.accentCyan.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.flash_on, size: 60, color: Colors.white),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Boot Messages
                Column(
                  children: List.generate(_bootMessages.length, (index) {
                    if (index > _currentMessageIndex) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (index == _currentMessageIndex)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: const BoxDecoration(
                                color: JarvisColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Text(
                            _bootMessages[index],
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              color: index == _currentMessageIndex 
                                  ? JarvisColors.accentCyan 
                                  : JarvisColors.textSecondary,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                
                const SizedBox(height: 30),
                
                // Progress Bar
                Container(
                  width: 250,
                  height: 2,
                  decoration: BoxDecoration(
                    color: JarvisColors.textHint.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: _progressValue,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [JarvisColors.accentCyan, JarvisColors.accentBlue],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Final Greeting
                if (_currentMessageIndex == _bootMessages.length - 1)
                  Text(
                    greeting,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: JarvisColors.success,
                      letterSpacing: 1,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}