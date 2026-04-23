// lib/services/ai/ai_service.dart
// Main AI Service Manager - Coordinates all AI providers

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../config/constants.dart';
import '../../utils/error_handler.dart';
import '../../utils/logger.dart';
import '../../models/chat_message.dart';
import 'gemini_service.dart';
import 'openai_service.dart';
import 'offline_ai.dart';

enum AIProvider {
  gemini,
  openai,
  offline,
  auto,
}

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();
  
  AIProvider _currentProvider = AIProvider.gemini;
  final GeminiService _geminiService = GeminiService();
  final OpenAIService _openAIService = OpenAIService();
  final OfflineAI _offlineAI = OfflineAI();
  
  bool _isOnline = true;
  String _conversationContext = '';
  List<Map<String, String>> _chatHistory = [];
  Map<String, dynamic> _userPreferences = {};
  String _currentMood = 'neutral';
  
  void setProvider(AIProvider provider) {
    _currentProvider = provider;
    Logger().info('AI Provider changed to: $provider', tag: 'AI');
  }
  
  void setOnlineStatus(bool isOnline) {
    _isOnline = isOnline;
    if (!isOnline) {
      Logger().info('Switching to offline AI mode', tag: 'AI');
    }
  }
  
  void setConversationContext(String context) {
    _conversationContext = context;
  }
  
  void setUserPreferences(Map<String, dynamic> preferences) {
    _userPreferences = preferences;
  }
  
  void setCurrentMood(String mood) {
    _currentMood = mood;
  }
  
  void addToHistory(String userMessage, String assistantResponse) {
    _chatHistory.add({'role': 'user', 'content': userMessage});
    _chatHistory.add({'role': 'assistant', 'content': assistantResponse});
    
    // Keep only last 20 messages for context
    if (_chatHistory.length > 40) {
      _chatHistory = _chatHistory.sublist(_chatHistory.length - 40);
    }
  }
  
  void clearChatHistory() {
    _chatHistory.clear();
    Logger().debug('Chat history cleared', tag: 'AI');
  }
  
  Future<String> processQuery(String query, {bool useVoice = true, Map<String, dynamic>? context}) async {
    try {
      Logger().info('Processing query: $query', tag: 'AI');
      
      // Check for mood-based response adaptation
      final moodAdjustedQuery = _adjustQueryForMood(query);
      
      // Determine which provider to use
      AIProvider providerToUse = _currentProvider;
      if (providerToUse == AIProvider.auto) {
        providerToUse = _selectBestProvider();
      }
      
      // Check if offline mode is forced or no internet
      if (!_isOnline || providerToUse == AIProvider.offline) {
        return await _offlineAI.getResponse(moodAdjustedQuery, mood: _currentMood);
      }
      
      // Try primary AI provider
      String response;
      try {
        switch (providerToUse) {
          case AIProvider.gemini:
            response = await _geminiService.getResponse(moodAdjustedQuery, _chatHistory);
            break;
          case AIProvider.openai:
            response = await _openAIService.getResponse(moodAdjustedQuery, _chatHistory);
            break;
          case AIProvider.offline:
            response = await _offlineAI.getResponse(moodAdjustedQuery, mood: _currentMood);
            break;
          case AIProvider.auto:
            response = await _geminiService.getResponse(moodAdjustedQuery, _chatHistory);
            break;
        }
      } catch (e) {
        Logger().error('Primary AI failed, falling back to offline', tag: 'AI', error: e);
        response = await _offlineAI.getResponse(moodAdjustedQuery, mood: _currentMood);
      }
      
      // Add to chat history
      addToHistory(query, response);
      
      // Apply JARVIS personality
      response = _applyPersonality(response);
      
      return response;
      
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'AI Service');
      return 'Sir, AI service mein problem hai. Offline mode mein baat kar raha hu. Kuch aur poochiye?';
    }
  }
  
  String _adjustQueryForMood(String query) {
    // Add mood context to query for better responses
    switch (_currentMood) {
      case 'happy':
        return query + " (User is happy, respond enthusiastically)";
      case 'sad':
        return query + " (User is feeling sad, be supportive and empathetic)";
      case 'angry':
        return query + " (User is angry, respond calmly and professionally)";
      case 'tired':
        return query + " (User is tired, keep response short and suggest rest)";
      case 'stressed':
        return query + " (User is stressed, provide calming and helpful response)";
      default:
        return query;
    }
  }
  
  AIProvider _selectBestProvider() {
    // Auto-select based on query type and availability
    if (!_isOnline) return AIProvider.offline;
    return AIProvider.gemini; // Default to Gemini
  }
  
  String _applyPersonality(String response) {
    // Add JARVIS personality touches
    final personalityResponses = [
      'Sir, ',
      'Boss, ',
      'Mukul Sir, ',
      'Check karo, ',
      'Dekho, ',
      'Actually Sir, ',
      'To be precise, ',
    ];
    
    // Don't add if already has greeting
    bool hasGreeting = false;
    for (var greeting in personalityResponses) {
      if (response.toLowerCase().startsWith(greeting.toLowerCase())) {
        hasGreeting = true;
        break;
      }
    }
    
    if (!hasGreeting && response.length > 15 && response.length < 500) {
      final randomGreeting = personalityResponses[
          DateTime.now().millisecond % personalityResponses.length];
      response = '$randomGreeting$response';
    }
    
    // Add emojis based on content
    if (response.toLowerCase().contains('sorry') || 
        response.toLowerCase().contains('maaf')) {
      response += ' 🙏';
    } else if (response.toLowerCase().contains('done') || 
               response.toLowerCase().contains('ho gaya')) {
      response += ' ✅';
    } else if (response.toLowerCase().contains('error') || 
               response.toLowerCase().contains('problem')) {
      response += ' ⚠️';
    } else if (response.toLowerCase().contains('congrats') || 
               response.toLowerCase().contains('badhai')) {
      response += ' 🎉';
    }
    
    return response;
  }
  
  Future<String> processCommand(String command) async {
    // Special handling for AI commands
    final lower = command.toLowerCase();
    
    if (lower.contains('ai provider') || lower.contains('change ai')) {
      return _handleAIProviderChange(command);
    }
    
    if (lower.contains('clear context') || lower.contains('reset conversation')) {
      clearChatHistory();
      return 'Sir, conversation history clear kar di. Naye topic par baat kar sakte hain. 🗑️';
    }
    
    if (lower.contains('what can you do') || lower.contains('capabilities') || lower.contains('kya kar sakta')) {
      return _getCapabilities();
    }
    
    return await processQuery(command);
  }
  
  String _handleAIProviderChange(String command) {
    if (command.toLowerCase().contains('gemini')) {
      _currentProvider = AIProvider.gemini;
      return 'Sir, main ab Gemini AI use kar raha hu. Yeh Google ka latest model hai - free aur bahut smart hai! 🧠';
    } else if (command.toLowerCase().contains('chatgpt') || 
               command.toLowerCase().contains('openai')) {
      _currentProvider = AIProvider.openai;
      return 'Sir, main ab ChatGPT use kar raha hu. Yeh OpenAI ka powerful model hai. 🚀';
    } else if (command.toLowerCase().contains('offline')) {
      _currentProvider = AIProvider.offline;
      return 'Sir, offline mode activate. Internet ki zaroorat nahi, lekin limited knowledge hai. 💾';
    } else if (command.toLowerCase().contains('auto')) {
      _currentProvider = AIProvider.auto;
      return 'Sir, auto mode activate. Main apne hisaab se best AI choose karunga. 🎯';
    } else {
      return 'Sir, AI provider change karne ke liye bolein:\n• "Gemini use karo"\n• "ChatGPT use karo"\n• "Offline mode"\n• "Auto mode"';
    }
  }
  
  String _getCapabilities() {
    return '''Sir, main 500+ tasks kar sakta hu! 🔥

📚 KNOWLEDGE: General Q&A, Facts, Definitions
💻 CODING: Code generation, Debugging, Explanation
✍️ CREATIVE: Poems, Stories, Essays, Captions
🌐 TRANSLATION: 100+ languages
📊 ANALYSIS: Summarization, Pros/Cons, Sentiment
🎓 EDUCATION: Tutoring, Interview prep, Career advice
💰 FINANCE: Budgeting, Investment tips, Tax info
⚖️ LEGAL: Basic legal information
🔬 SCIENCE: Physics, Chemistry, Biology
📖 HISTORY: Historical facts and analysis
🎨 ART: Art history, Techniques, Critique
🏥 HEALTH: Fitness, Nutrition, Wellness
❤️ RELATIONSHIP: Advice and communication tips
🧘 SPIRITUAL: Meditation, Mindfulness, Philosophy

Aur bhi bahut kuch! Kya poochna chahte ho Sir? 🎯''';
  }
  
  Future<String> analyzeImage(List<int> imageBytes, String query) async {
    try {
      if (_currentProvider == AIProvider.gemini && _isOnline) {
        return await _geminiService.analyzeImage(imageBytes, query);
      } else if (_currentProvider == AIProvider.openai && _isOnline) {
        return await _openAIService.analyzeImage(imageBytes, query);
      } else {
        return 'Sir, image analysis ke liye internet aur Gemini/OpenAI API chahiye. Internet connect karo ya provider change karo. 📷';
      }
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'Image Analysis');
      return 'Sir, image analyze nahi kar paya. Koi technical issue hai. Dobara try karo.';
    }
  }
  
  Future<String> generateImage(String prompt) async {
    try {
      if (_currentProvider == AIProvider.openai && _isOnline) {
        return await _openAIService.generateImage(prompt);
      } else {
        return 'Sir, image generation sirf OpenAI ChatGPT se possible hai. API key configure karo aur internet on rakho. 🎨';
      }
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'Image Generation');
      return 'Sir, image generate nahi kar paya.';
    }
  }
  
  Future<String> transcribeAudio(List<int> audioBytes) async {
    try {
      if (_isOnline) {
        return await _openAIService.transcribeAudio(audioBytes);
      } else {
        return 'Sir, audio transcription ke liye internet chahiye. 🌐';
      }
    } catch (e) {
      return 'Sir, audio transcribe nahi kar paya.';
    }
  }
  
  Map<String, dynamic> getAIStatus() {
    return {
      'provider': _currentProvider.toString(),
      'online': _isOnline,
      'chatHistoryLength': _chatHistory.length,
      'context': _conversationContext.isNotEmpty ? 'Active' : 'None',
      'mood': _currentMood,
      'preferences': _userPreferences.keys.length,
    };
  }
  
  Future<String> getThinkingResponse() async {
    final thinkingResponses = [
      'Processing, Sir... 🤔',
      'Let me think about that... 🧠',
      'Analyzing your request... 🔍',
      'Working on it, Boss... ⚡',
      'One moment, Sir... 🔄',
      'Calculating optimal response... 📊',
      'Accessing knowledge base... 📚',
      'Running neural networks... 🧬',
    ];
    return thinkingResponses[_chatHistory.length % thinkingResponses.length];
  }
}

