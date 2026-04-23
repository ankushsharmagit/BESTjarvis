// lib/models/routine_model.dart
// Automation Routine Model

import 'package:flutter/material.dart';

class Routine {
  final String id;
  final String name;
  final String description;
  final List<RoutineAction> actions;
  final RoutineTrigger trigger;
  final DateTime createdAt;
  DateTime? lastExecuted;
  bool isActive;
  int executionCount;
  final RoutineType type;
  final String? icon;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  
  Routine({
    required this.id,
    required this.name,
    required this.description,
    required this.actions,
    required this.trigger,
    required this.createdAt,
    this.lastExecuted,
    this.isActive = true,
    this.executionCount = 0,
    this.type = RoutineType.custom,
    this.icon,
    this.tags = const [],
    this.metadata = const {},
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'actions': actions.map((a) => a.toMap()).toList(),
      'trigger': trigger.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'lastExecuted': lastExecuted?.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'executionCount': executionCount,
      'type': type.index,
      'icon': icon,
      'tags': tags.join(','),
      'metadata': metadata,
    };
  }
  
  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      actions: (map['actions'] as List)
          .map((a) => RoutineAction.fromMap(a))
          .toList(),
      trigger: RoutineTrigger.fromMap(map['trigger']),
      createdAt: DateTime.parse(map['createdAt']),
      lastExecuted: map['lastExecuted'] != null 
          ? DateTime.parse(map['lastExecuted']) 
          : null,
      isActive: map['isActive'] == 1,
      executionCount: map['executionCount'],
      type: RoutineType.values[map['type']],
      icon: map['icon'],
      tags: map['tags']?.split(',') ?? [],
      metadata: map['metadata'] ?? {},
    );
  }
  
  void incrementExecution() {
    executionCount++;
    lastExecuted = DateTime.now();
  }
  
  String getFormattedLastExecuted() {
    if (lastExecuted == null) return 'Never';
    final now = DateTime.now();
    final diff = now.difference(lastExecuted!);
    
    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
  
  String getIcon() {
    if (icon != null) return icon!;
    
    switch (type) {
      case RoutineType.morning:
        return '🌅';
      case RoutineType.night:
        return '🌙';
      case RoutineType.office:
        return '💼';
      case RoutineType.driving:
        return '🚗';
      case RoutineType.gaming:
        return '🎮';
      case RoutineType.study:
        return '📚';
      case RoutineType.meeting:
        return '📹';
      case RoutineType.emergency:
        return '🚨';
      case RoutineType.custom:
        return '⚙️';
    }
  }
}

enum RoutineType {
  morning,
  night,
  office,
  driving,
  gaming,
  study,
  meeting,
  emergency,
  custom,
}

class RoutineAction {
  final String actionType;
  final Map<String, dynamic> parameters;
  final int delayMs;
  final String? condition;
  final bool isConditional;
  
  RoutineAction({
    required this.actionType,
    required this.parameters,
    this.delayMs = 0,
    this.condition,
    this.isConditional = false,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'actionType': actionType,
      'parameters': parameters,
      'delayMs': delayMs,
      'condition': condition,
      'isConditional': isConditional,
    };
  }
  
  factory RoutineAction.fromMap(Map<String, dynamic> map) {
    return RoutineAction(
      actionType: map['actionType'],
      parameters: map['parameters'],
      delayMs: map['delayMs'],
      condition: map['condition'],
      isConditional: map['isConditional'] ?? false,
    );
  }
  
  bool shouldExecute(Map<String, dynamic> context) {
    if (!isConditional || condition == null) return true;
    
    // Parse condition like "battery > 20" or "time > 22:00"
    try {
      // Simple condition parser
      if (condition!.contains('battery')) {
        final batteryLevel = context['batteryLevel'] ?? 0;
        if (condition!.contains('>')) {
          final threshold = int.parse(condition!.split('>')[1].trim());
          return batteryLevel > threshold;
        } else if (condition!.contains('<')) {
          final threshold = int.parse(condition!.split('<')[1].trim());
          return batteryLevel < threshold;
        }
      }
      
      if (condition!.contains('time')) {
        final currentTime = DateTime.now();
        // Parse time condition like "time > 22:00"
        final timeStr = condition!.split(' ')[2];
        final parts = timeStr.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final conditionTime = DateTime(currentTime.year, currentTime.month, currentTime.day, hour, minute);
        
        if (condition!.contains('>')) {
          return currentTime.isAfter(conditionTime);
        } else if (condition!.contains('<')) {
          return currentTime.isBefore(conditionTime);
        }
      }
    } catch (e) {
      return true;
    }
    
    return true;
  }
}

