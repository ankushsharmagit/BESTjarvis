// lib/services/core/command_parser.dart
// Advanced Natural Language Command Parser

import '../../utils/logger.dart';
import '../../config/constants.dart';

class CommandParser {
  static final CommandParser _instance = CommandParser._internal();
  factory CommandParser() => _instance;
  CommandParser._internal();
  
  final Map<String, List<String>> _commandPatterns = {};
  final Map<String, CommandTemplate> _commandTemplates = {};
  
  void initialize() {
    _buildCommandPatterns();
    _buildCommandTemplates();
    Logger().info('Command parser initialized', tag: 'PARSER');
  }
  
  void _buildCommandPatterns() {
    // Device Control Patterns
    _commandPatterns['flashlight_on'] = [
      'flash on', 'flashlight on', 'torch on', 'light on',
      'flash jala', 'torch jala', 'roshni karo', 'light chalu',
      'flash chalu', 'torch chalu', 'light on karo', 'flash on kar',
      'torch on kar', 'andhera hatao', 'light daal', 'flashlight jala',
      'torch jala do', 'roshni kar do', 'light on kar do bhai',
    ];
    
    _commandPatterns['flashlight_off'] = [
      'flash off', 'flashlight off', 'torch off', 'light off',
      'flash band', 'torch band', 'andhera karo', 'light band',
      'flash bujha', 'torch bujha', 'light off kar', 'roshni band',
      'torch off kar', 'flashlight band', 'light hatao', 'roshni hatao',
    ];
    
    _commandPatterns['volume_up'] = [
      'volume up', 'volume badhao', 'awaz badhao', 'volume increase',
      'tez karo', 'awaz tez karo', 'volume plus', 'sound up',
      'awaz barhao', 'volume barhao', 'thoda tez karo', 'awaz badha do',
    ];
    
    _commandPatterns['volume_down'] = [
      'volume down', 'volume kam karo', 'awaz kam karo', 'volume decrease',
      'dheere karo', 'awaz dheere karo', 'volume minus', 'sound down',
      'awaz ghatayo', 'volume ghatayo', 'thoda dheere karo',
    ];
    
    _commandPatterns['volume_mute'] = [
      'mute', 'volume mute', 'awaz band', 'silent karo', 'chup karo',
      'mute kar', 'awaz rok', 'sound off', 'no sound', 'awaz band kar',
    ];
    
    _commandPatterns['brightness_up'] = [
      'brightness up', 'brightness badhao', 'roshni badhao', 'screen bright',
      'display bright', 'brightness increase', 'roshni barhao',
      'screen tez karo', 'display tez karo',
    ];
    
    _commandPatterns['brightness_down'] = [
      'brightness down', 'brightness kam', 'roshni kam', 'screen dim',
      'display dim', 'brightness decrease', 'roshni ghatayo',
      'screen dheere karo', 'display dheere karo',
    ];
    
    // Communication Patterns
    _commandPatterns['call'] = [
      'call', 'phone karo', 'call karo', 'ring karo', 'dial',
      'phone lagao', 'contact karo', 'baat karo', 'phone milao',
      'ring maro', 'call maro', 'phone pe baat karo',
    ];
    
    _commandPatterns['message'] = [
      'message', 'sms', 'text', 'msg', 'bhejo', 'send', 'message kar',
      'text kar', 'whatsapp kar', 'sms kar', 'text bhejo',
    ];
    
    _commandPatterns['whatsapp'] = [
      'whatsapp', 'wa', 'whatsapp message', 'whatsapp kar', 'wp',
    ];
    
    _commandPatterns['telegram'] = [
      'telegram', 'tg', 'telegram message', 'telegram kar',
    ];
    
    // App Control Patterns
    _commandPatterns['open_app'] = [
      'open', 'kholo', 'chalao', 'start', 'launch', 'khole',
      'open kar', 'khol do', 'chala do', 'start kar', 'launch kar',
    ];
    
    _commandPatterns['close_app'] = [
      'close', 'band karo', 'stop', 'kill', 'exit', 'band kar',
      'close kar', 'stop kar', 'kill kar', 'exit kar',
    ];
    
    // Media Patterns
    _commandPatterns['play_music'] = [
      'play music', 'gaana chalao', 'music start', 'song bajao',
      'music play', 'gaana bajao', 'song play', 'music shuru karo',
      'gaana shuru karo', 'song shuru karo',
    ];
    
    _commandPatterns['pause_music'] = [
      'pause music', 'gaana rok', 'music pause', 'song stop',
      'gaana band', 'music stop', 'gaana roko', 'song roko',
    ];
    
    _commandPatterns['next_song'] = [
      'next song', 'agala gaana', 'next track', 'skip', 'agaala gaana',
      'next music', 'agala song', 'agaala song',
    ];
    
    _commandPatterns['previous_song'] = [
      'previous song', 'pichla gaana', 'previous track', 'back',
      'pichla gaana chalao', 'pichla song',
    ];
    
    // Camera Patterns
    _commandPatterns['take_photo'] = [
      'photo', 'photo le', 'picture', 'click photo', 'selfie',
      'photo khicho', 'picture lo', 'selfie lo', 'photo click karo',
    ];
    
    _commandPatterns['record_video'] = [
      'video record', 'video banao', 'record video', 'video shoot',
      'video recording start', 'video start karo',
    ];
    
    // System Patterns
    _commandPatterns['restart'] = [
      'restart phone', 'phone restart', 'reboot', 'system restart',
      'phone band karke chalu karo', 'restart kar', 'reboot kar',
    ];
    
    _commandPatterns['screenshot'] = [
      'screenshot', 'screen capture', 'screenshot lo', 'photo le screen ki',
      'capture screen', 'screen shot le', 'screen capture kar',
    ];
    
    // Information Patterns
    _commandPatterns['time'] = [
      'time', 'kya time hai', 'current time', 'samay kya hai',
      'time batao', 'ghanti kya hai', 'kya baj rahe hain',
    ];
    
    _commandPatterns['date'] = [
      'date', 'aaj ka din', 'kya date hai', 'today date',
      'date batao', 'konsa din hai', 'aaj ki tarikh',
    ];
    
    _commandPatterns['weather'] = [
      'weather', 'mausam', 'temperature', 'temperature kya hai',
      'mausam kaisa hai', 'kya mausam hai', 'weather update',
      'mausam kya hai', 'bahar kitni thand hai',
    ];
    
    _commandPatterns['news'] = [
      'news', 'khabar', 'latest news', 'headlines', 'news sunao',
      'aaj ki khabar', 'top news', 'breaking news',
    ];
    
    _commandPatterns['battery'] = [
      'battery', 'battery percentage', 'kitni battery hai',
      'battery status', 'charge kaisa hai', 'battery check',
      'kitna charge hai', 'battery kitni bachi hai',
    ];
    
    // Security Patterns
    _commandPatterns['vault'] = [
      'vault', 'private vault', 'my vault', 'secure folder', 'hidden files',
      'vault kholo', 'private files', 'secret folder', 'vault open karo',
    ];
    
    _commandPatterns['lockdown'] = [
      'lockdown', 'emergency', 'secure phone', 'lock everything',
      'emergency mode', 'lockdown mode', 'secure karo',
    ];
    
    // Routine Patterns
    _commandPatterns['good_morning'] = [
      'good morning', 'gm', 'subah ho gayi', 'morning routine',
      'subah ki shuruaat', 'day start', 'good morning jarvis',
    ];
    
    _commandPatterns['good_night'] = [
      'good night', 'gn', 'raat ho gayi', 'night routine',
      'sona hai', 'sleep time', 'good night jarvis',
    ];
    
    // Social Media Patterns
    _commandPatterns['instagram'] = [
      'instagram', 'ig', 'insta', 'instagram post', 'instagram story',
    ];
    
    _commandPatterns['twitter'] = [
      'twitter', 'x', 'tweet', 'twitter post', 'tweet karo',
    ];
    
    _commandPatterns['facebook'] = [
      'facebook', 'fb', 'meta', 'facebook post', 'fb post',
    ];
    
    // Cleanup Patterns
    _commandPatterns['cleanup'] = [
      'clean', 'saaf karo', 'cleanup', 'phone saaf', 'junk delete',
      'cache clear', 'temp delete', 'phone clean', 'phone saaf kar',
    ];
    
    // Help Patterns
    _commandPatterns['help'] = [
      'help', 'madad', 'kya kar sakta', 'what can you do',
      'capabilities', 'commands', 'help me', 'guide',
    ];
  }
  
