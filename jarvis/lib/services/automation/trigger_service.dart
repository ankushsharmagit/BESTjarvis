// lib/services/automation/trigger_service.dart
// Conditional Trigger Service for Automation

import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';
import '../device/device_control.dart';

enum TriggerType {
  time,
  location,
  battery,
  connectivity,
  appLaunch,
  notification,
  voiceCommand,
  sensor,
  schedule,
}

class TriggerService {
  static final TriggerService _instance = TriggerService._internal();
  factory TriggerService() => _instance;
  TriggerService._internal();
  
  final List<Trigger> _triggers = [];
  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();
  
  Timer? _timeChecker;
  Timer? _batteryChecker;
  Timer? _locationChecker;
  
  String? _currentApp;
  String? _lastNotification;
  
  StreamController<TriggerEvent> _triggerStream = StreamController<TriggerEvent>.broadcast();
  Stream<TriggerEvent> get onTrigger => _triggerStream.stream;
  
  Future<void> initialize() async {
    await _loadTriggers();
    _startTimeChecker();
    _startBatteryChecker();
    _startConnectivityListener();
    _startAppListener();
    _startNotificationListener();
    
    Logger().info('Trigger service initialized with ${_triggers.length} triggers', tag: 'TRIGGER');
  }
  
  void _startTimeChecker() {
    _timeChecker = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkTimeTriggers();
    });
  }
  
  void _startBatteryChecker() {
    _batteryChecker = Timer.periodic(const Duration(minutes: 5), (timer) async {
      final batteryLevel = await _battery.batteryLevel;
      _checkBatteryTriggers(batteryLevel);
    });
  }
  
  void _startConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((result) {
      _checkConnectivityTriggers(result);
    });
  }
  
  void _startAppListener() {
    // Listen for app launches
    Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkAppTriggers();
    });
  }
  
  void _startNotificationListener() {
    // Listen for notifications
    // Would use NotificationListenerService
  }
  
  void _checkTimeTriggers() {
    final now = DateTime.now();
    final timeKey = '${now.hour}:${now.minute}';
    final dayKey = now.weekday;
    
    for (var trigger in _triggers) {
      if (trigger.type == TriggerType.time && trigger.isActive) {
        if (trigger.timeValue == timeKey) {
          if (trigger.daysOfWeek == null || trigger.daysOfWeek!.contains(dayKey)) {
            _fireTrigger(trigger, {'time': timeKey, 'day': dayKey});
          }
        }
      }
    }
  }
  
  void _checkBatteryTriggers(int batteryLevel) {
    for (var trigger in _triggers) {
      if (trigger.type == TriggerType.battery && trigger.isActive) {
        bool shouldFire = false;
        
        if (trigger.condition == 'below' && batteryLevel <= trigger.threshold) {
          shouldFire = true;
        } else if (trigger.condition == 'above' && batteryLevel >= trigger.threshold) {
          shouldFire = true;
        } else if (trigger.condition == 'equal' && batteryLevel == trigger.threshold) {
          shouldFire = true;
        }
        
        if (shouldFire) {
          _fireTrigger(trigger, {'batteryLevel': batteryLevel, 'threshold': trigger.threshold});
        }
      }
    }
  }
  
  void _checkConnectivityTriggers(ConnectivityResult result) {
    final connectionType = result.toString().split('.').last;
    
    for (var trigger in _triggers) {
      if (trigger.type == TriggerType.connectivity && trigger.isActive) {
        if (trigger.connectivityType == connectionType) {
          _fireTrigger(trigger, {'connectivity': connectionType});
        } else if (trigger.condition == 'disconnect' && result == ConnectivityResult.none) {
          _fireTrigger(trigger, {'connectivity': 'disconnected'});
        } else if (trigger.condition == 'connect' && result != ConnectivityResult.none) {
          _fireTrigger(trigger, {'connectivity': 'connected'});
        }
      }
    }
  }
  
  void _checkAppTriggers() async {
    // Get current foreground app
    // Would use UsageStatsManager or AccessibilityService
    
    for (var trigger in _triggers) {
      if (trigger.type == TriggerType.appLaunch && trigger.isActive) {
        if (trigger.appName != null && _currentApp?.contains(trigger.appName!) == true) {
          _fireTrigger(trigger, {'app': _currentApp});
        }
      }
    }
  }
  
  void _checkLocationTriggers(Position position) {
    for (var trigger in _triggers) {
      if (trigger.type == TriggerType.location && trigger.isActive) {
        if (trigger.location != null) {
          final distance = _calculateDistance(
            position.latitude, position.longitude,
            trigger.location!.latitude, trigger.location!.longitude,
          );
          
          if (trigger.condition == 'enter' && distance <= trigger.radius) {
            _fireTrigger(trigger, {'location': trigger.location!.name, 'distance': distance});
          } else if (trigger.condition == 'exit' && distance > trigger.radius) {
            _fireTrigger(trigger, {'location': trigger.location!.name, 'distance': distance});
          }
        }
      }
    }
  }
  
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // Earth's radius in meters
    final dLat = (lat2 - lat1) * 3.14159 / 180;
    final dLon = (lon2 - lon1) * 3.14159 / 180;
    final a = 
        (dLat / 2).sin() * (dLat / 2).sin() +
        (lat1 * 3.14159 / 180).cos() * 
        (lat2 * 3.14159 / 180).cos() * 
        (dLon / 2).sin() * (dLon / 2).sin();
    final c = 2 * (a.sqrt()).atan2((1 - a).sqrt());
    return R * c;
  }
  
  void _fireTrigger(Trigger trigger, Map<String, dynamic> data) {
    Logger().info('Trigger fired: ${trigger.name} (${trigger.type})', tag: 'TRIGGER');
    
    final event = TriggerEvent(
      triggerId: trigger.id,
      triggerName: trigger.name,
      type: trigger.type,
      data: data,
      timestamp: DateTime.now(),
    );
    
    _triggerStream.add(event);
    
    // Execute associated actions
    for (var action in trigger.actions) {
      _executeAction(action, data);
    }
  }
  
  void _executeAction(TriggerAction action, Map<String, dynamic> triggerData) {
    switch (action.type) {
      case ActionType.speak:
        _speak(action.message ?? 'Trigger activated');
        break;
      case ActionType.notify:
        _showNotification(action.title ?? 'Trigger', action.message ?? '');
        break;
      case ActionType.runRoutine:
        _runRoutine(action.routineName);
        break;
      case ActionType.sendMessage:
        _sendMessage(action.contact, action.message);
        break;
      case ActionType.makeCall:
        _makeCall(action.contact);
        break;
      case ActionType.deviceControl:
        _deviceControl(action.deviceAction, action.deviceValue);
        break;
      case ActionType.triggerOther:
        _triggerOther(action.triggerId);
        break;
    }
  }
  
  void _speak(String message) {
    // Use TTS service to speak
    Logger().info('Speaking: $message', tag: 'TRIGGER');
  }
  
  void _showNotification(String title, String message) {
    // Show local notification
    Logger().info('Notification: $title - $message', tag: 'TRIGGER');
  }
  
  void _runRoutine(String routineName) {
    Logger().info('Running routine: $routineName', tag: 'TRIGGER');
  }
  
  void _sendMessage(String? contact, String? message) {
    Logger().info('Sending message to $contact: $message', tag: 'TRIGGER');
  }
  
  void _makeCall(String? contact) {
    Logger().info('Calling: $contact', tag: 'TRIGGER');
  }
  
  void _deviceControl(String? action, String? value) {
    Logger().info('Device control: $action = $value', tag: 'TRIGGER');
  }
  
  void _triggerOther(String? triggerId) {
    Logger().info('Triggering other: $triggerId', tag: 'TRIGGER');
  }
  
  // ============ PUBLIC METHODS ============
  
  Future<void> addTrigger(Trigger trigger) async {
    _triggers.add(trigger);
    await _saveTriggers();
    Logger().info('Added trigger: ${trigger.name}', tag: 'TRIGGER');
  }
  
  Future<void> removeTrigger(String triggerId) async {
    _triggers.removeWhere((t) => t.id == triggerId);
    await _saveTriggers();
    Logger().info('Removed trigger: $triggerId', tag: 'TRIGGER');
  }
  
  Future<void> updateTrigger(Trigger trigger) async {
    final index = _triggers.indexWhere((t) => t.id == trigger.id);
    if (index != -1) {
      _triggers[index] = trigger;
      await _saveTriggers();
      Logger().info('Updated trigger: ${trigger.name}', tag: 'TRIGGER');
    }
  }
  
  List<Trigger> getTriggers() {
    return List.unmodifiable(_triggers);
  }
  
  List<Trigger> getActiveTriggers() {
    return _triggers.where((t) => t.isActive).toList();
  }
  
  Future<void> enableTrigger(String triggerId) async {
    final trigger = _triggers.firstWhere((t) => t.id == triggerId);
    trigger.isActive = true;
    await _saveTriggers();
    Logger().info('Enabled trigger: ${trigger.name}', tag: 'TRIGGER');
  }
  
  Future<void> disableTrigger(String triggerId) async {
    final trigger = _triggers.firstWhere((t) => t.id == triggerId);
    trigger.isActive = false;
    await _saveTriggers();
    Logger().info('Disabled trigger: ${trigger.name}', tag: 'TRIGGER');
  }
  
  Future<void> _loadTriggers() async {
    // Load from database
    _triggers.addAll(_getDefaultTriggers());
  }
  
  List<Trigger> _getDefaultTriggers() {
    return [
      Trigger(
        id: 'low_battery',
        name: 'Low Battery Alert',
        type: TriggerType.battery,
        condition: 'below',
        threshold: 20,
        actions: [
          TriggerAction(
            type: ActionType.speak,
            message: 'Sir, battery 20% se neeche aa gayi. Charger laga do.',
          ),
          TriggerAction(
            type: ActionType.notify,
            title: 'Low Battery',
            message: 'Battery is below 20%',
          ),
        ],
        isActive: true,
      ),
      Trigger(
        id: 'charging_started',
        name: 'Charging Started',
        type: TriggerType.battery,
        condition: 'charging_started',
        actions: [
          TriggerAction(
            type: ActionType.speak,
            message: 'Sir, charging shuru ho gayi.',
          ),
        ],
        isActive: true,
      ),
      Trigger(
        id: 'wifi_connected',
        name: 'WiFi Connected',
        type: TriggerType.connectivity,
        connectivityType: 'wifi',
        condition: 'connect',
        actions: [
          TriggerAction(
            type: ActionType.speak,
            message: 'Sir, WiFi connected.',
          ),
        ],
        isActive: true,
      ),
      Trigger(
        id: 'night_mode',
        name: 'Night Mode',
        type: TriggerType.time,
        timeValue: '23:00',
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        actions: [
          TriggerAction(
            type: ActionType.deviceControl,
            deviceAction: 'dnd_on',
          ),
          TriggerAction(
            type: ActionType.speak,
            message: 'Sir, raat ho gayi. DND on kar raha hu.',
          ),
        ],
        isActive: true,
      ),
    ];
  }
  
  Future<void> _saveTriggers() async {
    // Save to database
  }
  
  void dispose() {
    _timeChecker?.cancel();
    _batteryChecker?.cancel();
    _triggerStream.close();
  }
}

