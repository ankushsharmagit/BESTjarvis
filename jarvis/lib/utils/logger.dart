// lib/utils/logger.dart
// Advanced Logging System with File Storage

import 'dart:developer' as developer;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  verbose,
  wtf,
}

enum LogCategory {
  general,
  voice,
  security,
  device,
  communication,
  ai,
  automation,
  ui,
  network,
  database,
}

class Logger {
  static final Logger _instance = Logger._internal();
  factory Logger() => _instance;
  Logger._internal();
  
  LogLevel _minLevel = LogLevel.debug;
  bool _enableFileLogging = true;
  bool _enableConsoleLogging = true;
  final List<LogEntry> _logs = [];
  final Map<LogCategory, List<LogEntry>> _categoryLogs = {};
  File? _logFile;
  int _maxLogEntries = 10000;
  
  Future<void> initialize() async {
    if (_enableFileLogging) {
      final appDir = await getApplicationDocumentsDirectory();
      final logDir = Directory('${appDir.path}/JARVIS_Logs');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }
      _logFile = File('${logDir.path}/jarvis_${DateTime.now().millisecondsSinceEpoch}.log');
    }
  }
  
  void setMinLevel(LogLevel level) {
    _minLevel = level;
  }
  
  void enableFileLogging(bool enable) {
    _enableFileLogging = enable;
  }
  
  void enableConsoleLogging(bool enable) {
    _enableConsoleLogging = enable;
  }
  
  void debug(String message, {String? tag, LogCategory category = LogCategory.general}) {
    _log(LogLevel.debug, message, tag: tag, category: category);
  }
  
  void info(String message, {String? tag, LogCategory category = LogCategory.general}) {
    _log(LogLevel.info, message, tag: tag, category: category);
  }
  
  void warning(String message, {String? tag, LogCategory category = LogCategory.general}) {
    _log(LogLevel.warning, message, tag: tag, category: category);
  }
  
  void error(String message, {String? tag, LogCategory category = LogCategory.general, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, category: category);
    if (error != null) {
      developer.log('Error details: $error', name: tag ?? 'ERROR', error: error, stackTrace: stackTrace);
      _log(LogLevel.error, 'Details: $error', tag: tag, category: category);
    }
  }
  
  void verbose(String message, {String? tag, LogCategory category = LogCategory.general}) {
    _log(LogLevel.verbose, message, tag: tag, category: category);
  }
  
  void wtf(String message, {String? tag, LogCategory category = LogCategory.general}) {
    _log(LogLevel.wtf, message, tag: tag, category: category);
  }
  
  void _log(LogLevel level, String message, {String? tag, LogCategory category = LogCategory.general}) {
    if (level.index < _minLevel.index) return;
    
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      tag: tag,
      category: category,
    );
    
    _logs.add(entry);
    _categoryLogs.putIfAbsent(category, () => []).add(entry);
    
    // Maintain log size limit
    if (_logs.length > _maxLogEntries) {
      _logs.removeAt(0);
    }
    if (_categoryLogs[category]!.length > _maxLogEntries) {
      _categoryLogs[category]!.removeAt(0);
    }
    
    // Console output
    if (_enableConsoleLogging) {
      _printToConsole(entry);
    }
    
    // File logging
    if (_enableFileLogging) {
      _writeToFile(entry);
    }
  }
  
  void _printToConsole(LogEntry entry) {
    final levelStr = entry.level.toString().split('.').last.toUpperCase().padRight(7);
    final tagStr = entry.tag != null ? '[${entry.tag}] ' : '';
    final categoryStr = '[${entry.category.toString().split('.').last.toUpperCase()}] ';
    final logMessage = '${_formatTime(entry.timestamp)} $levelStr $categoryStr$tagStr${entry.message}';
    
    switch (entry.level) {
      case LogLevel.error:
      case LogLevel.wtf:
        developer.log(logMessage, level: 1000, name: 'JARVIS');
        break;
      case LogLevel.warning:
        developer.log(logMessage, level: 900, name: 'JARVIS');
        break;
      default:
        developer.log(logMessage, name: 'JARVIS');
    }
  }
  
  Future<void> _writeToFile(LogEntry entry) async {
    if (_logFile == null) return;
    try {
      final line = '${_formatDateTime(entry.timestamp)} | ${entry.level} | ${entry.category} | ${entry.tag ?? ''} | ${entry.message}\n';
      await _logFile!.writeAsString(line, mode: FileMode.append);
    } catch (e) {
      // Silent fail - don't want logging errors to crash app
    }
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}.${time.millisecond.toString().padLeft(3, '0')}';
  }
  
  String _formatDateTime(DateTime time) {
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${_formatTime(time)}';
  }
  
  List<LogEntry> getLogs({
    LogLevel? minLevel, 
    String? tag, 
    LogCategory? category,
    DateTime? from,
    DateTime? to,
    int limit = 100
  }) {
    var filtered = _logs.reversed.toList();
    
    if (minLevel != null) {
      filtered = filtered.where((l) => l.level.index >= minLevel.index).toList();
    }
    
    if (tag != null) {
      filtered = filtered.where((l) => l.tag == tag).toList();
    }
    
    if (category != null) {
      filtered = filtered.where((l) => l.category == category).toList();
    }
    
    if (from != null) {
      filtered = filtered.where((l) => l.timestamp.isAfter(from)).toList();
    }
    
    if (to != null) {
      filtered = filtered.where((l) => l.timestamp.isBefore(to)).toList();
    }
    
    if (filtered.length > limit) {
      filtered = filtered.sublist(0, limit);
    }
    
    return filtered;
  }
  
  Map<LogCategory, int> getLogCountByCategory() {
    final result = <LogCategory, int>{};
    for (var entry in _categoryLogs.entries) {
      result[entry.key] = entry.value.length;
    }
    return result;
  }
  
  Map<LogLevel, int> getLogCountByLevel() {
    final result = <LogLevel, int>{};
    for (var log in _logs) {
      result[log.level] = (result[log.level] ?? 0) + 1;
    }
    return result;
  }
  
  void clearLogs() {
    _logs.clear();
    _categoryLogs.clear();
  }
  
  Future<String> exportLogs({LogCategory? category, DateTime? from, DateTime? to}) async {
    final logs = getLogs(category: category, from: from, to: to, limit: 10000);
    final buffer = StringBuffer();
    
    buffer.writeln('=== JARVIS Log Export ===');
    buffer.writeln('Export Time: ${DateTime.now()}');
    buffer.writeln('Total Logs: ${logs.length}');
    buffer.writeln();
    
    for (var log in logs) {
      buffer.writeln('${_formatDateTime(log.timestamp)} | ${log.level} | ${log.category} | ${log.tag ?? ''} | ${log.message}');
    }
    
    final exportFile = File('${_logFile?.parent.path}/jarvis_export_${DateTime.now().millisecondsSinceEpoch}.log');
    await exportFile.writeAsString(buffer.toString());
    return exportFile.path;
  }
  
  Future<void> rotateLogFile() async {
    if (_logFile != null && await _logFile!.exists()) {
      final size = await _logFile!.length();
      if (size > 10 * 1024 * 1024) { // 10MB
        final archiveName = '${_logFile!.path.split('.').first}_${DateTime.now().millisecondsSinceEpoch}.log';
        await _logFile!.rename(archiveName);
        await _logFile!.create();
      }
    }
  }
  
  void dispose() {
    // Close log file if needed
  }
}

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? tag;
  final LogCategory category;
  
  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.tag,
    required this.category,
  });
  
  String getFormattedMessage() {
    return '[$timestamp] ${level.toString().split('.').last.toUpperCase()}: ${tag != null ? '[$tag] ' : ''}$message';
  }
  
  bool isError() {
    return level == LogLevel.error || level == LogLevel.wtf;
  }
  
  bool isWarning() {
    return level == LogLevel.warning;
  }
}