  void _buildCommandTemplates() {
    _commandTemplates['call'] = CommandTemplate(
      name: 'call',
      patterns: ['call {contact}', 'phone karo {contact}', '{contact} ko call karo'],
      parameters: ['contact'],
      example: 'call Mummy',
    );
    
    _commandTemplates['message'] = CommandTemplate(
      name: 'message',
      patterns: ['message {contact} {message}', 'send {contact} {message}', '{contact} ko message bhejo {message}'],
      parameters: ['contact', 'message'],
      example: 'message Rahul - Hello, kaise ho?',
    );
    
    _commandTemplates['set_volume'] = CommandTemplate(
      name: 'set_volume',
      patterns: ['volume {percent}%', 'volume set kar {percent}', 'volume {percent} percent karo'],
      parameters: ['percent'],
      example: 'volume 50%',
    );
    
    _commandTemplates['set_brightness'] = CommandTemplate(
      name: 'set_brightness',
      patterns: ['brightness {percent}%', 'brightness set kar {percent}', 'brightness {percent} percent karo'],
      parameters: ['percent'],
      example: 'brightness 80%',
    );
    
    _commandTemplates['reminder'] = CommandTemplate(
      name: 'reminder',
      patterns: ['remind me {time} to {task}', '{time} par {task} yaad dilao', 'reminder set {time} {task}'],
      parameters: ['time', 'task'],
      example: 'remind me 3 PM to call doctor',
    );
    
    _commandTemplates['alarm'] = CommandTemplate(
      name: 'alarm',
      patterns: ['alarm {time}', 'set alarm for {time}', '{time} ka alarm laga do'],
      parameters: ['time'],
      example: 'alarm 6:30 AM',
    );
  }
  
