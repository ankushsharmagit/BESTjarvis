// lib/services/voice/speech_to_text_service.dart
// Speech Recognition Service with Continuous Listening

import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';

class SpeechToTextService {
  static final SpeechToTextService _instance = SpeechToTextService._internal();
  factory SpeechToTextService() => _instance;
  SpeechToTextService._internal();
  
  SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  String _lastRecognizedText = '';
  double _currentSoundLevel = 0.0;
  
  StreamController<String> _recognitionStream = StreamController<String>.broadcast();
  StreamController<bool> _listeningStatusStream = StreamController<bool>.broadcast();
  StreamController<double> _soundLevelStream = StreamController<double>.broadcast();
  
  Stream<String> get recognitionStream => _recognitionStream.stream;
  Stream<bool> get listeningStatusStream => _listeningStatusStream.stream;
  Stream<double> get soundLevelStream => _soundLevelStream.stream;
  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;
  double get currentSoundLevel => _currentSoundLevel;
  String get lastRecognizedText => _lastRecognizedText;
  
  Future<bool> initialize() async {
    try {
      _isAvailable = await _speech.initialize(
        onStatus: (status) {
          Logger().debug('Speech status: $status', tag: 'STT');
          if (status == 'notListening') {
            _isListening = false;
            _listeningStatusStream.add(false);
          } else if (status == 'listening') {
            _isListening = true;
            _listeningStatusStream.add(true);
          }
        },
        onError: (error) {
          Logger().error('Speech error: $error', tag: 'STT');
          _isListening = false;
          _listeningStatusStream.add(false);
        },
      );
      
      if (_isAvailable) {
        Logger().info('Speech recognition initialized successfully', tag: 'STT');
      } else {
        Logger().warning('Speech recognition not available on this device', tag: 'STT');
      }
      
      return _isAvailable;
      
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'STT Init');
      _isAvailable = false;
      return false;
    }
  }
  
  Future<void> startListening({
    String localeId = 'en_IN',
    Duration listenFor = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 2),
    bool partialResults = true,
    bool listenMode = false,
  }) async {
    try {
      if (!_isAvailable) {
        Logger().warning('Speech recognition not available', tag: 'STT');
        await initialize();
        if (!_isAvailable) return;
      }
      
      if (_isListening) {
        await stopListening();
      }
      
      _isListening = true;
      _listeningStatusStream.add(true);
      
      await _speech.listen(
        onResult: (result) => _onSpeechResult(result),
        listenFor: listenFor,
        pauseFor: pauseFor,
        partialResults: partialResults,
        localeId: localeId,
        onSoundLevelChange: (level) {
          _currentSoundLevel = level;
          _soundLevelStream.add(level);
        },
        listenMode: listenMode ? ListenMode.dictation : ListenMode.search,
      );
      
      Logger().debug('Started listening for $listenFor', tag: 'STT');
      
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'STT Start');
      _isListening = false;
      _listeningStatusStream.add(false);
    }
  }
  
  Future<void> stopListening() async {
    try {
      if (_isListening) {
        await _speech.stop();
        _isListening = false;
        _listeningStatusStream.add(false);
        Logger().debug('Stopped listening', tag: 'STT');
      }
    } catch (e) {
      Logger().error('Error stopping listening', tag: 'STT', error: e);
    }
  }
  
  Future<void> cancelListening() async {
    try {
      if (_isListening) {
        await _speech.cancel();
        _isListening = false;
        _listeningStatusStream.add(false);
        Logger().debug('Cancelled listening', tag: 'STT');
      }
    } catch (e) {
      Logger().error('Error cancelling listening', tag: 'STT', error: e);
    }
  }
  
  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      _lastRecognizedText = result.recognizedWords;
      _recognitionStream.add(_lastRecognizedText);
      Logger().info('Recognized: $_lastRecognizedText', tag: 'STT');
    } else {
      // Partial result for real-time display
      _recognitionStream.add(result.recognizedWords);
    }
  }
  
  Future<List<String>> getAvailableLocales() async {
    try {
      if (!_isAvailable) await initialize();
      final locales = await _speech.locales();
      return locales.map((l) => l.localeId).toList();
    } catch (e) {
      Logger().error('Error getting locales', tag: 'STT', error: e);
      return ['en_US', 'hi_IN', 'en_IN', 'bn_IN', 'ta_IN', 'te_IN', 'mr_IN'];
    }
  }
  
  Future<bool> setLocale(String localeId) async {
    try {
      if (!_isAvailable) await initialize();
      final result = await _speech.setLocale(localeId);
      if (result) {
        Logger().info('Locale set to: $localeId', tag: 'STT');
      }
      return result;
    } catch (e) {
      Logger().error('Error setting locale', tag: 'STT', error: e);
      return false;
    }
  }
  
  bool isLanguageSupported(String languageCode) {
    final supported = ['en', 'hi', 'bn', 'te', 'mr', 'ta', 'ur', 'gu', 'kn', 'ml', 'or', 'pa'];
    return supported.contains(languageCode.split('_')[0]);
  }
  
  double getSoundLevel() {
    return _currentSoundLevel;
  }
  
  void dispose() {
    _speech.stop();
    _recognitionStream.close();
    _listeningStatusStream.close();
    _soundLevelStream.close();
  }
}

