// lib/services/voice/text_to_speech_service.dart
// Text-to-Speech Service with JARVIS Voice

import 'package:flutter_tts/flutter_tts.dart';
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';

class TextToSpeechService {
  static final TextToSpeechService _instance = TextToSpeechService._internal();
  factory TextToSpeechService() => _instance;
  TextToSpeechService._internal();
  
  FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isInitialized = false;
  
  String _currentLanguage = 'hi-IN';
  double _speechRate = 0.5;
  double _speechPitch = 1.0;
  double _speechVolume = 1.0;
  String _voiceName = 'hi-in-x-hie#male_2-local';
  
  final List<String> _availableLanguages = [
    'en-US', 'en-IN', 'hi-IN', 'bn-IN', 'ta-IN', 'te-IN', 'mr-IN', 'gu-IN', 'kn-IN', 'ml-IN', 'pa-IN'
  ];
  
  Stream<bool> get speakingStatusStream => _flutterTts.isSpeaking;
  bool get isSpeaking => _isSpeaking;
  bool get isInitialized => _isInitialized;
  
  Future<void> initialize() async {
    try {
      await _flutterTts.setLanguage(_currentLanguage);
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setPitch(_speechPitch);
      await _flutterTts.setVolume(_speechVolume);
      
      // Set voice for JARVIS character
      await _flutterTts.setVoice(_voiceName);
      
      // Set callbacks
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        Logger().debug('TTS started speaking', tag: 'TTS');
      });
      
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        Logger().debug('TTS completed', tag: 'TTS');
      });
      
      _flutterTts.setErrorHandler((error) {
        _isSpeaking = false;
        Logger().error('TTS error: $error', tag: 'TTS');
      });
      
      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        Logger().debug('TTS cancelled', tag: 'TTS');
      });
      
      _isInitialized = true;
      Logger().info('TTS initialized with JARVIS voice', tag: 'TTS');
      
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'TTS Init');
      _isInitialized = false;
    }
  }
  
  Future<void> speak(String text, {bool isHindi = true, String? emotion, bool waitForCompletion = false}) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      if (text.isEmpty) return;
      
      // Stop current speech if any
      if (_isSpeaking) {
        await stop();
        if (waitForCompletion) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
      
      // Apply emotion-based voice settings
      if (emotion != null) {
        await _applyEmotionSettings(emotion);
      }
      
      // Set language based on text or preference
      final shouldUseHindi = isHindi || _containsHindi(text);
      await _flutterTts.setLanguage(shouldUseHindi ? 'hi-IN' : 'en-US');
      
      // Clean text for TTS (remove markdown, emojis, etc.)
      final cleanText = _cleanForTTS(text);
      
      // Speak
      final result = await _flutterTts.speak(cleanText);
      
      if (result == 1) {
        Logger().info('Speaking: ${cleanText.substring(0, cleanText.length > 50 ? 50 : cleanText.length)}...', tag: 'TTS');
      } else {
        Logger().error('Failed to speak', tag: 'TTS');
      }
      
      // Reset to default settings after speaking
      if (emotion != null) {
        await _resetToDefaultSettings();
      }
      
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'TTS Speak');
    }
  }
  
  Future<void> speakWithJARVISStyle(String text) async {
    // Add JARVIS-style pauses and emphasis
    text = _addJarvisEmphasis(text);
    await speak(text, emotion: 'jarvis');
  }
  
  String _addJarvisEmphasis(String text) {
    // Add natural pauses for JARVIS speaking style
    text = text.replaceAll('. ', '. .. ');
    text = text.replaceAll('? ', '? .. ');
    text = text.replaceAll('! ', '! .. ');
    return text;
  }
  
  Future<void> stop() async {
    try {
      if (_isSpeaking) {
        await _flutterTts.stop();
        _isSpeaking = false;
        Logger().debug('TTS stopped', tag: 'TTS');
      }
    } catch (e) {
      Logger().error('Error stopping TTS', tag: 'TTS', error: e);
    }
  }
  
  Future<void> setLanguage(String languageCode) async {
    try {
      if (!_availableLanguages.contains(languageCode)) {
        Logger().warning('Language $languageCode not available, using default', tag: 'TTS');
        languageCode = 'hi-IN';
      }
      _currentLanguage = languageCode;
      await _flutterTts.setLanguage(languageCode);
      Logger().info('TTS language set to $languageCode', tag: 'TTS');
    } catch (e) {
      Logger().error('Error setting language', tag: 'TTS', error: e);
    }
  }
  
  Future<void> setSpeechRate(double rate) async {
    try {
      _speechRate = rate.clamp(0.0, 1.0);
      await _flutterTts.setSpeechRate(_speechRate);
      Logger().debug('Speech rate set to $_speechRate', tag: 'TTS');
    } catch (e) {
      Logger().error('Error setting speech rate', tag: 'TTS', error: e);
    }
  }
  
  Future<void> setPitch(double pitch) async {
    try {
      _speechPitch = pitch.clamp(0.5, 2.0);
      await _flutterTts.setPitch(_speechPitch);
      Logger().debug('Pitch set to $_speechPitch', tag: 'TTS');
    } catch (e) {
      Logger().error('Error setting pitch', tag: 'TTS', error: e);
    }
  }
  
  Future<void> setVolume(double volume) async {
    try {
      _speechVolume = volume.clamp(0.0, 1.0);
      await _flutterTts.setVolume(_speechVolume);
      Logger().debug('Volume set to $_speechVolume', tag: 'TTS');
    } catch (e) {
      Logger().error('Error setting volume', tag: 'TTS', error: e);
    }
  }
  
  Future<void> setVoice(String voiceName) async {
    try {
      _voiceName = voiceName;
      await _flutterTts.setVoice(voiceName);
      Logger().info('Voice set to $voiceName', tag: 'TTS');
    } catch (e) {
      Logger().error('Error setting voice', tag: 'TTS', error: e);
    }
  }
  
  Future<void> _applyEmotionSettings(String emotion) async {
    switch (emotion.toLowerCase()) {
      case 'happy':
        await setPitch(1.2);
        await setSpeechRate(0.55);
        break;
      case 'sad':
        await setPitch(0.8);
        await setSpeechRate(0.45);
        break;
      case 'angry':
        await setPitch(1.3);
        await setSpeechRate(0.6);
        break;
      case 'excited':
        await setPitch(1.4);
        await setSpeechRate(0.65);
        break;
      case 'calm':
        await setPitch(0.9);
        await setSpeechRate(0.4);
        break;
      case 'serious':
        await setPitch(1.0);
        await setSpeechRate(0.5);
        break;
      case 'jarvis':
        await setPitch(1.05);
        await setSpeechRate(0.52);
        break;
      default:
        await _resetToDefaultSettings();
    }
  }
  
  Future<void> _resetToDefaultSettings() async {
    await setPitch(1.0);
    await setSpeechRate(0.5);
    await setVolume(1.0);
  }
  
  bool _containsHindi(String text) {
    final hindiRegex = RegExp(r'[\u0900-\u097F]');
    return hindiRegex.hasMatch(text);
  }
  
  String _cleanForTTS(String text) {
    // Remove markdown
    text = text.replaceAll(RegExp(r'[*_~`]'), '');
    text = text.replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '');
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // Remove emojis (keep basic punctuation)
    text = text.replaceAll(RegExp(r'[\u{1F600}-\u{1F64F}]', unicode: true), '');
    text = text.replaceAll(RegExp(r'[\u{1F300}-\u{1F5FF}]', unicode: true), '');
    text = text.replaceAll(RegExp(r'[\u{1F680}-\u{1F6FF}]', unicode: true), '');
    text = text.replaceAll(RegExp(r'[\u{2600}-\u{26FF}]', unicode: true), '');
    
    // Fix common abbreviations
    text = text.replaceAll('Sir', 'Sir');
    text = text.replaceAll('JARVIS', 'Jarvis');
    
    return text.trim();
  }
  
  Future<List<dynamic>> getVoices() async {
    try {
      return await _flutterTts.getVoices;
    } catch (e) {
      Logger().error('Error getting voices', tag: 'TTS', error: e);
      return [];
    }
  }
  
  Future<void> speakWithEmotion(String text, String emotion) async {
    await _applyEmotionSettings(emotion);
    await speak(text);
    await _resetToDefaultSettings();
  }
  
  void dispose() {
    _flutterTts.stop();
  }
}

