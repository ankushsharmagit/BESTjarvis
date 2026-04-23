// lib/models/diagnostic_result.dart
// System Diagnostic Result Model

import 'package:flutter/material.dart';

class DiagnosticResult {
  final DateTime timestamp;
  final List<DiagnosticItem> items;
  final double overallScore;
  final String overallStatus;
  final String deviceName;
  final String androidVersion;
  final int totalMemory;
  final int freeMemory;
  final int totalStorage;
  final int freeStorage;
  final double cpuUsage;
  final double batteryHealth;
  final int networkLatency;
  
  DiagnosticResult({
    required this.timestamp,
    required this.items,
    required this.overallScore,
    required this.overallStatus,
    this.deviceName = '',
    this.androidVersion = '',
    this.totalMemory = 0,
    this.freeMemory = 0,
    this.totalStorage = 0,
    this.freeStorage = 0,
    this.cpuUsage = 0,
    this.batteryHealth = 100,
    this.networkLatency = 0,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'items': items.map((i) => i.toMap()).toList(),
      'overallScore': overallScore,
      'overallStatus': overallStatus,
      'deviceName': deviceName,
      'androidVersion': androidVersion,
      'totalMemory': totalMemory,
      'freeMemory': freeMemory,
      'totalStorage': totalStorage,
      'freeStorage': freeStorage,
      'cpuUsage': cpuUsage,
      'batteryHealth': batteryHealth,
      'networkLatency': networkLatency,
    };
  }
  
  factory DiagnosticResult.fromMap(Map<String, dynamic> map) {
    return DiagnosticResult(
      timestamp: DateTime.parse(map['timestamp']),
      items: (map['items'] as List)
          .map((i) => DiagnosticItem.fromMap(i))
          .toList(),
      overallScore: map['overallScore'],
      overallStatus: map['overallStatus'],
      deviceName: map['deviceName'] ?? '',
      androidVersion: map['androidVersion'] ?? '',
      totalMemory: map['totalMemory'] ?? 0,
      freeMemory: map['freeMemory'] ?? 0,
      totalStorage: map['totalStorage'] ?? 0,
      freeStorage: map['freeStorage'] ?? 0,
      cpuUsage: map['cpuUsage'] ?? 0,
      batteryHealth: map['batteryHealth'] ?? 100,
      networkLatency: map['networkLatency'] ?? 0,
    );
  }
  
  int getPassCount() {
    return items.where((i) => i.status == DiagnosticStatus.pass).length;
  }
  
  int getWarningCount() {
    return items.where((i) => i.status == DiagnosticStatus.warning).length;
  }
  
  int getFailCount() {
    return items.where((i) => i.status == DiagnosticStatus.fail).length;
  }
  
  double getMemoryUsagePercent() {
    if (totalMemory == 0) return 0;
    return ((totalMemory - freeMemory) / totalMemory) * 100;
  }
  
  double getStorageUsagePercent() {
    if (totalStorage == 0) return 0;
    return ((totalStorage - freeStorage) / totalStorage) * 100;
  }
  
  String getFormattedMemory() {
    return '${(totalMemory - freeMemory) ~/ (1024 * 1024)}MB / ${totalMemory ~/ (1024 * 1024)}MB';
  }
  
  String getFormattedStorage() {
    return '${(totalStorage - freeStorage) ~/ (1024 * 1024 * 1024)}GB / ${totalStorage ~/ (1024 * 1024 * 1024)}GB';
  }
  
  String getRecommendation() {
    if (overallScore >= 90) {
      return 'Your device is in excellent condition. Keep up the good maintenance! ✅';
    } else if (overallScore >= 70) {
      return 'Your device is doing well. Consider clearing some storage for better performance. 📱';
    } else if (overallScore >= 50) {
      return 'Your device needs attention. Run smart cleanup and close background apps. ⚠️';
    } else {
      return 'Your device requires immediate maintenance. Consider factory reset or upgrading. 🔴';
    }
  }
}

class DiagnosticItem {
  final String name;
  final String category;
  final DiagnosticStatus status;
  final String message;
  final String? suggestion;
  final dynamic value;
  final String unit;
  final DateTime? lastChecked;
  
  DiagnosticItem({
    required this.name,
    required this.category,
    required this.status,
    required this.message,
    this.suggestion,
    this.value,
    this.unit = '',
    this.lastChecked,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'status': status.index,
      'message': message,
      'suggestion': suggestion,
      'value': value,
      'unit': unit,
      'lastChecked': lastChecked?.toIso8601String(),
    };
  }
  