class VoiceCommandDetector {
  static const List<String> _wakeWords = [
    'jarvis', 'hey jarvis', 'hello jarvis', 'jarvis ji',
    'suno jarvis', 'jarvis suno', 'ok jarvis', 'jarvis bhai',
    'jarvis bhaiya', 'jarvis sir', 'jarvis boss', 'jarvis wake up',
    'mukul sir', 'jarvis please', 'jarvis karo', 'jarvis bolo'
  ];
  
  static const List<String> _yesWords = [
    'yes', 'haan', 'ha', 'han', 'yeah', 'yep', 'sure', 'ok', 
    'okay', 'theek', 'acha', 'bilkul', 'karo', 'chalo', 'done'
  ];
  
  static const List<String> _noWords = [
    'no', 'nahi', 'na', 'nope', 'not', 'mat', 'mana', 'cancel', 
    'band karo', 'rok', 'stop', 'nah'
  ];
  
  static const List<String> _confirmationWords = [
    'confirm', 'confirm karo', 'haan karo', 'yes karo', 'theek hai', 'sahi hai'
  ];
  
  static bool containsWakeWord(String text) {
    final lowercase = text.toLowerCase().trim();
    for (var wakeWord in _wakeWords) {
      if (lowercase.contains(wakeWord)) {
        return true;
      }
    }
    return false;
  }
  
  static String removeWakeWord(String text) {
    var result = text.toLowerCase();
    for (var wakeWord in _wakeWords) {
      result = result.replaceAll(wakeWord, '');
    }
    return result.trim();
  }
  
  static bool isYesCommand(String text) {
    final cleanText = text.toLowerCase().trim();
    return _yesWords.contains(cleanText) || 
           _yesWords.any((word) => cleanText.contains(word));
  }
  
  static bool isNoCommand(String text) {
    final cleanText = text.toLowerCase().trim();
    return _noWords.contains(cleanText) || 
           _noWords.any((word) => cleanText.contains(word));
  }
  
  static bool isConfirmationCommand(String text) {
    final cleanText = text.toLowerCase().trim();
    return _confirmationWords.any((word) => cleanText.contains(word));
  }
  
  static List<String> extractNumbers(String text) {
    final regex = RegExp(r'\d+');
    return regex.allMatches(text).map((m) => m.group(0)!).toList();
  }
  
  static int? extractNumber(String text) {
    final numbers = extractNumbers(text);
    if (numbers.isNotEmpty) {
      return int.tryParse(numbers.first);
    }
    return null;
  }
  
