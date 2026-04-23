// lib/services/automation/routine_service.dart
// Smart Automation Routine Service

import 'dart:async';
import '../../models/routine_model.dart';
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';
import '../device/device_control.dart';
import '../device/app_manager.dart';
import '../communication/sms_service.dart';
import '../voice/text_to_speech_service.dart';
import '../media/media_control.dart';

class RoutineService {
  static final RoutineService _instance = RoutineService._internal();
  factory RoutineService() => _instance;
  RoutineService._internal();
  
  final List<Routine> _routines = [];
  Timer? _schedulerTimer;
  Timer? _triggerCheckTimer;
  
  final DeviceControlService _deviceControl = DeviceControlService();
  final AppManagerService _appManager = AppManagerService();
  final SmsService _smsService = SmsService();
  final TextToSpeechService _ttsService = TextToSpeechService();
  final MediaControlService _mediaControl = MediaControlService();
  
  final Map<String, DateTime> _lastTriggered = {};
  
  Future<void> initialize() async {
    try {
      await _loadRoutines();
      _startScheduler();
      _startTriggerChecker();
      Logger().info('Routine service initialized with ${_routines.length} routines', tag: 'ROUTINE');
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'Routine Init');
    }
  }
  
  Future<void> _loadRoutines() async {
    // Load from database
    // For now, add default routines
    _routines.addAll([
      PrebuiltRoutines.getMorningRoutine(),
      PrebuiltRoutines.getNightRoutine(),
      PrebuiltRoutines.getOfficeRoutine(),
      PrebuiltRoutines.getDrivingRoutine(),
      PrebuiltRoutines.getGamingRoutine(),
      PrebuiltRoutines.getStudyRoutine(),
      PrebuiltRoutines.getEmergencyRoutine(),
    ]);
  }
  
  void _startScheduler() {
    _schedulerTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkScheduledRoutines();
    });
  }
  
  void _startTriggerChecker() {
    _triggerCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkConditionalTriggers();
    });
  }
  
  Future<void> _checkScheduledRoutines() async {
    final now = DateTime.now();
    
    for (var routine in _routines) {
      if (!routine.isActive) continue;
      
      if (routine.trigger.type == TriggerType.scheduled) {
        if (routine.trigger.shouldTrigger(now, null, null, 0, '')) {
          // Check if already triggered today
          final lastTriggerKey = '${routine.id}_${now.day}_${now.month}_${now.year}';
          if (!_lastTriggered.containsKey(lastTriggerKey)) {
            await executeRoutine(routine);
            _lastTriggered[lastTriggerKey] = now;
            
            // Clean old triggers after 24 hours
            _cleanOldTriggers();
          }
        }
      }
    }
  }
  
  Future<void> _checkConditionalTriggers() async {
    // Get current conditions
    final batteryInfo = await _deviceControl.getBatteryInfo();
    final connectivity = await _deviceControl.getConnectivityInfo();
    final currentApp = await _getCurrentApp();
    
    for (var routine in _routines) {
      if (!routine.isActive) continue;
      
      final shouldTrigger = routine.trigger.shouldTrigger(
        DateTime.now(),
        null, null,
        batteryInfo['level'],
        connectivity['type'],
        currentApp,
      );
      
      if (shouldTrigger) {
        final lastTriggerKey = '${routine.id}_${DateTime.now().day}_${DateTime.now().month}';
        if (!_lastTriggered.containsKey(lastTriggerKey)) {
          await executeRoutine(routine);
          _lastTriggered[lastTriggerKey] = DateTime.now();
        }
      }
    }
  }
  
  Future<String?> _getCurrentApp() async {
    // Get currently running app
    return null;
  }
  
  void _cleanOldTriggers() {
    final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));
    _lastTriggered.removeWhere((key, value) => value.isBefore(oneDayAgo));
  }
  
  Future<void> executeRoutine(Routine routine) async {
    try {
      Logger().info('Executing routine: ${routine.name}', tag: 'ROUTINE');
      
      for (var action in routine.actions) {
        if (action.delayMs > 0) {
          await Future.delayed(Duration(milliseconds: action.delayMs));
        }
        
        await _executeAction(action);
      }
      
      routine.incrementExecution();
      await _saveRoutines();
      Logger().info('Routine completed: ${routine.name}', tag: 'ROUTINE');
      
      // Speak completion if needed
      await _ttsService.speak('${routine.name} routine completed, Sir.');
      
    } catch (e) {
      Logger().error('Routine execution error: ${routine.name}', tag: 'ROUTINE', error: e);
    }
  }
  
  Future<void> _executeAction(RoutineAction action) async {
    switch (action.actionType) {
      case 'speak':
        final message = action.parameters['message'] as String?;
        if (message != null) {
          await _ttsService.speak(message);
        }
        break;
        
      case 'dnd_on':
        await _deviceControl.setDndMode(true);
        break;
        
      case 'dnd_off':
        await _deviceControl.setDndMode(false);
        break;
        
      case 'silent_mode':
        await _deviceControl.muteVolume();
        break;
        
      case 'set_brightness':
        final level = action.parameters['level'] as double?;
        if (level != null) {
          await _deviceControl.setBrightness(level / 100);
        } else if (action.parameters['mode'] == 'auto') {
          await _deviceControl.setAutoBrightness();
        }
        break;
        
      case 'wifi_on':
        await _deviceControl.openWifiSettings();
        break;
        
      case 'wifi_off':
        // Disable WiFi
        break;
        
      case 'bluetooth_on':
        await _deviceControl.openBluetoothSettings();
        break;
        
      case 'volume_max':
        await _deviceControl.setVolume(1.0);
        break;
        
      case 'volume_normal':
        await _deviceControl.setVolume(0.5);
        break;
        
      case 'set_alarm':
        final time = action.parameters['time'] as String?;
        if (time != null) {
          // Set alarm using AlarmManager
        }
        break;
        
      case 'auto_reply':
        final message = action.parameters['message'] as String?;
        if (message != null) {
          // Enable auto-reply with message
        }
        break;
        
      case 'weather_report':
        // Get and speak weather
        break;
        
      case 'calendar_events':
        // Get and speak calendar events
        break;
        
      case 'news_headlines':
        final count = action.parameters['count'] as int? ?? 3;
        // Get and speak news
        break;
        
      case 'daily_summary':
        // Speak daily summary
        break;
        
      case 'motivational_quote':
        // Speak motivational quote
        await _ttsService.speak('Stay focused and keep pushing forward, Sir! 💪');
        break;
        
      case 'suggest_blue_light_filter':
        await _ttsService.speak('Sir, blue light filter laga du? Aankhon ke liye accha rahega.');
        break;
        
      case 'kill_background_apps':
        await _appManager.killBackgroundApps();
        break;
        
      case 'free_ram':
        await _appManager.killBackgroundApps();
        break;
        
      case 'auto_answer_calls':
        final enabled = action.parameters['enabled'] as bool? ?? true;
        // Enable/disable auto-answer
        break;
        
      case 'read_messages_aloud':
        // Enable reading messages aloud
        break;
        
      case 'play_focus_music':
        await _mediaControl.play();
        break;
        
      case 'block_apps':
        final apps = action.parameters['apps'] as List<String>?;
        if (apps != null) {
          // Block specified apps
        }
        break;
        
      case 'set_timer':
        final duration = action.parameters['duration'] as int? ?? 60;
        final mode = action.parameters['mode'] as String? ?? 'standard';
        // Set timer
        await _ttsService.speak('Setting timer for $duration minutes in $mode mode.');
        break;
        
      case 'navigation_ready':
        // Open navigation app
        break;
        
      case 'performance_mode':
        // Enable performance mode
        break;
        
      case 'focus_mode':
        final blockSocial = action.parameters['block_social_media'] as bool? ?? false;
        if (blockSocial) {
          // Block social media apps
        }
        break;
        
      case 'send_location':
        final contacts = action.parameters['contacts'] as String?;
        // Send location to emergency contacts
        break;
        
      case 'flashlight_sos':
        await _deviceControl.flashlightSOS();
        break;
        
      case 'start_recording':
        // Start audio/video recording
        break;
        
      case 'call_emergency':
        final number = action.parameters['number'] as String? ?? '100';
        // Call emergency number
        break;
        
      default:
        Logger().warning('Unknown action type: ${action.actionType}', tag: 'ROUTINE');
    }
  }
  
  Future<void> addRoutine(Routine routine) async {
    _routines.add(routine);
    await _saveRoutines();
    Logger().info('Added routine: ${routine.name}', tag: 'ROUTINE');
  }
  
  Future<void> removeRoutine(String routineId) async {
    _routines.removeWhere((r) => r.id == routineId);
    await _saveRoutines();
    Logger().info('Removed routine: $routineId', tag: 'ROUTINE');
  }
  
  Future<void> updateRoutine(Routine routine) async {
    final index = _routines.indexWhere((r) => r.id == routine.id);
    if (index != -1) {
      _routines[index] = routine;
      await _saveRoutines();
      Logger().info('Updated routine: ${routine.name}', tag: 'ROUTINE');
    }
  }
  
  List<Routine> getRoutines() {
    return List.unmodifiable(_routines);
  }
  
  List<Routine> getActiveRoutines() {
    return _routines.where((r) => r.isActive).toList();
  }
  
  Future<void> _saveRoutines() async {
    // Save to database
  }
  
  Future<Routine?> getRoutine(String id) async {
    try {
      return _routines.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }
  
  Future<void> executeRoutineByName(String name) async {
    final routine = _routines.firstWhere(
      (r) => r.name.toLowerCase() == name.toLowerCase(),
      orElse: () => _routines.firstWhere(
        (r) => r.name.toLowerCase().contains(name.toLowerCase()),
        orElse: () => throw Exception('Routine not found'),
      ),
    );
    
    await executeRoutine(routine);
  }
  
  List<String> getRoutineNames() {
    return _routines.map((r) => r.name).toList();
  }
  
  Future<Map<String, dynamic>> getRoutineStats() async {
    int totalExecutions = 0;
    for (var routine in _routines) {
      totalExecutions += routine.executionCount;
    }
    
    return {
      'totalRoutines': _routines.length,
      'activeRoutines': getActiveRoutines().length,
      'totalExecutions': totalExecutions,
      'mostExecuted': _routines.isNotEmpty 
          ? _routines.reduce((a, b) => a.executionCount > b.executionCount ? a : b).name
          : 'None',
      'lastExecuted': _routines.where((r) => r.lastExecuted != null)
          .map((r) => r.lastExecuted!)
          .fold(null, (a, b) => a == null || b.isAfter(a) ? b : a),
    };
  }
  
  void dispose() {
    _schedulerTimer?.cancel();
    _triggerCheckTimer?.cancel();
  }
}

class CustomRoutineBuilder {
  String name = '';
  String description = '';
  final List<RoutineAction> actions = [];
  RoutineTrigger? trigger;
  String? icon;
  List<String> tags = [];
  
  void addAction(String actionType, Map<String, dynamic> parameters, {int delayMs = 0}) {
    actions.add(RoutineAction(
      actionType: actionType,
      parameters: parameters,
      delayMs: delayMs,
    ));
  }
  
  void removeAction(int index) {
    if (index < actions.length) {
      actions.removeAt(index);
    }
  }
  
  void setTrigger(TriggerType type, {String? timeOfDay, List<int>? daysOfWeek, String? voiceCommand}) {
    trigger = RoutineTrigger(
      type: type,
      timeOfDay: timeOfDay,
      daysOfWeek: daysOfWeek,
      voiceCommand: voiceCommand,
    );
  }
  
  Routine build() {
    return Routine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      actions: actions,
      trigger: trigger ?? RoutineTrigger(type: TriggerType.manual),
      createdAt: DateTime.now(),
      icon: icon,
      tags: tags,
    );
  }
  
  void reset() {
    name = '';
    description = '';
    actions.clear();
    trigger = null;
    icon = null;
    tags.clear();
  }
}