  factory DiagnosticItem.fromMap(Map<String, dynamic> map) {
    return DiagnosticItem(
      name: map['name'],
      category: map['category'],
      status: DiagnosticStatus.values[map['status']],
      message: map['message'],
      suggestion: map['suggestion'],
      value: map['value'],
      unit: map['unit'],
      lastChecked: map['lastChecked'] != null ? DateTime.parse(map['lastChecked']) : null,
    );
  }
  
  IconData getStatusIcon() {
    switch (status) {
      case DiagnosticStatus.pass:
        return Icons.check_circle;
      case DiagnosticStatus.warning:
        return Icons.warning_amber;
      case DiagnosticStatus.fail:
        return Icons.error;
      case DiagnosticStatus.running:
        return Icons.sync;
    }
  }
  
  Color getStatusColor() {
    switch (status) {
      case DiagnosticStatus.pass:
        return const Color(0xFF00FF88);
      case DiagnosticStatus.warning:
        return const Color(0xFFFF8800);
      case DiagnosticStatus.fail:
        return const Color(0xFFFF0040);
      case DiagnosticStatus.running:
        return const Color(0xFF00D4FF);
    }
  }
  
  String getFormattedValue() {
    if (value == null) return 'N/A';
    if (unit == 'MB' || unit == 'GB') {
      return '$value $unit';
    }
    if (unit == '%') {
      return '$value%';
    }
    if (unit == 'ms') {
      return '${value}ms';
    }
    return value.toString();
  }
}

enum DiagnosticStatus {
  pass,
  warning,
  fail,
  running,
}

class SystemHealth {
  double cpuUsage;
  double ramUsage;
  double storageUsed;
  double storageTotal;
  int batteryLevel;
  bool isCharging;
  double batteryTemperature;
  String networkType;
  int signalStrength;
  int wifiStrength;
  int activeProcesses;
  int totalProcesses;
  DateTime uptime;
  double gpuUsage;
  int screenBrightness;
  bool isLocationEnabled;
  bool isBluetoothEnabled;
  int notificationCount;
  
  SystemHealth({
    this.cpuUsage = 0,
    this.ramUsage = 0,
    this.storageUsed = 0,
    this.storageTotal = 0,
    this.batteryLevel = 0,
    this.isCharging = false,
    this.batteryTemperature = 0,
    this.networkType = 'Unknown',
    this.signalStrength = 0,
    this.wifiStrength = 0,
    this.activeProcesses = 0,
    this.totalProcesses = 0,
    required this.uptime,
    this.gpuUsage = 0,
    this.screenBrightness = 50,
    this.isLocationEnabled = false,
    this.isBluetoothEnabled = false,
    this.notificationCount = 0,
  });
  
  double getStoragePercentage() {
    if (storageTotal == 0) return 0;
    return (storageUsed / storageTotal) * 100;
  }
  
  double getRamPercentage() {
    return ramUsage;
  }
  
  String getHealthScore() {
    double score = 100;
    
    if (cpuUsage > 80) score -= 20;
    else if (cpuUsage > 60) score -= 10;
    
    if (getStoragePercentage() > 90) score -= 20;
    else if (getStoragePercentage() > 75) score -= 10;
    
    if (batteryLevel < 15) score -= 15;
    else if (batteryLevel < 30) score -= 5;
    
    if (batteryTemperature > 45) score -= 15;
    else if (batteryTemperature > 40) score -= 5;
    
    if (ramUsage > 85) score -= 10;
    else if (ramUsage > 70) score -= 5;
    
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Poor';
  }
  
  String getHealthEmoji() {
    switch (getHealthScore()) {
      case 'Excellent':
        return '💪';
      case 'Good':
        return '👍';
      case 'Fair':
        return '😐';
      case 'Poor':
        return '😰';
      default:
        return '🤖';
    }
  }
  
  String getBatteryStatus() {
    if (isCharging) {
      return 'Charging ⚡';
    } else if (batteryLevel <= 15) {
      return 'Critical 🔴';
    } else if (batteryLevel <= 30) {
      return 'Low 🟡';
    } else {
      return 'Normal ✅';
    }
  }
  
  String getNetworkIcon() {
    if (networkType.toLowerCase().contains('wifi')) {
      return '📶';
    } else if (networkType.toLowerCase().contains('mobile')) {
      return '📱';
    } else {
      return '🌐';
    }
  }
  