class Trigger {
  final String id;
  final String name;
  final TriggerType type;
  final String? condition;
  final int? threshold;
  final String? timeValue;
  final List<int>? daysOfWeek;
  final TriggerLocation? location;
  final double? radius;
  final String? connectivityType;
  final String? appName;
  final String? notificationKeyword;
  final String? voiceCommand;
  final List<TriggerAction> actions;
  bool isActive;
  final DateTime createdAt;
  
  Trigger({
    required this.id,
    required this.name,
    required this.type,
    this.condition,
    this.threshold,
    this.timeValue,
    this.daysOfWeek,
    this.location,
    this.radius,
    this.connectivityType,
    this.appName,
    this.notificationKeyword,
    this.voiceCommand,
    required this.actions,
    this.isActive = true,
    required this.createdAt,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'condition': condition,
      'threshold': threshold,
      'timeValue': timeValue,
      'daysOfWeek': daysOfWeek,
      'location': location?.toJson(),
      'radius': radius,
      'connectivityType': connectivityType,
      'appName': appName,
      'notificationKeyword': notificationKeyword,
      'voiceCommand': voiceCommand,
      'actions': actions.map((a) => a.toJson()).toList(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  factory Trigger.fromJson(Map<String, dynamic> json) {
    return Trigger(
      id: json['id'],
      name: json['name'],
      type: TriggerType.values[json['type']],
      condition: json['condition'],
      threshold: json['threshold'],
      timeValue: json['timeValue'],
      daysOfWeek: json['daysOfWeek'] != null 
          ? List<int>.from(json['daysOfWeek']) 
          : null,
      location: json['location'] != null 
          ? TriggerLocation.fromJson(json['location']) 
          : null,
      radius: json['radius']?.toDouble(),
      connectivityType: json['connectivityType'],
      appName: json['appName'],
      notificationKeyword: json['notificationKeyword'],
      voiceCommand: json['voiceCommand'],
      actions: (json['actions'] as List)
          .map((a) => TriggerAction.fromJson(a))
          .toList(),
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class TriggerLocation {
  final String name;
  final double latitude;
  final double longitude;
  final String? address;
  
  TriggerLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
  
  factory TriggerLocation.fromJson(Map<String, dynamic> json) {
    return TriggerLocation(
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
    );
  }
}

class TriggerAction {
  final ActionType type;
  final String? message;
  final String? title;
  final String? routineName;
  final String? contact;
  final String? deviceAction;
  final String? deviceValue;
  final String? triggerId;
  
  TriggerAction({
    required this.type,
    this.message,
    this.title,
    this.routineName,
    this.contact,
    this.deviceAction,
    this.deviceValue,
    this.triggerId,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'message': message,
      'title': title,
      'routineName': routineName,
      'contact': contact,
      'deviceAction': deviceAction,
      'deviceValue': deviceValue,
      'triggerId': triggerId,
    };
  }
  
  factory TriggerAction.fromJson(Map<String, dynamic> json) {
    return TriggerAction(
      type: ActionType.values[json['type']],
      message: json['message'],
      title: json['title'],
      routineName: json['routineName'],
      contact: json['contact'],
      deviceAction: json['deviceAction'],
      deviceValue: json['deviceValue'],
      triggerId: json['triggerId'],
    );
  }
}

enum ActionType {
  speak,
  notify,
  runRoutine,
  sendMessage,
  makeCall,
  deviceControl,
  triggerOther,
}

class TriggerEvent {
  final String triggerId;
  final String triggerName;
  final TriggerType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  
  TriggerEvent({
    required this.triggerId,
    required this.triggerName,
    required this.type,
    required this.data,
    required this.timestamp,
  });
  
  String getFormattedTime() {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }
}