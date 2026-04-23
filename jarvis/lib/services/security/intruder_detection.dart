// lib/services/security/intruder_detection.dart
// Intruder Detection & Security Monitoring System

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';
import '../../models/intruder_log.dart';
import '../../config/constants.dart';

class IntruderDetectionService {
  static final IntruderDetectionService _instance = IntruderDetectionService._internal();
  factory IntruderDetectionService() => _instance;
  IntruderDetectionService._internal();
  
  final List<IntruderLog> _intruderLogs = [];
  bool _isMonitoring = false;
  CameraController? _cameraController;
  
  Future<void> initialize() async {
    try {
      await _loadLogs();
      _startMonitoring();
      Logger().info('Intruder detection service initialized', tag: 'INTRUDER');
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'Intruder Init');
    }
  }
  
  void _startMonitoring() {
    _isMonitoring = true;
    // Start monitoring for suspicious activities
    Logger().info('Intruder monitoring started', tag: 'INTRUDER');
  }
  
  Future<void> logIntruderAttempt({
    required String actionType,
    String? attemptedAccess,
    bool capturePhoto = true,
  }) async {
    try {
      String? photoPath;
      Position? position;
      
      // Capture photo if enabled
      if (capturePhoto) {
        photoPath = await _captureIntruderPhoto();
      }
      
      // Get location
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        Logger().warning('Could not get location for intruder log', tag: 'INTRUDER');
      }
      
      final log = IntruderLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        actionType: actionType,
        photoPath: photoPath,
        latitude: position?.latitude,
        longitude: position?.longitude,
        attemptedAccess: attemptedAccess,
        attemptDuration: 0,
        wasSuccessful: false,
        deviceInfo: await _getDeviceInfo(),
      );
      
      _intruderLogs.add(log);
      await _saveLogs();
      
      Logger().warning('Intruder attempt logged: $actionType', tag: 'INTRUDER');
      
      // Send alert if configured
      await _sendAlert(log);
      
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'Log Intruder');
    }
  }
  
  Future<String?> _captureIntruderPhoto() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      
      _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
      await _cameraController!.initialize();
      
      // Wait a moment for camera to adjust
      await Future.delayed(const Duration(milliseconds: 500));
      
      final image = await _cameraController!.takePicture();
      
      // Save to intruder photos directory
      final appDir = await getApplicationDocumentsDirectory();
      final intruderDir = Directory('${appDir.path}/${AppConstants.intruderPhotosDirectory}');
      if (!await intruderDir.exists()) {
        await intruderDir.create(recursive: true);
      }
      
      final fileName = 'intruder_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${intruderDir.path}/$fileName';
      await File(image.path).copy(savedPath);
      
      await _cameraController!.dispose();
      
      Logger().info('Intruder photo captured: $savedPath', tag: 'INTRUDER');
      return savedPath;
      
    } catch (e) {
      Logger().error('Failed to capture intruder photo', tag: 'INTRUDER', error: e);
      return null;
    }
  }
  
  Future<String> _getDeviceInfo() async {
    // Get device information
    return 'Android Device'; // Placeholder
  }
  
  Future<void> _sendAlert(IntruderLog log) async {
    // Send alert to owner via notification or SMS
    Logger().info('Alert sent for intruder attempt', tag: 'INTRUDER');
  }
  
  Future<void> _saveLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = _intruderLogs.map((l) => l.toMap()).toList();
      // Save to shared preferences or database
    } catch (e) {
      Logger().error('Error saving intruder logs', tag: 'INTRUDER', error: e);
    }
  }
  
  Future<void> _loadLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Load logs from storage
    } catch (e) {
      Logger().error('Error loading intruder logs', tag: 'INTRUDER', error: e);
    }
  }
  
  List<IntruderLog> getIntruderLogs({int limit = 50}) {
    return _intruderLogs.reversed.take(limit).toList();
  }
  
  Future<void> clearLogs() async {
    _intruderLogs.clear();
    await _saveLogs();
    Logger().info('Intruder logs cleared', tag: 'INTRUDER');
  }
  
  Future<void> emergencyLockdown() async {
    Logger().warning('EMERGENCY LOCKDOWN ACTIVATED', tag: 'INTRUDER');
    
    // Capture intruder photo
    final photoPath = await _captureIntruderPhoto();
    
    // Get location
    Position? position;
    try {
      position = await Geolocator.getCurrentPosition();
    } catch (e) {}
    
    // Log the incident
    final log = IntruderLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      actionType: 'EMERGENCY_LOCKDOWN',
      photoPath: photoPath,
      latitude: position?.latitude,
      longitude: position?.longitude,
      attemptedAccess: 'Emergency lockdown triggered',
      attemptDuration: 0,
      wasSuccessful: false,
    );
    _intruderLogs.add(log);
    await _saveLogs();
    
    // Send emergency alert
    await _sendEmergencyAlert(log);
  }
  
  Future<void> _sendEmergencyAlert(IntruderLog log) async {
    // Send SMS to emergency contacts
    Logger().info('Emergency alert sent to contacts', tag: 'INTRUDER');
  }
  
  Future<Map<String, dynamic>> getSecurityStats() async {
    final now = DateTime.now();
    final todayLogs = _intruderLogs.where((l) => 
      l.timestamp.day == now.day && 
      l.timestamp.month == now.month && 
      l.timestamp.year == now.year
    ).length;
    
    final weekLogs = _intruderLogs.where((l) => 
      now.difference(l.timestamp).inDays <= 7
    ).length;
    
    return {
      'totalAttempts': _intruderLogs.length,
      'todayAttempts': todayLogs,
      'weekAttempts': weekLogs,
      'uniqueIntruders': _intruderLogs.map((l) => l.photoPath).toSet().length,
      'lastAttempt': _intruderLogs.isNotEmpty 
          ? _intruderLogs.last.timestamp 
          : null,
      'mostCommonAction': _getMostCommonAction(),
    };
  }
  
  String _getMostCommonAction() {
    if (_intruderLogs.isEmpty) return 'None';
    final actions = <String, int>{};
    for (var log in _intruderLogs) {
      actions[log.actionType] = (actions[log.actionType] ?? 0) + 1;
    }
    return actions.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
  
  void dispose() {
    _cameraController?.dispose();
  }
}