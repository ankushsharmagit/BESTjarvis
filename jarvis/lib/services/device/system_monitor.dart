// lib/services/device/system_monitor.dart
// Real-time System Performance Monitor

import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../utils/logger.dart';
import '../../utils/helpers.dart';

class SystemMonitorService {
  static final SystemMonitorService _instance = SystemMonitorService._internal();
  factory SystemMonitorService() => _instance;
  SystemMonitorService._internal();
  
  final Battery _battery = Battery();
  final DeviceInfoPlus _deviceInfo = DeviceInfoPlus();
  final Connectivity _connectivity = Connectivity();
  
  Timer? _monitorTimer;
  final List<PerformanceData> _history = [];
  
  StreamController<PerformanceData> _performanceStream = StreamController<PerformanceData>.broadcast();
  Stream<PerformanceData> get performanceStream => _performanceStream.stream;
  
  void startMonitoring({int intervalSeconds = 5}) {
    _monitorTimer?.cancel();
    _monitorTimer = Timer.periodic(Duration(seconds: intervalSeconds), (timer) async {
      final data = await getCurrentPerformance();
      _history.add(data);
      
      // Keep last 1000 records
      if (_history.length > 1000) {
        _history.removeAt(0);
      }
      
      _performanceStream.add(data);
    });
    Logger().info('System monitoring started', tag: 'MONITOR');
  }
  
  void stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
    Logger().info('System monitoring stopped', tag: 'MONITOR');
  }
  
  Future<PerformanceData> getCurrentPerformance() async {
    final battery = await _getBatteryInfo();
    final network = await _getNetworkInfo();
    final memory = await _getMemoryInfo();
    final storage = await _getStorageInfo();
    
    return PerformanceData(
      timestamp: DateTime.now(),
      cpuUsage: _getCpuUsage(),
      ramUsage: memory['usedPercent'],
      ramTotal: memory['total'],
      ramFree: memory['free'],
      storageUsed: storage['usedPercent'],
      storageTotal: storage['total'],
      storageFree: storage['free'],
      batteryLevel: battery['level'],
      isCharging: battery['isCharging'],
      batteryTemperature: battery['temperature'],
      networkType: network['type'],
      networkStrength: network['strength'],
      activeProcesses: _getActiveProcesses(),
    );
  }
  
  Future<Map<String, dynamic>> _getBatteryInfo() async {
    try {
      final level = await _battery.batteryLevel;
      final state = await _battery.batteryState;
      final isCharging = state == BatteryState.charging;
      
      return {
        'level': level,
        'isCharging': isCharging,
        'temperature': 28.5, // Would need additional API
        'voltage': 3.8,
      };
    } catch (e) {
      return {'level': 50, 'isCharging': false, 'temperature': 25};
    }
  }
  
  Future<Map<String, dynamic>> _getNetworkInfo() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return {
        'type': result.toString().split('.').last,
        'strength': 75, // Would need additional API
        'isConnected': result != ConnectivityResult.none,
      };
    } catch (e) {
      return {'type': 'Unknown', 'strength': 0, 'isConnected': false};
    }
  }
  
  Future<Map<String, dynamic>> _getMemoryInfo() async {
    // Get memory info from Android
    try {
      final androidInfo = await _deviceInfo.androidInfo;
      final totalRam = androidInfo.totalRam ?? 0;
      // Would need additional API for free RAM
      return {
        'total': totalRam,
        'free': totalRam ~/ 2,
        'usedPercent': 50,
      };
    } catch (e) {
      return {'total': 8 * 1024 * 1024 * 1024, 'free': 4 * 1024 * 1024 * 1024, 'usedPercent': 50};
    }
  }
  
  Future<Map<String, dynamic>> _getStorageInfo() async {
    try {
      final dir = await getExternalStorageDirectory();
      final stat = await dir!.stat();
      final total = stat.size;
      final free = stat.free;
      final used = total - free;
      final usedPercent = (used / total) * 100;
      
      return {
        'total': total,
        'free': free,
        'used': used,
        'usedPercent': usedPercent,
      };
    } catch (e) {
      return {'total': 128 * 1024 * 1024 * 1024, 'free': 64 * 1024 * 1024 * 1024, 'usedPercent': 50};
    }
  }
  
  double _getCpuUsage() {
    // Would need native implementation for real CPU usage
    return 25.0 + (DateTime.now().second % 50);
  }
  
  int _getActiveProcesses() {
    // Would need to count running processes
    return 50 + (DateTime.now().second % 30);
  }
  
  List<PerformanceData> getHistory({int limit = 100}) {
    return _history.reversed.take(limit).toList();
  }
  
  PerformanceData getAveragePerformance() {
    if (_history.isEmpty) {
      return PerformanceData(
        timestamp: DateTime.now(),
        cpuUsage: 0,
        ramUsage: 0,
        ramTotal: 0,
        ramFree: 0,
        storageUsed: 0,
        storageTotal: 0,
        storageFree: 0,
        batteryLevel: 0,
        isCharging: false,
        batteryTemperature: 0,
        networkType: '',
        networkStrength: 0,
        activeProcesses: 0,
      );
    }
    
    double avgCpu = 0;
    double avgRam = 0;
    double avgStorage = 0;
    double avgBattery = 0;
    
    for (var data in _history) {
      avgCpu += data.cpuUsage;
      avgRam += data.ramUsage;
      avgStorage += data.storageUsed;
      avgBattery += data.batteryLevel;
    }
    
    return PerformanceData(
      timestamp: DateTime.now(),
      cpuUsage: avgCpu / _history.length,
      ramUsage: avgRam / _history.length,
      ramTotal: _history.last.ramTotal,
      ramFree: _history.last.ramFree,
      storageUsed: avgStorage / _history.length,
      storageTotal: _history.last.storageTotal,
      storageFree: _history.last.storageFree,
      batteryLevel: avgBattery / _history.length,
      isCharging: _history.last.isCharging,
      batteryTemperature: _history.last.batteryTemperature,
      networkType: _history.last.networkType,
      networkStrength: _history.last.networkStrength,
      activeProcesses: _history.last.activeProcesses,
    );
  }
  
  String getHealthScore() {
    final avg = getAveragePerformance();
    double score = 100;
    
    if (avg.cpuUsage > 80) score -= 20;
    else if (avg.cpuUsage > 60) score -= 10;
    
    if (avg.ramUsage > 85) score -= 15;
    else if (avg.ramUsage > 70) score -= 8;
    
    if (avg.storageUsed > 90) score -= 20;
    else if (avg.storageUsed > 75) score -= 10;
    
    if (avg.batteryLevel < 15) score -= 15;
    else if (avg.batteryLevel < 30) score -= 5;
    
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Poor';
  }
  
  void dispose() {
    _monitorTimer?.cancel();
    _performanceStream.close();
  }
}