  ParsedCommand parseCommand(String rawCommand) {
    final lowerCommand = rawCommand.toLowerCase().trim();
    
    // Check each pattern category
    for (var entry in _commandPatterns.entries) {
      for (var pattern in entry.value) {
        if (lowerCommand.contains(pattern)) {
          return ParsedCommand(
            type: entry.key,
            originalText: rawCommand,
            confidence: 0.95,
            parameters: _extractParameters(entry.key, rawCommand),
          );
        }
      }
    }
    
    // Check templates for complex commands
    for (var template in _commandTemplates.values) {
      final parsed = _matchTemplate(rawCommand, template);
      if (parsed != null) {
        return parsed;
      }
    }
    
    // Default: treat as AI query
    return ParsedCommand(
      type: 'ai_query',
      originalText: rawCommand,
      confidence: 0.5,
      parameters: {'query': rawCommand},
    );
  }
  
  ParsedCommand? _matchTemplate(String command, CommandTemplate template) {
    for (var pattern in template.patterns) {
      final regex = _patternToRegex(pattern);
      final match = regex.firstMatch(command.toLowerCase());
      
      if (match != null) {
        final parameters = <String, dynamic>{};
        for (var i = 0; i < template.parameters.length; i++) {
          final paramName = template.parameters[i];
          final paramValue = match.group(i + 1);
          if (paramValue != null) {
            parameters[paramName] = paramValue;
          }
        }
        
        return ParsedCommand(
          type: template.name,
          originalText: command,
          confidence: 0.9,
          parameters: parameters,
        );
      }
    }
    return null;
  }
  
  RegExp _patternToRegex(String pattern) {
    var regexPattern = pattern
        .replaceAll('{', '(?<')
        .replaceAll('}', '>\\w+)')
        .replaceAll(' ', '\\s+');
    
    return RegExp('^$regexPattern\$', caseSensitive: false);
  }
  
  Map<String, dynamic> _extractParameters(String commandType, String rawCommand) {
    final params = <String, dynamic>{};
    final lowerCommand = rawCommand.toLowerCase();
    
    switch (commandType) {
      case 'call':
        final contact = _extractContactName(rawCommand);
        if (contact != null) params['contact'] = contact;
        break;
        
      case 'message':
        final contact = _extractContactName(rawCommand);
        final message = _extractMessageContent(rawCommand);
        if (contact != null) params['contact'] = contact;
        if (message != null) params['message'] = message;
        break;
        
      case 'set_volume':
      case 'set_brightness':
        final percent = _extractPercentage(rawCommand);
        if (percent != null) params['percent'] = percent;
        break;
    }
    
    return params;
  }
  