class JARVISVoiceEffects {
  static const String jarvisDefault = 'en-us-x-sfg#male_2-local';
  static const String jarvisEnergized = 'en-us-x-sfg#male_1-local';
  static const String jarvisCalm = 'en-us-x-sfg#male_3-local';
  static const String jarvisHindi = 'hi-in-x-hie#male_2-local';
  
  static Map<String, dynamic> getEffectSettings(String effect) {
    switch (effect) {
      case 'energized':
        return {'pitch': 1.2, 'rate': 0.55, 'volume': 1.0};
      case 'calm':
        return {'pitch': 0.9, 'rate': 0.45, 'volume': 0.8};
      case 'dramatic':
        return {'pitch': 1.1, 'rate': 0.5, 'volume': 1.0};
      case 'whisper':
        return {'pitch': 1.0, 'rate': 0.4, 'volume': 0.5};
      case 'excited':
        return {'pitch': 1.3, 'rate': 0.6, 'volume': 1.0};
      default:
        return {'pitch': 1.0, 'rate': 0.5, 'volume': 1.0};
    }
  }
  
  static String getVoiceForLanguage(String language) {
    switch (language) {
      case 'hi':
        return jarvisHindi;
      case 'en':
        return jarvisDefault;
      default:
        return jarvisDefault;
    }
  }
}

class TTSQueue {
  static final TTSQueue _instance = TTSQueue._internal();
  factory TTSQueue() => _instance;
  TTSQueue._internal();
  
  final List<TTSQueueItem> _queue = [];
  bool _isProcessing = false;
  final TextToSpeechService _tts = TextToSpeechService();
  
  void addToQueue(String text, {String? emotion, bool isHindi = true}) {
    _queue.add(TTSQueueItem(
      text: text,
      emotion: emotion,
      isHindi: isHindi,
      timestamp: DateTime.now(),
    ));
    _processQueue();
  }
  
  Future<void> _processQueue() async {
    if (_isProcessing || _queue.isEmpty) return;
    
    _isProcessing = true;
    final item = _queue.removeAt(0);
    
    await _tts.speak(item.text, emotion: item.emotion, isHindi: item.isHindi);
    
    _isProcessing = false;
    _processQueue();
  }
  
  void clear() {
    _queue.clear();
    _tts.stop();
    _isProcessing = false;
  }
  
  int get queueLength => _queue.length;
}

class TTSQueueItem {
  final String text;
  final String? emotion;
  final bool isHindi;
  final DateTime timestamp;
  
  TTSQueueItem({
    required this.text,
    this.emotion,
    required this.isHindi,
    required this.timestamp,
  });
}