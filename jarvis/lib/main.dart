// lib/main.dart
// JARVIS App Entry Point

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'config/themes.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  
  // Request critical permissions
  await _requestPermissions();
  
  runApp(const JARVISApp());
}

Future<void> _requestPermissions() async {
  final permissions = [
    Permission.microphone,
    Permission.camera,
    Permission.storage,
    Permission.contacts,
    Permission.phone,
    Permission.sms,
    Permission.location,
    Permission.notification,
  ];
  
  await permissions.request();
}

class JARVISApp extends StatelessWidget {
  const JARVISApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JARVIS',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.darkTheme,
      home: const SplashScreen(),
    );
  }
}