  String? _extractContactName(String command) {
    final patterns = [
      RegExp(r'call\s+(\w+)', caseSensitive: false),
      RegExp(r'message\s+(\w+)', caseSensitive: false),
      RegExp(r'phone\s+(\w+)', caseSensitive: false),
      RegExp(r'(\w+)\s+ko\s+call', caseSensitive: false),
      RegExp(r'(\w+)\s+ko\s+message', caseSensitive: false),
    ];
    
    for (var pattern in patterns) {
      final match = pattern.firstMatch(command);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }
    return null;
  }
  
  String? _extractMessageContent(String command) {
    final patterns = [
      RegExp(r'-\s*(.+)$', caseSensitive: false),
      RegExp(r'"(.*?)"', caseSensitive: false),
      RegExp(r'bolo\s+(.+)$', caseSensitive: false),
      RegExp(r'send\s+(.+)$', caseSensitive: false),
    ];
    
    for (var pattern in patterns) {
      final match = pattern.firstMatch(command);
      if (match != null && match.groupCount >= 1) {
        return match.group(1)?.trim();
      }
    }
    return null;
  }
  
  int? _extractPercentage(String command) {
    final match = RegExp(r'(\d+)%').firstMatch(command);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }
  
  List<String> getCommandSuggestions(String partialCommand) {
    final suggestions = <String>[];
    final lowerPartial = partialCommand.toLowerCase();
    
    for (var entry in _commandPatterns.entries) {
      for (var pattern in entry.value) {
        if (pattern.startsWith(lowerPartial)) {
          suggestions.add(pattern);
          break;
        }
      }
    }
    
    return suggestions.take(5).toList();
  }
  
  bool isCommand(String text) {
    final lowerText = text.toLowerCase();
    for (var patterns in _commandPatterns.values) {
      for (var pattern in patterns) {
        if (lowerText.contains(pattern)) {
          return true;
        }
      }
    }
    return false;
  }
  
  String getCommandCategory(String command) {
    final lowerCommand = command.toLowerCase();
    
    if (_commandPatterns['flashlight_on']!.any((p) => lowerCommand.contains(p)) ||
        _commandPatterns['flashlight_off']!.any((p) => lowerCommand.contains(p))) {
      return 'device';
    }
    
    if (_commandPatterns['call']!.any((p) => lowerCommand.contains(p))) {
      return 'communication';
    }
    
    if (_commandPatterns['message']!.any((p) => lowerCommand.contains(p))) {
      return 'communication';
    }
    
    if (_commandPatterns['open_app']!.any((p) => lowerCommand.contains(p))) {
      return 'app';
    }
    
    if (_commandPatterns['play_music']!.any((p) => lowerCommand.contains(p))) {
      return 'media';
    }
    
    if (_commandPatterns['time']!.any((p) => lowerCommand.contains(p))) {
      return 'info';
    }
    
    if (_commandPatterns['weather']!.any((p) => lowerCommand.contains(p))) {
      return 'info';
    }
    
    if (_commandPatterns['good_morning']!.any((p) => lowerCommand.contains(p)) ||
        _commandPatterns['good_night']!.any((p) => lowerCommand.contains(p))) {
      return 'routine';
    }
    
    return 'general';
  }
}

class ParsedCommand {
  final String type;
  final String originalText;
  final double confidence;
  final Map<String, dynamic> parameters;
  
  ParsedCommand({
    required this.type,
    required this.originalText,
    required this.confidence,
    this.parameters = const {},
  });
  
  bool get isHighConfidence => confidence >= 0.8;
  bool get isMediumConfidence => confidence >= 0.6 && confidence < 0.8;
  bool get isLowConfidence => confidence < 0.6;
  
  @override
  String toString() {
    return 'ParsedCommand(type: $type, confidence: $confidence, params: $parameters)';
  }
}

class CommandTemplate {
  final String name;
  final List<String> patterns;
  final List<String> parameters;
  final String example;
  
  CommandTemplate({
    required this.name,
    required this.patterns,
    required this.parameters,
    required this.example,
  });
}