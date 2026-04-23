// lib/services/core/response_builder.dart
// Dynamic Response Builder with Personality

import '../../models/chat_message.dart';
import '../../utils/helpers.dart';

class ResponseBuilder {
  static final ResponseBuilder _instance = ResponseBuilder._internal();
  factory ResponseBuilder() => _instance;
  ResponseBuilder._internal();
  
  String _currentMood = 'neutral';
  String _lastResponse = '';
  List<String> _responseHistory = [];
  
  void setMood(String mood) {
    _currentMood = mood;
  }
  
  String buildResponse({
    required String content,
    required MessageType type,
    bool useHinglish = true,
    bool addEmoji = true,
    String? context,
  }) {
    var response = content;
    
    // Apply mood-based prefix
    response = _applyMoodPrefix(response);
    
    // Apply personality
    response = _applyPersonality(response);
    
    // Add emojis if enabled
    if (addEmoji) {
      response = _addEmojis(response, type);
    }
    
    // Apply Hinglish if enabled
    if (useHinglish) {
      response = _applyHinglish(response);
    }
    
    // Ensure proper formatting
    response = _formatResponse(response);
    
    _lastResponse = response;
    _responseHistory.add(response);
    if (_responseHistory.length > 50) _responseHistory.removeAt(0);
    
    return response;
  }
  
  String _applyMoodPrefix(String response) {
    switch (_currentMood) {
      case 'happy':
        return '😊 $response';
      case 'sad':
        return '💙 $response';
      case 'angry':
        return '🧘 $response';
      case 'tired':
        return '💤 $response';
      case 'stressed':
        return '🌿 $response';
      default:
        return response;
    }
  }
  
  String _applyPersonality(String response) {
    final personalityPrefixes = [
      'Sir, ',
      'Boss, ',
      'Mukul Sir, ',
      'Check karo, ',
      'Dekho, ',
      'Actually Sir, ',
      'To be precise, ',
      'Here\'s the thing, ',
      'Let me tell you, ',
    ];
    
    // Don't add prefix if already present or response is too short
    bool hasPrefix = false;
    for (var prefix in personalityPrefixes) {
      if (response.toLowerCase().startsWith(prefix.toLowerCase())) {
        hasPrefix = true;
        break;
      }
    }
    
    if (!hasPrefix && response.length > 15 && response.length < 500) {
      final randomPrefix = personalityPrefixes[
          DateTime.now().millisecond % personalityPrefixes.length];
      response = '$randomPrefix$response';
    }
    
    return response;
  }
  
  String _addEmojis(String response, MessageType type) {
    // Add type-specific emoji
    switch (type) {
      case MessageType.success:
        response = '✅ $response';
        break;
      case MessageType.error:
        response = '❌ $response';
        break;
      case MessageType.warning:
        response = '⚠️ $response';
        break;
      case MessageType.info:
        response = 'ℹ️ $response';
        break;
      default:
        break;
    }
    
    // Add content-based emojis
    if (response.toLowerCase().contains('sorry') || 
        response.toLowerCase().contains('maaf')) {
      response += ' 🙏';
    }
    if (response.toLowerCase().contains('done') || 
        response.toLowerCase().contains('ho gaya') ||
        response.toLowerCase().contains('complete')) {
      response += ' ✅';
    }
    if (response.toLowerCase().contains('error') || 
        response.toLowerCase().contains('problem') ||
        response.toLowerCase().contains('issue')) {
      response += ' ⚠️';
    }
    if (response.toLowerCase().contains('congrats') || 
        response.toLowerCase().contains('badhai') ||
        response.toLowerCase().contains('welcome')) {
      response += ' 🎉';
    }
    if (response.toLowerCase().contains('love') || 
        response.toLowerCase().contains('like')) {
      response += ' ❤️';
    }
    if (response.toLowerCase().contains('call') || 
        response.toLowerCase().contains('phone')) {
      response += ' 📞';
    }
    if (response.toLowerCase().contains('message') || 
        response.toLowerCase().contains('text')) {
      response += ' ✉️';
    }
    if (response.toLowerCase().contains('photo') || 
        response.toLowerCase().contains('camera')) {
      response += ' 📷';
    }
    if (response.toLowerCase().contains('music') || 
        response.toLowerCase().contains('song')) {
      response += ' 🎵';
    }
    
    return response;
  }
  
  String _applyHinglish(String response) {
    final hinglishMap = {
      'hello': 'namaste',
      'how are you': 'aap kaise hain',
      'thank you': 'dhanyavaad',
      'thanks': 'shukriya',
      'good morning': 'suprabhat',
      'good night': 'shubh ratri',
      'yes': 'haan',
      'no': 'nahi',
      'please': 'kripya',
      'sorry': 'maaf karo',
      'what': 'kya',
      'where': 'kahan',
      'when': 'kab',
      'why': 'kyun',
      'who': 'kaun',
      'tell me': 'mujhe batao',
      'show me': 'mujhe dikhao',
      'open': 'kholo',
      'close': 'band karo',
      'call': 'phone karo',
      'message': 'message karo',
      'send': 'bhejo',
      'done': 'ho gaya',
      'wait': 'ruko',
      'listen': 'suno',
      'speak': 'bolo',
      'go': 'jao',
      'come': 'aao',
      'sit': 'baitho',
      'stand': 'kharhe ho',
    };
    
    var result = response;
    hinglishMap.forEach((eng, hin) {
      result = result.replaceAll(RegExp('\\b$eng\\b', caseSensitive: false), hin);
    });
    
    return result;
  }
  