  Map<String, dynamic> toMap() {
    return {
      'cpuUsage': cpuUsage,
      'ramUsage': ramUsage,
      'storageUsed': storageUsed,
      'storageTotal': storageTotal,
      'batteryLevel': batteryLevel,
      'isCharging': isCharging,
      'batteryTemperature': batteryTemperature,
      'networkType': networkType,
      'signalStrength': signalStrength,
      'wifiStrength': wifiStrength,
      'activeProcesses': activeProcesses,
      'totalProcesses': totalProcesses,
      'uptime': uptime.toIso8601String(),
      'gpuUsage': gpuUsage,
      'screenBrightness': screenBrightness,
      'isLocationEnabled': isLocationEnabled,
      'isBluetoothEnabled': isBluetoothEnabled,
      'notificationCount': notificationCount,
    };
  }
  
  factory SystemHealth.fromMap(Map<String, dynamic> map) {
    return SystemHealth(
      cpuUsage: map['cpuUsage'] ?? 0,
      ramUsage: map['ramUsage'] ?? 0,
      storageUsed: map['storageUsed'] ?? 0,
      storageTotal: map['storageTotal'] ?? 0,
      batteryLevel: map['batteryLevel'] ?? 0,
      isCharging: map['isCharging'] ?? false,
      batteryTemperature: map['batteryTemperature'] ?? 0,
      networkType: map['networkType'] ?? 'Unknown',
      signalStrength: map['signalStrength'] ?? 0,
      wifiStrength: map['wifiStrength'] ?? 0,
      activeProcesses: map['activeProcesses'] ?? 0,
      totalProcesses: map['totalProcesses'] ?? 0,
      uptime: DateTime.parse(map['uptime']),
      gpuUsage: map['gpuUsage'] ?? 0,
      screenBrightness: map['screenBrightness'] ?? 50,
      isLocationEnabled: map['isLocationEnabled'] ?? false,
      isBluetoothEnabled: map['isBluetoothEnabled'] ?? false,
      notificationCount: map['notificationCount'] ?? 0,
    );
  }
}

class PerformanceMetrics {
  final DateTime timestamp;
  final double fps;
  final int frameDropCount;
  final int memoryUsage;
  final int peakMemoryUsage;
  final int uiThreadTime;
  final int rasterThreadTime;
  final int gpuTime;
  final int networkRequests;
  final double batteryDrainRate;
  
  PerformanceMetrics({
    required this.timestamp,
    required this.fps,
    required this.frameDropCount,
    required this.memoryUsage,
    required this.peakMemoryUsage,
    required this.uiThreadTime,
    required this.rasterThreadTime,
    this.gpuTime = 0,
    this.networkRequests = 0,
    this.batteryDrainRate = 0,
  });
  
  bool isSmooth() {
    return fps >= 55 && frameDropCount < 5;
  }
  
  String getPerformanceRating() {
    if (fps >= 58) return 'Butter Smooth';
    if (fps >= 50) return 'Smooth';
    if (fps >= 40) return 'Acceptable';
    if (fps >= 30) return 'Laggy';
    return 'Very Laggy';
  }
  
  String getPerformanceEmoji() {
    if (fps >= 58) return '🔥';
    if (fps >= 50) return '👍';
    if (fps >= 40) return '😐';
    return '😰';
  }
  
  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'fps': fps,
      'frameDropCount': frameDropCount,
      'memoryUsage': memoryUsage,
      'peakMemoryUsage': peakMemoryUsage,
      'uiThreadTime': uiThreadTime,
      'rasterThreadTime': rasterThreadTime,
      'gpuTime': gpuTime,
      'networkRequests': networkRequests,
      'batteryDrainRate': batteryDrainRate,
    };
  }
  
  factory PerformanceMetrics.fromMap(Map<String, dynamic> map) {
    return PerformanceMetrics(
      timestamp: DateTime.parse(map['timestamp']),
      fps: map['fps'],
      frameDropCount: map['frameDropCount'],
      memoryUsage: map['memoryUsage'],
      peakMemoryUsage: map['peakMemoryUsage'],
      uiThreadTime: map['uiThreadTime'],
      rasterThreadTime: map['rasterThreadTime'],
      gpuTime: map['gpuTime'] ?? 0,
      networkRequests: map['networkRequests'] ?? 0,
      batteryDrainRate: map['batteryDrainRate'] ?? 0,
    );
  }
}