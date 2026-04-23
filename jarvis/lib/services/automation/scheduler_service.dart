// lib/services/automation/scheduler_service.dart
// Scheduled Task Service

import 'dart:async';
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';

class SchedulerService {
  static final SchedulerService _instance = SchedulerService._internal();
  factory SchedulerService() => _instance;
  SchedulerService._internal();
  
  final List<ScheduledTask> _tasks = [];
  Timer? _schedulerTimer;
  
  Future<void> initialize() async {
    await _loadTasks();
    _startScheduler();
    Logger().info('Scheduler service initialized with ${_tasks.length} tasks', tag: 'SCHEDULER');
  }
  
  void _startScheduler() {
    _schedulerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkTasks();
    });
  }
  
  Future<void> _checkTasks() async {
    final now = DateTime.now();
    
    for (var task in _tasks) {
      if (!task.isActive) continue;
      if (task.isExecuted) continue;
      
      if (now.isAfter(task.scheduledTime)) {
        await _executeTask(task);
        task.isExecuted = true;
        await _saveTasks();
      }
    }
  }
  
  Future<void> _executeTask(ScheduledTask task) async {
    try {
      Logger().info('Executing scheduled task: ${task.id}', tag: 'SCHEDULER');
      
      switch (task.type) {
        case TaskType.reminder:
          // Show reminder notification
          break;
        case TaskType.alarm:
          // Trigger alarm
          break;
        case TaskType.message:
          // Send scheduled message
          break;
        case TaskType.routine:
          // Execute routine
          break;
        case TaskType.device:
          // Execute device command
          break;
      }
      
    } catch (e) {
      Logger().error('Task execution error', tag: 'SCHEDULER', error: e);
    }
  }
  
  Future<void> addTask(ScheduledTask task) async {
    _tasks.add(task);
    await _saveTasks();
    Logger().info('Added scheduled task: ${task.id}', tag: 'SCHEDULER');
  }
  
  Future<void> removeTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    await _saveTasks();
    Logger().info('Removed scheduled task: $taskId', tag: 'SCHEDULER');
  }
  
  List<ScheduledTask> getPendingTasks() {
    return _tasks.where((t) => !t.isExecuted && t.isActive).toList();
  }
  
  List<ScheduledTask> getCompletedTasks() {
    return _tasks.where((t) => t.isExecuted).toList();
  }
  
  Future<void> _loadTasks() async {
    // Load from database
  }
  
  Future<void> _saveTasks() async {
    // Save to database
  }
  
  void dispose() {
    _schedulerTimer?.cancel();
  }
}

class ScheduledTask {
  final String id;
  final TaskType type;
  final DateTime scheduledTime;
  final Map<String, dynamic> data;
  bool isExecuted;
  bool isActive;
  final DateTime createdAt;
  
  ScheduledTask({
    required this.id,
    required this.type,
    required this.scheduledTime,
    required this.data,
    this.isExecuted = false,
    this.isActive = true,
    required this.createdAt,
  });
  
  String getFormattedTime() {
    return '${scheduledTime.day}/${scheduledTime.month} ${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}';
  }
  
  String getRemainingTime() {
    final diff = scheduledTime.difference(DateTime.now());
    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''}';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Less than a minute';
    }
  }
}

enum TaskType {
  reminder,
  alarm,
  message,
  routine,
  device,
}