  String _formatResponse(String response) {
    // Trim whitespace
    response = response.trim();
    
    // Ensure proper capitalization
    if (response.isNotEmpty) {
      response = response[0].toUpperCase() + response.substring(1);
    }
    
    // Add period if missing
    if (!response.endsWith('.') && !response.endsWith('!') && 
        !response.endsWith('?') && response.isNotEmpty) {
      response += '.';
    }
    
    // Limit length for better UX
    if (response.length > 500) {
      response = response.substring(0, 497) + '...';
    }
    
    return response;
  }
  
  String buildThinkingResponse() {
    final thinkingResponses = [
      'Processing, Sir... 🤔',
      'Let me think about that... 🧠',
      'Analyzing your request... 🔍',
      'Working on it, Boss... ⚡',
      'One moment, Sir... 🔄',
      'Calculating optimal response... 📊',
      'Accessing knowledge base... 📚',
      'Running neural networks... 🧬',
      'Just a second, Sir... ⏱️',
      'Let me check that for you... 🔎',
    ];
    return thinkingResponses[DateTime.now().second % thinkingResponses.length];
  }
  
  String buildWelcomeResponse() {
    final hour = DateTime.now().hour;
    String greeting;
    
    if (hour < 12) greeting = 'Good Morning';
    else if (hour < 17) greeting = 'Good Afternoon';
    else greeting = 'Good Evening';
    
    return '$greeting Mukul Sir! 👋\n\nI am JARVIS, your personal AI assistant. I\'m always listening for your commands.\n\nJust say "JARVIS" followed by what you need. Try: "JARVIS, what time is it?" or "JARVIS, tell me a joke"';
  }
  
  String buildHelpResponse() {
    return '''Sir, main 500+ commands execute kar sakta hu! 🚀

🔐 SECURITY: Face recognition, Voice ID, Vault, Intruder detection, Lockdown
📱 DEVICE: Flashlight, Volume, Brightness, WiFi, Bluetooth, Hotspot, Screenshot
📞 CALLS: Call anyone, Missed calls, Call blocking, Call recording
💬 MESSAGES: SMS, WhatsApp, Telegram, Email, Auto-reply
🎵 MEDIA: Music, Videos, YouTube, Camera, Gallery
🗂️ FILES: Browse, Search, Delete, Move, Copy, Zip, Unzip
🧹 CLEANUP: Smart cleanup, WhatsApp cleanup, Duplicate photos, Junk removal
🤖 AI: General knowledge, Coding, Translation, Jokes, Quotes, Facts
⚡ ROUTINES: Good Morning, Night, Office, Driving, Gaming, Study, Meeting
📰 INFO: Weather, News, Time, Date, Battery, Storage
🔧 SYSTEM: Device info, Performance monitor, Storage analyzer

Kya karna hai Sir? 🎯''';
  }
  
  String buildErrorResponse(String error) {
    final errorResponses = [
      'Sir, kuch technical issue hai. Thodi der mein try karo. 🔧',
      'Oops! Kuch gadbad ho gayi. Phir se boliye. 🔄',
      'Sir, main samajh nahi paya. Thoda aur detail mein batao. 🎤',
      'Sorry Sir, ye command process nahi kar paya. Kuch aur poochiye? 🙏',
    ];
    return errorResponses[DateTime.now().second % errorResponses.length];
  }
  
  String buildSuccessResponse(String action) {
    final successResponses = [
      'Done, Sir! ✅',
      'Command executed successfully! 🎯',
      'Ho gaya, Sir! 👍',
      'Complete! Anything else? 🔥',
      'Sir, aapka kaam ho gaya! 💪',
    ];
    return successResponses[DateTime.now().second % successResponses.length];
  }
  
  String getLastResponse() => _lastResponse;
  
  List<String> getResponseHistory() => List.unmodifiable(_responseHistory);
  
  void clearHistory() {
    _responseHistory.clear();
  }
}

class ResponseFormatter {
  static String formatForTTS(String text) {
    // Remove markdown and special characters for TTS
    text = text.replaceAll(RegExp(r'[*_~`]'), '');
    text = text.replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '');
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');
    text = text.replaceAll(RegExp(r'[\u{1F600}-\u{1F64F}]', unicode: true), '');
    text = text.replaceAll(RegExp(r'[\u{1F300}-\u{1F5FF}]', unicode: true), '');
    text = text.replaceAll('✅', 'done');
    text = text.replaceAll('❌', 'error');
    text = text.replaceAll('⚠️', 'warning');
    text = text.replaceAll('🔦', 'flashlight');
    text = text.replaceAll('📞', 'call');
    text = text.replaceAll('✉️', 'message');
    text = text.replaceAll('🎵', 'music');
    text = text.replaceAll('📷', 'camera');
    return text.trim();
  }
  
  static String formatForDisplay(String text) {
    // Add line breaks for better readability
    text = text.replaceAll(r'\n', '\n\n');
    return text;
  }
  
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }
  
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}