class RoutineTrigger {
  final TriggerType type;
  final String? timeOfDay;
  final List<int>? daysOfWeek;
  final String? locationId;
  final double? latitude;
  final double? longitude;
  final double? radius;
  final String? voiceCommand;
  final int? batteryLevel;
  final String? connectivityType;
  final String? appName;
  final String? notificationKeyword;
  final bool? isRecurring;
  final DateTime? endDate;
  final int? repeatInterval;
  
  RoutineTrigger({
    required this.type,
    this.timeOfDay,
    this.daysOfWeek,
    this.locationId,
    this.latitude,
    this.longitude,
    this.radius,
    this.voiceCommand,
    this.batteryLevel,
    this.connectivityType,
    this.appName,
    this.notificationKeyword,
    this.isRecurring,
    this.endDate,
    this.repeatInterval,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'type': type.index,
      'timeOfDay': timeOfDay,
      'daysOfWeek': daysOfWeek,
      'locationId': locationId,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'voiceCommand': voiceCommand,
      'batteryLevel': batteryLevel,
      'connectivityType': connectivityType,
      'appName': appName,
      'notificationKeyword': notificationKeyword,
      'isRecurring': isRecurring,
      'endDate': endDate?.toIso8601String(),
      'repeatInterval': repeatInterval,
    };
  }
  
  factory RoutineTrigger.fromMap(Map<String, dynamic> map) {
    return RoutineTrigger(
      type: TriggerType.values[map['type']],
      timeOfDay: map['timeOfDay'],
      daysOfWeek: map['daysOfWeek'] != null 
          ? List<int>.from(map['daysOfWeek']) 
          : null,
      locationId: map['locationId'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      radius: map['radius'],
      voiceCommand: map['voiceCommand'],
      batteryLevel: map['batteryLevel'],
      connectivityType: map['connectivityType'],
      appName: map['appName'],
      notificationKeyword: map['notificationKeyword'],
      isRecurring: map['isRecurring'],
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      repeatInterval: map['repeatInterval'],
    );
  }
  
  bool shouldTrigger(DateTime now, double? currentLat, double? currentLon, 
      int currentBattery, String currentConnectivity, String? currentApp) {
    switch (type) {
      case TriggerType.scheduled:
        if (timeOfDay == null) return false;
        final timeParts = timeOfDay!.split(':');
        if (timeParts.length != 2) return false;
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        
        if (now.hour != hour || now.minute != minute) return false;
        
        if (daysOfWeek != null && daysOfWeek!.isNotEmpty) {
          // Convert DateTime.weekday (Monday=1) to Sunday=0 format
          final weekday = now.weekday % 7;
          return daysOfWeek!.contains(weekday);
        }
        
        if (isRecurring == true && repeatInterval != null) {
          // Check if enough time has passed since last trigger
          // This requires tracking last trigger time separately
          return true;
        }
        
        return true;
        
      case TriggerType.location:
        if (latitude == null || longitude == null || radius == null) return false;
        if (currentLat == null || currentLon == null) return false;
        
        final distance = _calculateDistance(
          latitude!, longitude!, 
          currentLat, currentLon
        );
        return distance <= radius!;
        
      case TriggerType.voice:
        return false;
        
      case TriggerType.battery:
        if (batteryLevel == null) return false;
        return currentBattery <= batteryLevel!;
        
      case TriggerType.connectivity:
        if (connectivityType == null) return false;
        return currentConnectivity == connectivityType;
        
      case TriggerType.app:
        if (appName == null) return false;
        return currentApp?.contains(appName!) ?? false;
        
      case TriggerType.notification:
        if (notificationKeyword == null) return false;
        // Notification trigger handled separately
        return false;
        
      case TriggerType.manual:
        return false;
    }
  }
  
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000;
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
  
  String getTriggerDescription() {
    switch (type) {
      case TriggerType.scheduled:
        if (timeOfDay != null) {
          String desc = 'Daily at $timeOfDay';
          if (daysOfWeek != null && daysOfWeek!.isNotEmpty) {
            final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
            final days = daysOfWeek!.map((d) => dayNames[d]).join(', ');
            desc = '$desc on $days';
          }
          return desc;
        }
        return 'Scheduled';
      case TriggerType.location:
        return 'Location based';
      case TriggerType.voice:
        return 'Voice command: "$voiceCommand"';
      case TriggerType.battery:
        return 'Battery ≤ $batteryLevel%';
      case TriggerType.connectivity:
        return 'Network: $connectivityType';
      case TriggerType.app:
        return 'When $appName opens';
      case TriggerType.notification:
        return 'When notification contains "$notificationKeyword"';
      case TriggerType.manual:
        return 'Manual only';
    }
  }
}

enum TriggerType {
  scheduled,
  location,
  voice,
  battery,
  connectivity,
  app,
  notification,
  manual,
}

class PrebuiltRoutines {
  static Routine getMorningRoutine() {
    return Routine(
      id: 'morning_default',
      name: 'Good Morning',
      description: 'Start your day with energy and information',
      icon: '🌅',
      actions: [
        RoutineAction(
          actionType: 'dnd_off',
          parameters: {},
          delayMs: 0,
        ),
        RoutineAction(
          actionType: 'set_brightness',
          parameters: {'mode': 'auto'},
          delayMs: 500,
        ),
        RoutineAction(
          actionType: 'wifi_on',
          parameters: {},
          delayMs: 500,
        ),
        RoutineAction(
          actionType: 'speak',
          parameters: {
            'message': 'Good morning Mukul Sir! Let me get your day ready.'
          },
          delayMs: 1000,
        ),
        RoutineAction(
          actionType: 'weather_report',
          parameters: {},
          delayMs: 2000,
        ),
        RoutineAction(
          actionType: 'calendar_events',
          parameters: {},
          delayMs: 2000,
        ),
        RoutineAction(
          actionType: 'news_headlines',
          parameters: {'count': 3},
          delayMs: 3000,
        ),
        RoutineAction(
          actionType: 'motivational_quote',
          parameters: {},
          delayMs: 2000,
        ),
      ],
      trigger: RoutineTrigger(
        type: TriggerType.scheduled,
        timeOfDay: '06:30',
        daysOfWeek: [1, 2, 3, 4, 5, 6, 0],
        isRecurring: true,
      ),
      createdAt: DateTime.now(),
      type: RoutineType.morning,
      tags: ['daily', 'productivity'],
    );
  }
  