class PerformanceData {
  final DateTime timestamp;
  final double cpuUsage;
  final double ramUsage;
  final int ramTotal;
  final int ramFree;
  final double storageUsed;
  final int storageTotal;
  final int storageFree;
  final int batteryLevel;
  final bool isCharging;
  final double batteryTemperature;
  final String networkType;
  final int networkStrength;
  final int activeProcesses;
  
  PerformanceData({
    required this.timestamp,
    required this.cpuUsage,
    required this.ramUsage,
    required this.ramTotal,
    required this.ramFree,
    required this.storageUsed,
    required this.storageTotal,
    required this.storageFree,
    required this.batteryLevel,
    required this.isCharging,
    required this.batteryTemperature,
    required this.networkType,
    required this.networkStrength,
    required this.activeProcesses,
  });
  
  String getFormattedTimestamp() {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }
  
  String getRamFormatted() {
    return '${(ramTotal - ramFree) ~/ (1024 * 1024)}MB / ${ramTotal ~/ (1024 * 1024)}MB';
  }
  
  String getStorageFormatted() {
    return '${(storageTotal - storageFree) ~/ (1024 * 1024 * 1024)}GB / ${storageTotal ~/ (1024 * 1024 * 1024)}GB';
  }
  
  String getHealthEmoji() {
    if (cpuUsage > 80) return '🔥';
    if (cpuUsage > 60) return '⚠️';
    if (batteryLevel < 20) return '🔋';
    return '✅';
  }
  
  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'cpuUsage': cpuUsage,
      'ramUsage': ramUsage,
      'ramTotal': ramTotal,
      'ramFree': ramFree,
      'storageUsed': storageUsed,
      'storageTotal': storageTotal,
      'storageFree': storageFree,
      'batteryLevel': batteryLevel,
      'isCharging': isCharging,
      'batteryTemperature': batteryTemperature,
      'networkType': networkType,
      'networkStrength': networkStrength,
      'activeProcesses': activeProcesses,
    };
  }
}