class PerformanceLogger {
  static final Map<String, _TimingInfo> _timings = {};
  static final List<_PerformanceRecord> _records = [];
  
  static void startTiming(String operation, {Map<String, dynamic>? metadata}) {
    _timings[operation] = _TimingInfo(
      startTime: DateTime.now(),
      metadata: metadata,
    );
  }
  
  static Duration endTiming(String operation, {Map<String, dynamic>? result}) {
    final timing = _timings[operation];
    if (timing == null) {
      Logger().warning('No start time for operation: $operation', tag: 'PERFORMANCE');
      return Duration.zero;
    }
    
    final duration = DateTime.now().difference(timing.startTime);
    _timings.remove(operation);
    
    final record = _PerformanceRecord(
      operation: operation,
      duration: duration,
      startTime: timing.startTime,
      endTime: DateTime.now(),
      metadata: timing.metadata,
      result: result,
    );
    _records.add(record);
    
    // Keep only last 1000 records
    if (_records.length > 1000) {
      _records.removeAt(0);
    }
    
    Logger().debug('Performance: $operation took ${duration.inMilliseconds}ms', tag: 'PERFORMANCE');
    
    return duration;
  }
  
  static Future<T> measure<T>(String operation, Future<T> Function() action, 
      {Map<String, dynamic>? metadata}) async {
    startTiming(operation, metadata: metadata);
    try {
      final result = await action();
      endTiming(operation, result: {'success': true});
      return result;
    } catch (e) {
      endTiming(operation, result: {'success': false, 'error': e.toString()});
      rethrow;
    }
  }
  
  static List<_PerformanceRecord> getPerformanceRecords({int limit = 50}) {
    return _records.reversed.take(limit).toList();
  }
  
  static Map<String, double> getAverageDurations() {
    final averages = <String, List<int>>{};
    for (var record in _records) {
      averages.putIfAbsent(record.operation, () => []).add(record.duration.inMilliseconds);
    }
    
    final result = <String, double>{};
    for (var entry in averages.entries) {
      result[entry.key] = entry.value.reduce((a, b) => a + b) / entry.value.length;
    }
    return result;
  }
  
  static void clearRecords() {
    _records.clear();
  }
  
  static String getPerformanceReport() {
    final buffer = StringBuffer();
    buffer.writeln('=== JARVIS Performance Report ===');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('Total Operations: ${_records.length}');
    buffer.writeln();
    
    buffer.writeln('=== Average Durations ===');
    final averages = getAverageDurations();
    for (var entry in averages.entries) {
      buffer.writeln('${entry.key}: ${entry.value.toStringAsFixed(2)}ms');
    }
    
    buffer.writeln();
    buffer.writeln('=== Slowest Operations ===');
    final sorted = _records.toList()..sort((a, b) => b.duration.compareTo(a.duration));
    for (var i = 0; i < sorted.length && i < 10; i++) {
      final record = sorted[i];
      buffer.writeln('${record.operation}: ${record.duration.inMilliseconds}ms (${record.startTime})');
    }
    
    return buffer.toString();
  }
}

class _TimingInfo {
  final DateTime startTime;
  final Map<String, dynamic>? metadata;
  
  _TimingInfo({required this.startTime, this.metadata});
}

class _PerformanceRecord {
  final String operation;
  final Duration duration;
  final DateTime startTime;
  final DateTime endTime;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? result;
  
  _PerformanceRecord({
    required this.operation,
    required this.duration,
    required this.startTime,
    required this.endTime,
    this.metadata,
    this.result,
  });
}