  static Routine getNightRoutine() {
    return Routine(
      id: 'night_default',
      name: 'Good Night',
      description: 'Wind down and prepare for sleep',
      icon: '🌙',
      actions: [
        RoutineAction(
          actionType: 'dnd_on',
          parameters: {},
          delayMs: 0,
        ),
        RoutineAction(
          actionType: 'set_brightness',
          parameters: {'level': 10},
          delayMs: 500,
        ),
        RoutineAction(
          actionType: 'speak',
          parameters: {
            'message': 'Good night Sir! Let me summarize your day.'
          },
          delayMs: 1000,
        ),
        RoutineAction(
          actionType: 'daily_summary',
          parameters: {},
          delayMs: 1500,
        ),
        RoutineAction(
          actionType: 'set_alarm',
          parameters: {'time': '06:30'},
          delayMs: 2000,
        ),
        RoutineAction(
          actionType: 'suggest_blue_light_filter',
          parameters: {},
          delayMs: 1000,
        ),
      ],
      trigger: RoutineTrigger(
        type: TriggerType.scheduled,
        timeOfDay: '23:00',
        daysOfWeek: [1, 2, 3, 4, 5, 6, 0],
        isRecurring: true,
      ),
      createdAt: DateTime.now(),
      type: RoutineType.night,
      tags: ['daily', 'health'],
    );
  }
  
  static Routine getOfficeRoutine() {
    return Routine(
      id: 'office_default',
      name: 'Office Mode',
      description: 'Professional mode for work hours',
      icon: '💼',
      actions: [
        RoutineAction(
          actionType: 'silent_mode',
          parameters: {},
          delayMs: 0,
        ),
        RoutineAction(
          actionType: 'auto_reply',
          parameters: {
            'message': 'In a meeting, will call back shortly'
          },
          delayMs: 500,
        ),
        RoutineAction(
          actionType: 'speak',
          parameters: {
            'message': 'Office mode activated. All notifications silenced.'
          },
          delayMs: 1000,
        ),
        RoutineAction(
          actionType: 'focus_mode',
          parameters: {'block_social_media': true},
          delayMs: 500,
        ),
      ],
      trigger: RoutineTrigger(
        type: TriggerType.location,
        latitude: 0,
        longitude: 0,
        radius: 100,
      ),
      createdAt: DateTime.now(),
      type: RoutineType.office,
      tags: ['work', 'productivity'],
    );
  }
  
