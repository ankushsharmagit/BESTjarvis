// lib/services/device/app_manager.dart
// Complete Application Management Service

import 'dart:io';
import 'package:device_apps/device_apps.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';

class AppManagerService {
  static final AppManagerService _instance = AppManagerService._internal();
  factory AppManagerService() => _instance;
  AppManagerService._internal();
  
  List<Application> _installedApps = [];
  List<Application> _userApps = [];
  List<Application> _systemApps = [];
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    try {
      await _loadInstalledApps();
      _isInitialized = true;
      Logger().info('App manager initialized with ${_installedApps.length} apps', tag: 'APP_MANAGER');
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'App Manager Init');
    }
  }
  
  Future<void> _loadInstalledApps() async {
    try {
      _installedApps = await DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        onlyAppsWithLaunchIntent: true,
      );
      
      _userApps = _installedApps.where((app) => !app.isSystemApp).toList();
      _systemApps = _installedApps.where((app) => app.isSystemApp).toList();
      
      Logger().info('Loaded ${_userApps.length} user apps and ${_systemApps.length} system apps', tag: 'APP_MANAGER');
    } catch (e) {
      Logger().error('Error loading apps', tag: 'APP_MANAGER', error: e);
    }
  }
  
  Future<bool> openApp(String appName) async {
    try {
      // Search for app by name
      final app = _findAppByName(appName);
      if (app != null) {
        final result = await DeviceApps.openApp(app.packageName);
        if (result) {
          Logger().info('Opened app: ${app.appName}', tag: 'APP_MANAGER');
          return true;
        }
      }
      
      // Try opening by package name
      final packageName = _getPackageNameFromAppName(appName);
      if (packageName != null) {
        final result = await DeviceApps.openApp(packageName);
        if (result) {
          Logger().info('Opened app by package: $packageName', tag: 'APP_MANAGER');
          return true;
        }
      }
      
      Logger().warning('App not found: $appName', tag: 'APP_MANAGER');
      return false;
      
    } catch (e) {
      Logger().error('Open app error', tag: 'APP_MANAGER', error: e);
      return false;
    }
  }
  
  Future<bool> closeApp(String appName) async {
    try {
      final app = _findAppByName(appName);
      if (app != null) {
        await DeviceApps.killApp(app.packageName);
        Logger().info('Closed app: ${app.appName}', tag: 'APP_MANAGER');
        return true;
      }
      return false;
    } catch (e) {
      Logger().error('Close app error', tag: 'APP_MANAGER', error: e);
      return false;
    }
  }
  
  Future<bool> uninstallApp(String appName, {bool requireConfirmation = true}) async {
    try {
      final app = _findAppByName(appName);
      if (app != null && !app.isSystemApp) {
        final result = await DeviceApps.uninstallApp(app.packageName);
        if (result) {
          Logger().info('Uninstalled app: ${app.appName}', tag: 'APP_MANAGER');
          await _loadInstalledApps(); // Refresh list
          return true;
        }
      }
      return false;
    } catch (e) {
      Logger().error('Uninstall app error', tag: 'APP_MANAGER', error: e);
      return false;
    }
  }
  
  Future<bool> clearAppCache(String appName) async {
    try {
      final app = _findAppByName(appName);
      if (app != null) {
        await DeviceApps.clearAppPreferences(app.packageName);
        Logger().info('Cleared cache for: ${app.appName}', tag: 'APP_MANAGER');
        return true;
      }
      return false;
    } catch (e) {
      Logger().error('Clear cache error', tag: 'APP_MANAGER', error: e);
      return false;
    }
  }
  
  Future<bool> clearAppData(String appName) async {
    try {
      final app = _findAppByName(appName);
      if (app != null) {
        await DeviceApps.clearAppData(app.packageName);
        Logger().info('Cleared data for: ${app.appName}', tag: 'APP_MANAGER');
        return true;
      }
      return false;
    } catch (e) {
      Logger().error('Clear data error', tag: 'APP_MANAGER', error: e);
      return false;
    }
  }
  
  Future<Map<String, dynamic>> getAppDetails(String appName) async {
    try {
      final app = _findAppByName(appName);
      if (app != null) {
        final appInfo = await DeviceApps.getAppInfo(app.packageName);
        return {
          'name': app.appName,
          'packageName': app.packageName,
          'versionName': appInfo?.versionName,
          'versionCode': appInfo?.versionCode,
          'size': appInfo?.apkSize,
          'isSystemApp': app.isSystemApp,
          'isInstalled': true,
          'isEnabled': appInfo?.enabled ?? true,
          'installTime': appInfo?.firstInstallTime,
          'updateTime': appInfo?.lastUpdateTime,
        };
      }
      return {'error': 'App not found'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }
  
  Future<List<Map<String, dynamic>>> getAllApps() async {
    try {
      final apps = <Map<String, dynamic>>[];
      for (var app in _installedApps) {
        apps.add({
          'name': app.appName,
          'packageName': app.packageName,
          'isSystemApp': app.isSystemApp,
          'icon': app.icon,
        });
      }
      return apps;
    } catch (e) {
      Logger().error('Get all apps error', tag: 'APP_MANAGER', error: e);
      return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> getUserApps() async {
    try {
      final apps = <Map<String, dynamic>>[];
      for (var app in _userApps) {
        apps.add({
          'name': app.appName,
          'packageName': app.packageName,
          'icon': app.icon,
        });
      }
      return apps;
    } catch (e) {
      return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> searchApps(String query) async {
    final lowerQuery = query.toLowerCase();
    final results = <Map<String, dynamic>>[];
    
    for (var app in _installedApps) {
      if (app.appName.toLowerCase().contains(lowerQuery) ||
          app.packageName.toLowerCase().contains(lowerQuery)) {
        results.add({
          'name': app.appName,
          'packageName': app.packageName,
          'isSystemApp': app.isSystemApp,
          'match': app.appName.toLowerCase().contains(lowerQuery) ? 'name' : 'package',
        });
      }
    }
    
    return results;
  }
  
  Future<Map<String, int>> getAppUsageStats() async {
    try {
      final usageStats = <String, int>{};
      // This requires USAGE_ACCESS permission
      return usageStats;
    } catch (e) {
      Logger().error('Usage stats error', tag: 'APP_MANAGER', error: e);
      return {};
    }
  }
  
  Future<bool> killBackgroundApps() async {
    try {
      final runningApps = await DeviceApps.getRunningApps();
      int killedCount = 0;
      
      for (var app in runningApps) {
        if (!app.isSystemApp) {
          await DeviceApps.killApp(app.packageName);
          killedCount++;
        }
      }
      
      Logger().info('Killed $killedCount background apps', tag: 'APP_MANAGER');
      return true;
    } catch (e) {
      Logger().error('Kill apps error', tag: 'APP_MANAGER', error: e);
      return false;
    }
  }
  
  Future<bool> enableApp(String packageName) async {
    try {
      await DeviceApps.enableApp(packageName);
      Logger().info('Enabled app: $packageName', tag: 'APP_MANAGER');
      return true;
    } catch (e) {
      Logger().error('Enable app error', tag: 'APP_MANAGER', error: e);
      return false;
    }
  }
  
  Future<bool> disableApp(String packageName) async {
    try {
      await DeviceApps.disableApp(packageName);
      Logger().info('Disabled app: $packageName', tag: 'APP_MANAGER');
      return true;
    } catch (e) {
      Logger().error('Disable app error', tag: 'APP_MANAGER', error: e);
      return false;
    }
  }
  
  Application? _findAppByName(String name) {
    final lowercaseName = name.toLowerCase().trim();
    
    // Exact match first
    for (var app in _installedApps) {
      if (app.appName.toLowerCase() == lowercaseName) {
        return app;
      }
    }
    
    // Partial match
    for (var app in _installedApps) {
      if (app.appName.toLowerCase().contains(lowercaseName)) {
        return app;
      }
    }
    
    return null;
  }
  
  String? _getPackageNameFromAppName(String name) {
    final appMap = {
      'whatsapp': 'com.whatsapp',
      'instagram': 'com.instagram.android',
      'facebook': 'com.facebook.katana',
      'youtube': 'com.google.android.youtube',
      'gmail': 'com.google.android.gm',
      'maps': 'com.google.android.apps.maps',
      'chrome': 'com.android.chrome',
      'camera': 'com.android.camera',
      'settings': 'com.android.settings',
      'phone': 'com.android.dialer',
      'messages': 'com.google.android.apps.messaging',
      'spotify': 'com.spotify.music',
      'netflix': 'com.netflix.mediaclient',
      'prime video': 'com.amazon.primevideo',
      'twitter': 'com.twitter.android',
      'snapchat': 'com.snapchat.android',
      'telegram': 'org.telegram.messenger',
      'discord': 'com.discord',
      'reddit': 'com.reddit.frontpage',
      'linkedin': 'com.linkedin.android',
      'zoom': 'us.zoom.videomeetings',
      'teams': 'com.microsoft.teams',
      'drive': 'com.google.android.apps.docs',
      'photos': 'com.google.android.apps.photos',
      'calendar': 'com.google.android.calendar',
      'contacts': 'com.google.android.contacts',
      'clock': 'com.google.android.deskclock',
      'calculator': 'com.google.android.calculator',
      'files': 'com.google.android.apps.nbu.files',
      'play store': 'com.android.vending',
      'youtube music': 'com.google.android.apps.youtube.music',
      'google tv': 'com.google.android.tv',
      'google home': 'com.google.android.apps.chromecast.app',
    };
    
    final lowercaseName = name.toLowerCase();
    for (var entry in appMap.entries) {
      if (lowercaseName.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return null;
  }
  
  Future<void> refreshApps() async {
    await _loadInstalledApps();
  }
  
  Future<bool> isAppInstalled(String packageName) async {
    return await DeviceApps.isAppInstalled(packageName);
  }
  
  Future<void> openAppSettings(String packageName) async {
    final intent = AndroidIntent(
      action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
      data: 'package:$packageName',
    );
    await intent.launch();
  }
  
  Future<void> openPlayStore(String packageName) async {
    final intent = AndroidIntent(
      action: 'android.intent.action.VIEW',
      data: 'market://details?id=$packageName',
    );
    await intent.launch();
  }
  
  Future<List<Map<String, dynamic>>> getRecentlyUsedApps() async {
    // This would use UsageStatsManager
    return [];
  }
  
  int getTotalApps() => _installedApps.length;
  int getUserAppsCount() => _userApps.length;
  int getSystemAppsCount() => _systemApps.length;
}

class AppCategories {
  static const Map<String, List<String>> categoryApps = {
    'social': ['whatsapp', 'instagram', 'facebook', 'twitter', 'snapchat', 'telegram', 'discord', 'reddit'],
    'communication': ['whatsapp', 'telegram', 'messenger', 'signal', 'wechat', 'imessage'],
    'entertainment': ['youtube', 'netflix', 'prime video', 'hotstar', 'spotify', 'apple music', 'twitch'],
    'productivity': ['gmail', 'drive', 'calendar', 'keep', 'tasks', 'microsoft teams', 'zoom', 'slack'],
    'photography': ['camera', 'photos', 'lightroom', 'snapseed', 'vsco', 'picsart'],
    'navigation': ['maps', 'waze', 'uber', 'ola', 'google maps', 'lyft'],
    'shopping': ['amazon', 'flipkart', 'myntra', 'ajio', 'paytm', 'ebay', 'walmart'],
    'finance': ['gpay', 'phonepe', 'paytm', 'google pay', 'banking', 'crypto', 'stock'],
    'education': ['duolingo', 'coursera', 'udemy', 'byjus', 'unacademy', 'khan academy'],
    'health': ['fitbit', 'google fit', 'healthify', 'cult.fit', 'myfitnesspal', 'strava'],
    'gaming': ['pubg', 'free fire', 'candy crush', 'subway surfers', 'among us', 'genshin'],
    'news': ['google news', 'bbc news', 'cnn', 'times of india', 'the hindu'],
  };
  
  static String getCategoryForApp(String appName) {
    final lowercaseName = appName.toLowerCase();
    for (var entry in categoryApps.entries) {
      for (var keyword in entry.value) {
        if (lowercaseName.contains(keyword)) {
          return entry.key;
        }
      }
    }
    return 'other';
  }
  
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'social': return Icons.people;
      case 'communication': return Icons.chat;
      case 'entertainment': return Icons.movie;
      case 'productivity': return Icons.work;
      case 'photography': return Icons.camera_alt;
      case 'navigation': return Icons.navigation;
      case 'shopping': return Icons.shopping_cart;
      case 'finance': return Icons.attach_money;
      case 'education': return Icons.school;
      case 'health': return Icons.favorite;
      case 'gaming': return Icons.sports_esports;
      case 'news': return Icons.newspaper;
      default: return Icons.apps;
    }
  }
}