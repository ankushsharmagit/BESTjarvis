// lib/utils/error_handler.dart
// Centralized Error Handling & Recovery System

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'logger.dart';

class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();
  
  final List<ErrorLog> _errorLogs = [];
  final Map<String, int> _errorCounts = {};
  bool _isRecovering = false;
  
  void handleError(dynamic error, StackTrace stackTrace, 
      {String? context, bool showToUser = true, ErrorSeverity severity = ErrorSeverity.medium}) {
    
    final errorLog = ErrorLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      error: error.toString(),
      stackTrace: stackTrace.toString(),
      context: context,
      severity: severity,
    );
    
    _errorLogs.add(errorLog);
    
    // Track error count
    final errorKey = error.toString().split('\n').first;
    _errorCounts[errorKey] = (_errorCounts[errorKey] ?? 0) + 1;
    
    // Log to file
    Logger().error('[$context] $error', tag: 'ERROR', error: error, stackTrace: stackTrace);
    
    // Auto-recovery attempt
    _attemptRecovery(error, context);
    
    // Show to user if needed
    if (showToUser) {
      _showErrorToUser(error.toString(), severity);
    }
    
    // If too many errors, suggest restart
    if (_errorLogs.length > 50) {
      _suggestRestart();
    }
  }
  
  void _showErrorToUser(String error, ErrorSeverity severity) {
    // Will be implemented with UI context
    // For now, just log
    print('User notified of error: $error (Severity: ${severity.toString()})');
  }
  
  void _attemptRecovery(dynamic error, String? context) {
    if (_isRecovering) return;
    _isRecovering = true;
    
    final errorStr = error.toString().toLowerCase();
    
    // Network errors
    if (errorStr.contains('network') || errorStr.contains('internet') || 
        errorStr.contains('socket') || errorStr.contains('timeout')) {
      Logger().info('Network error detected, switching to offline mode', tag: 'RECOVERY');
      _switchToOfflineMode();
    }
    
    // Memory errors
    else if (errorStr.contains('memory') || errorStr.contains('out of memory') ||
        errorStr.contains('oom')) {
      Logger().info('Memory error detected, clearing caches', tag: 'RECOVERY');
      _clearMemoryCaches();
    }
    
    // Permission errors
    else if (errorStr.contains('permission') || errorStr.contains('access denied')) {
      Logger().info('Permission error detected, requesting again', tag: 'RECOVERY');
      _reRequestPermissions();
    }
    
    // Camera errors
    else if (errorStr.contains('camera') || errorStr.contains('cameraaccess')) {
      Logger().info('Camera error detected, resetting camera', tag: 'RECOVERY');
      _resetCamera();
    }
    
    // Voice recognition errors
    else if (errorStr.contains('speech') || errorStr.contains('recognition')) {
      Logger().info('Speech recognition error, restarting service', tag: 'RECOVERY');
      _restartSpeechService();
    }
    
    _isRecovering = false;
  }
  
  Future<void> _switchToOfflineMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('offline_mode', true);
    // Notify user
  }
  
  Future<void> _clearMemoryCaches() async {
    // Clear temporary files and caches
    try {
      final tempDir = Directory.systemTemp;
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (e) {
      Logger().error('Failed to clear caches', tag: 'RECOVERY', error: e);
    }
  }
  
  Future<void> _reRequestPermissions() async {
    // Re-request critical permissions
    // Implementation would use permission_handler
  }
  
  Future<void> _resetCamera() async {
    // Reset camera controller
  }
  
  Future<void> _restartSpeechService() async {
    // Restart speech recognition
  }
  
  void _suggestRestart() {
    Logger().warning('Too many errors detected, suggesting app restart', tag: 'RECOVERY');
    // Show dialog to user suggesting restart
  }
  
  List<ErrorLog> getErrorLogs({int limit = 100, ErrorSeverity? minSeverity}) {
    var filtered = _errorLogs.reversed.toList();
    
    if (minSeverity != null) {
      filtered = filtered.where((e) => e.severity.index >= minSeverity.index).toList();
    }
    
    if (filtered.length > limit) {
      filtered = filtered.sublist(0, limit);
    }
    
    return filtered;
  }
  
  void clearErrorLogs() {
    _errorLogs.clear();
    _errorCounts.clear();
  }
  
  int getErrorCount() {
    return _errorLogs.length;
  }
  
  Map<String, int> getErrorStats() {
    return Map.from(_errorCounts);
  }
  
  String getMostFrequentError() {
    if (_errorCounts.isEmpty) return 'None';
    return _errorCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
  
  double getErrorRate() {
    // Calculate errors per minute in last hour
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    final recentErrors = _errorLogs.where((e) => e.timestamp.isAfter(oneHourAgo)).length;
    return recentErrors / 60.0; // errors per minute
  }
  
  String getHealthStatus() {
    final errorRate = getErrorRate();
    final totalErrors = _errorLogs.length;
    
    if (totalErrors == 0) return 'Excellent';
    if (errorRate < 0.1) return 'Good';
    if (errorRate < 0.5) return 'Fair';
    if (errorRate < 1.0) return 'Poor';
    return 'Critical';
  }
  
  String getErrorReport() {
    final buffer = StringBuffer();
    buffer.writeln('=== JARVIS Error Report ===');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('Total Errors: ${_errorLogs.length}');
    buffer.writeln('Health Status: ${getHealthStatus()}');
    buffer.writeln('Error Rate: ${getErrorRate().toStringAsFixed(2)} errors/min');
    buffer.writeln('Most Frequent: ${getMostFrequentError()}');
    buffer.writeln();
    
    buffer.writeln('=== Error Breakdown ===');
    for (var entry in _errorCounts.entries) {
      buffer.writeln('${entry.key}: ${entry.value} times');
    }
    buffer.writeln();
    
    buffer.writeln('=== Recent Errors ===');
    for (var i = 0; i < _errorLogs.length && i < 20; i++) {
      final log = _errorLogs[_errorLogs.length - 1 - i];
      buffer.writeln('[${log.timestamp}] ${log.severity}: ${log.error.split('\n').first}');
      if (log.context != null) buffer.writeln('    Context: ${log.context}');
    }
    
    return buffer.toString();
  }
  
  Future<void> exportErrorReport() async {
    final report = getErrorReport();
    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/jarvis_error_report_${DateTime.now().millisecondsSinceEpoch}.txt');
    await file.writeAsString(report);
    Logger().info('Error report exported to ${file.path}', tag: 'ERROR');
  }
}

class ErrorLog {
  final String id;
  final DateTime timestamp;
  final String error;
  final String stackTrace;
  final String? context;
  final ErrorSeverity severity;
  bool isResolved;
  String? resolution;
  
  ErrorLog({
    required this.id,
    required this.timestamp,
    required this.error,
    required this.stackTrace,
    this.context,
    this.severity = ErrorSeverity.medium,
    this.isResolved = false,
    this.resolution,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'error': error,
      'stackTrace': stackTrace,
      'context': context,
      'severity': severity.index,
      'isResolved': isResolved,
      'resolution': resolution,
    };
  }
  
  factory ErrorLog.fromMap(Map<String, dynamic> map) {
    return ErrorLog(
      id: map['id'],
      timestamp: DateTime.parse(map['timestamp']),
      error: map['error'],
      stackTrace: map['stackTrace'],
      context: map['context'],
      severity: ErrorSeverity.values[map['severity']],
      isResolved: map['isResolved'],
      resolution: map['resolution'],
    );
  }
  
  String getFormattedTimestamp() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
  
  String getSeverityIcon() {
    switch (severity) {
      case ErrorSeverity.low:
        return '⚠️';
      case ErrorSeverity.medium:
        return '🔶';
      case ErrorSeverity.high:
        return '🔴';
      case ErrorSeverity.critical:
        return '💀';
    }
  }
  
  Color getSeverityColor() {
    switch (severity) {
      case ErrorSeverity.low:
        return Colors.yellow;
      case ErrorSeverity.medium:
        return Colors.orange;
      case ErrorSeverity.high:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.purple;
    }
  }
}

enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

class AppException implements Exception {
  final String message;
  final String code;
  final String? details;
  
  AppException(this.message, {this.code = 'UNKNOWN', this.details});
  
  @override
  String toString() => '[$code] $message${details != null ? '\nDetails: $details' : ''}';
}

class NetworkException extends AppException {
  NetworkException(String message, {String? details}) 
      : super(message, code: 'NETWORK', details: details);
}

class PermissionException extends AppException {
  PermissionException(String message, {String? details}) 
      : super(message, code: 'PERMISSION', details: details);
}

class AuthenticationException extends AppException {
  AuthenticationException(String message, {String? details}) 
      : super(message, code: 'AUTH', details: details);
}

class AiException extends AppException {
  AiException(String message, {String? details}) 
      : super(message, code: 'AI', details: details);
}

class DeviceControlException extends AppException {
  DeviceControlException(String message, {String? details}) 
      : super(message, code: 'DEVICE', details: details);
}

class FileException extends AppException {
  FileException(String message, {String? details}) 
      : super(message, code: 'FILE', details: details);
}

class VoiceException extends AppException {
  VoiceException(String message, {String? details}) 
      : super(message, code: 'VOICE', details: details);
}

class CameraException extends AppException {
  CameraException(String message, {String? details}) 
      : super(message, code: 'CAMERA', details: details);
}

class Result<T> {
  final T? data;
  final AppException? error;
  final bool isSuccess;
  
  Result.success(this.data)
      : error = null,
        isSuccess = true;
  
  Result.failure(this.error)
      : data = null,
        isSuccess = false;
  
  void onSuccess(void Function(T) action) {
    if (isSuccess && data != null) {
      action(data!);
    }
  }
  
  void onFailure(void Function(AppException) action) {
    if (!isSuccess && error != null) {
      action(error!);
    }
  }
  
  T getOrThrow() {
    if (isSuccess && data != null) {
      return data!;
    }
    throw error ?? AppException('Unknown error');
  }
  
  T getOrDefault(T defaultValue) {
    return isSuccess && data != null ? data! : defaultValue;
  }
  
  Result<R> map<R>(R Function(T) mapper) {
    if (isSuccess && data != null) {
      return Result.success(mapper(data!));
    } else {
      return Result.failure(error!);
    }
  }
  
  Future<Result<R>> asyncMap<R>(Future<R> Function(T) mapper) async {
    if (isSuccess && data != null) {
      try {
        final result = await mapper(data!);
        return Result.success(result);
      } catch (e, stack) {
        return Result.failure(AppException(e.toString()));
      }
    } else {
      return Result.failure(error!);
    }
  }
}

class RetryHelper {
  static Future<T> retry<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    bool exponentialBackoff = true,
    void Function(int attempt, Duration delay)? onRetry,
  }) async {
    var attempts = 0;
    var currentDelay = delay;
    
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) rethrow;
        
        if (exponentialBackoff) {
          currentDelay = Duration(milliseconds: currentDelay.inMilliseconds * 2);
        }
        
        onRetry?.call(attempts, currentDelay);
        await Future.delayed(currentDelay);
      }
    }
    throw Exception('Max retries exceeded');
  }
  
  static Future<T> retryWithBackoff<T>({
    required Future<T> Function() operation,
    int maxRetries = 5,
    Duration initialDelay = const Duration(milliseconds: 500),
    double backoffFactor = 2.0,
  }) async {
    var delay = initialDelay;
    for (var i = 0; i < maxRetries; i++) {
      try {
        return await operation();
      } catch (e) {
        if (i == maxRetries - 1) rethrow;
        await Future.delayed(delay);
        delay = Duration(milliseconds: (delay.inMilliseconds * backoffFactor).round());
      }
    }
    throw Exception('Max retries exceeded');
  }
}

class FallbackHandler {
  static T withFallback<T>({
    required T Function() primary,
    required T Function() fallback,
    bool shouldFallback = true,
  }) {
    if (!shouldFallback) {
      return primary();
    }
    
    try {
      return primary();
    } catch (e) {
      Logger().warning('Primary failed, using fallback', tag: 'FALLBACK', error: e);
      return fallback();
    }
  }
  
  static Future<T> withFallbackAsync<T>({
    required Future<T> Function() primary,
    required Future<T> Function() fallback,
    bool shouldFallback = true,
  }) async {
    if (!shouldFallback) {
      return await primary();
    }
    
    try {
      return await primary();
    } catch (e) {
      Logger().warning('Primary failed, using fallback', tag: 'FALLBACK', error: e);
      return await fallback();
    }
  }
}