  static Routine getDrivingRoutine() {
    return Routine(
      id: 'driving_default',
      name: 'Driving Mode',
      description: 'Safe driving assistance',
      icon: '🚗',
      actions: [
        RoutineAction(
          actionType: 'bluetooth_on',
          parameters: {},
          delayMs: 0,
        ),
        RoutineAction(
          actionType: 'volume_max',
          parameters: {},
          delayMs: 500,
        ),
        RoutineAction(
          actionType: 'auto_answer_calls',
          parameters: {'enabled': true},
          delayMs: 500,
        ),
        RoutineAction(
          actionType: 'read_messages_aloud',
          parameters: {},
          delayMs: 500,
        ),
        RoutineAction(
          actionType: 'speak',
          parameters: {
            'message': 'Driving mode activated. Stay safe on the road Sir!'
          },
          delayMs: 1000,
        ),
        RoutineAction(
          actionType: 'navigation_ready',
          parameters: {},
          delayMs: 500,
        ),
      ],
      trigger: RoutineTrigger(
        type: TriggerType.voice,
        voiceCommand: 'driving mode',
      ),
      createdAt: DateTime.now(),
      type: RoutineType.driving,
      tags: ['safety', 'travel'],
    );
  }
  
  static Routine getGamingRoutine() {
    return Routine(
      id: 'gaming_default',
      name: 'Gaming Mode',
      description: 'Optimize phone for gaming',
      icon: '🎮',
      actions: [
        RoutineAction(
          actionType: 'dnd_on',
          parameters: {},
          delayMs: 0,
        ),
        RoutineAction(
          actionType: 'set_brightness',
          parameters: {'level': 100},
          delayMs: 500,
        ),
        RoutineAction(
          actionType: 'kill_background_apps',
          parameters: {},
          delayMs: 500,
        ),
        RoutineAction(
          actionType: 'free_ram',
          parameters: {},
          delayMs: 500,
        ),
        RoutineAction(
          actionType: 'performance_mode',
          parameters: {},
          delayMs: 500,
        ),
        RoutineAction(
          actionType: 'speak',
          parameters: {
            'message': 'Gaming mode activated! Let\'s go Sir! 🎮'
          },
          delayMs: 1000,
        ),
      ],
      trigger: RoutineTrigger(
        type: TriggerType.voice,
        voiceCommand: 'gaming mode',
      ),
      createdAt: DateTime.now(),
      type: RoutineType.gaming,
      tags: ['gaming', 'performance'],
    );
  }
  
  static Routine getStudyRoutine() {
    return Routine(
      id: 'study_default',
      name: 'Study Mode',
      description: 'Focus mode for studying',
      icon: '📚',
      actions: [
        RoutineAction(
          actionType: 'dnd_on',
          parameters: {},
          delayMs: 0,
        ),
        RoutineAction(
          actionType: 'block_apps',
          parameters: {
            'apps': ['instagram', 'facebook', 'twitter', 'youtube', 'tiktok']
          },
          delayMs: 500,
        ),
        RoutineAction(
          actionType: 'set_timer',
          parameters: {'duration': 60, 'mode': 'pomodoro'},
          delayMs: 500,
        ),
        RoutineAction(
          actionType: 'play_focus_music',
          parameters: {},
          delayMs: 500,
        ),
        RoutineAction(
          actionType: 'speak',
          parameters: {
            'message': 'Study mode activated. Social media blocked. Focus time!'
          },
          delayMs: 1000,
        ),
      ],
      trigger: RoutineTrigger(
        type: TriggerType.voice,
        voiceCommand: 'study mode',
      ),
      createdAt: DateTime.now(),
      type: RoutineType.study,
      tags: ['education', 'focus'],
    );
  }
  
  static Routine getEmergencyRoutine() {
    return Routine(
      id: 'emergency_default',
      name: 'Emergency Mode',
      description: 'Emergency protocol activation',
      icon: '🚨',
      actions: [
        RoutineAction(
          actionType: 'send_location',
          parameters: {'contacts': 'emergency'},
          delayMs: 0,
        ),
        RoutineAction(
          actionType: 'flashlight_sos',
          parameters: {},
          delayMs: 500,
        ),
        RoutineAction(
          actionType: 'start_recording',
          parameters: {},
          delayMs: 500,
        ),
        RoutineAction(
          actionType: 'call_emergency',
          parameters: {'number': '100'},
          delayMs: 1000,
        ),
        RoutineAction(
          actionType: 'speak',
          parameters: {
            'message': 'Emergency protocol activated. Location shared with emergency contacts.'
          },
          delayMs: 500,
        ),
      ],
      trigger: RoutineTrigger(
        type: TriggerType.voice,
        voiceCommand: 'emergency',
      ),
      createdAt: DateTime.now(),
      type: RoutineType.emergency,
      tags: ['safety', 'urgent'],
    );
  }
  
  static List<Routine> getAllPrebuilt() {
    return [
      getMorningRoutine(),
      getNightRoutine(),
      getOfficeRoutine(),
      getDrivingRoutine(),
      getGamingRoutine(),
      getStudyRoutine(),
      getEmergencyRoutine(),
    ];
  }
}