  static String extractContactName(String text) {
    // Extract name after "call", "message", etc.
    final patterns = [
      RegExp(r'call\s+(\w+)', caseSensitive: false),
      RegExp(r'message\s+(\w+)', caseSensitive: false),
      RegExp(r'text\s+(\w+)', caseSensitive: false),
      RegExp(r'phone\s+(\w+)', caseSensitive: false),
      RegExp(r'(\w+)\s+ko\s+phone', caseSensitive: false),
      RegExp(r'(\w+)\s+ko\s+call', caseSensitive: false),
      RegExp(r'(\w+)\s+ko\s+message', caseSensitive: false),
      RegExp(r'(\w+)\s+ko\s+text', caseSensitive: false),
    ];
    
    for (var pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        final name = match.group(1)!;
        if (name.length > 1 && name.length < 30) {
          return name;
        }
      }
    }
    
    return '';
  }
  
  static String extractMessageContent(String text) {
    // Extract message content after "message", "text", etc.
    final patterns = [
      RegExp(r'message\s+(?:to\s+\w+\s+)?(.*?)(?:\s*$)', caseSensitive: false),
      RegExp(r'text\s+(?:to\s+\w+\s+)?(.*?)(?:\s*$)', caseSensitive: false),
      RegExp(r'(?:bolo|send|bhejo)\s+(?:to\s+\w+\s+)?(.*?)(?:\s*$)', caseSensitive: false),
      RegExp(r'-\s+(.+?)$', caseSensitive: false),
      RegExp(r'"(.*?)"', caseSensitive: false),
    ];
    
    for (var pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        final content = match.group(1)!.trim();
        if (content.isNotEmpty && content.length > 2) {
          return content;
        }
      }
    }
    
    return '';
  }
  
  static String extractTimeFromCommand(String text) {
    // Extract time like "8 baje", "8:30", "8:30 PM"
    final patterns = [
      RegExp(r'(\d{1,2})\s*(?:baje|o\'clock|:)?\s*(\d{2})?\s*(am|pm)?', caseSensitive: false),
      RegExp(r'(\d{1,2}):(\d{2})\s*(am|pm)?', caseSensitive: false),
    ];
    
    for (var pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final hour = int.tryParse(match.group(1) ?? '0');
        final minute = match.groupCount >= 2 ? int.tryParse(match.group(2) ?? '0') : 0;
        final period = match.groupCount >= 3 ? match.group(3)?.toLowerCase() : '';
        
        if (hour != null && hour > 0 && hour <= 24) {
          var finalHour = hour;
          if (period == 'pm' && hour < 12) finalHour += 12;
          if (period == 'am' && hour == 12) finalHour = 0;
          return '${finalHour.toString().padLeft(2, '0')}:${minute?.toString().padLeft(2, '0') ?? '00'}';
        }
      }
    }
    
    return '';
  }
  
  static String extractCommandCategory(String text) {
    final lower = text.toLowerCase();
    
    if (lower.contains('flash') || lower.contains('torch') || lower.contains('light')) {
      return 'device';
    }
    if (lower.contains('call') || lower.contains('phone')) {
      return 'call';
    }
    if (lower.contains('message') || lower.contains('sms') || lower.contains('whatsapp')) {
      return 'message';
    }
    if (lower.contains('open') || lower.contains('kholo')) {
      return 'app';
    }
    if (lower.contains('time') || lower.contains('date') || lower.contains('weather')) {
      return 'info';
    }
    if (lower.contains('joke') || lower.contains('quote') || lower.contains('fact')) {
      return 'entertainment';
    }
    if (lower.contains('clean') || lower.contains('clear') || lower.contains('delete')) {
      return 'cleanup';
    }
    if (lower.contains('vault') || lower.contains('lockdown') || lower.contains('face')) {
      return 'security';
    }
    
    return 'general';
  }
}