class AIResponseFormatter {
  static String formatResponse(String response, {bool useHinglish = true, String? mood}) {
    if (!useHinglish) return response;
    
    // Mood-based prefix
    String prefix = '';
    if (mood == 'happy') {
      prefix = '😊 ';
    } else if (mood == 'sad') {
      prefix = '💙 ';
    } else if (mood == 'angry') {
      prefix = '🧘 ';
    } else if (mood == 'tired') {
      prefix = '💤 ';
    }
    
    response = prefix + response;
    
    // Ensure proper punctuation
    if (!response.endsWith('.') && !response.endsWith('!') && !response.endsWith('?') && response.length > 0) {
      response += '.';
    }
    
    return response;
  }
  
  static String simplifyForTTS(String response) {
    // Remove markdown and special characters for TTS
    response = response.replaceAll(RegExp(r'[*_~`]'), '');
    response = response.replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '');
    response = response.replaceAll(RegExp(r'<[^>]*>'), '');
    return response;
  }
  
  static String addEmojis(String response) {
    final emojiMap = {
      'hello': '👋',
      'hi': '👋',
      'namaste': '🙏',
      'thank': '🙏',
      'sorry': '🙏',
      'done': '✅',
      'complete': '✅',
      'error': '⚠️',
      'problem': '⚠️',
      'congrat': '🎉',
      'good': '👍',
      'great': '🔥',
      'amazing': '🤯',
      'love': '❤️',
      'like': '👍',
      'sad': '😢',
      'happy': '😊',
      'angry': '😠',
      'tired': '😴',
      'time': '⏰',
      'date': '📅',
      'weather': '🌤️',
      'news': '📰',
      'music': '🎵',
      'video': '🎬',
      'photo': '📷',
      'camera': '📸',
      'phone': '📱',
      'computer': '💻',
      'internet': '🌐',
      'wifi': '📶',
      'battery': '🔋',
      'flashlight': '🔦',
      'volume': '🔊',
      'brightness': '☀️',
      'lock': '🔒',
      'unlock': '🔓',
      'security': '🛡️',
      'vault': '🏦',
      'face': '👤',
      'voice': '🎤',
    };
    
    var result = response;
    for (var entry in emojiMap.entries) {
      if (result.toLowerCase().contains(entry.key)) {
        // Add emoji at the end if not already present
        if (!result.contains(entry.value)) {
          result = result.replaceFirst(RegExp(r'$'), ' $entry.value');
        }
        break;
      }
    }
    
    return result;
  }
}