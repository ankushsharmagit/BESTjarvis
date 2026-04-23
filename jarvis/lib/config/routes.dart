// lib/config/routes.dart
// JARVIS Navigation Routes

import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/setup_screen.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/chat_history_screen.dart';
import '../screens/security_log_screen.dart';
import '../screens/vault_screen.dart';
import '../screens/routine_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/code_viewer_screen.dart';
import '../screens/diagnostic_screen.dart';
import '../screens/about_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String setup = '/setup';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String chatHistory = '/chat-history';
  static const String securityLog = '/security-log';
  static const String vault = '/vault';
  static const String routines = '/routines';
  static const String dashboard = '/dashboard';
  static const String codeViewer = '/code-viewer';
  static const String diagnostic = '/diagnostic';
  static const String about = '/about';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _createRoute(const SplashScreen());
      case setup:
        return _createRoute(const SetupScreen());
      case home:
        return _createRoute(const HomeScreen());
      case settings:
        return _createRoute(const SettingsScreen());
      case chatHistory:
        return _createRoute(const ChatHistoryScreen());
      case securityLog:
        return _createRoute(const SecurityLogScreen());
      case vault:
        return _createRoute(const VaultScreen());
      case routines:
        return _createRoute(const RoutineScreen());
      case dashboard:
        return _createRoute(const DashboardScreen());
      case codeViewer:
        return _createRoute(const CodeViewerScreen());
      case diagnostic:
        return _createRoute(const DiagnosticScreen());
      case about:
        return _createRoute(const AboutScreen());
      default:
        return _createRoute(const HomeScreen());
    }
  }
  
  static Route<dynamic> _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        
        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

class RouteObserverService {
  static final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
}