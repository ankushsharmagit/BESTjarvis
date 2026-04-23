// lib/services/ai/gemini_service.dart
// Google Gemini AI Integration - WITH YOUR API KEY

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/constants.dart';
import '../../utils/logger.dart';

class GeminiService {
  final String _apiKey = AppConstants.geminiApiKey;
  final String _baseUrl = '${AppConstants.geminiBaseUrl}/models/${AppConstants.geminiModel}:generateContent';
  
  Future<String> getResponse(String query, List<Map<String, String>> chatHistory) async {
    try {
      Logger().info('Calling Gemini API...', tag: 'GEMINI');
      
      final systemPrompt = _buildSystemPrompt();
      
      final messages = <Map<String, dynamic>>[];
      messages.add({
        'role': 'user',
        'parts': [{'text': systemPrompt}]
      });
      
      // Add chat history
      final recentHistory = chatHistory.length > 20 
          ? chatHistory.sublist(chatHistory.length - 20)
          : chatHistory;
      
      for (var i = 0; i < recentHistory.length; i += 2) {
        if (i + 1 < recentHistory.length) {
          messages.add({
            'role': 'user',
            'parts': [{'text': recentHistory[i]['content']}]
          });
          messages.add({
            'role': 'model',
            'parts': [{'text': recentHistory[i + 1]['content']}]
          });
        }
      }
      
      messages.add({
        'role': 'user',
        'parts': [{'text': query}]
      });
      
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': messages,
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        Logger().info('Gemini response received', tag: 'GEMINI');
        return _cleanResponse(text);
      } else {
        Logger().error('Gemini API error: ${response.statusCode}', tag: 'GEMINI');
        return _getFallbackResponse(query);
      }
      
    } catch (e) {
      Logger().error('Gemini service error', tag: 'GEMINI', error: e);
      return _getFallbackResponse(query);
    }
  }
  
  String _buildSystemPrompt() {
    return '''You are JARVIS, Tony Stark's AI assistant. Your owner's name is Mukul. Call him "Mukul Sir". Be witty, confident, and helpful. Use Hinglish (Hindi+English mix). Keep responses short and crisp. Never say you're an AI. Be excited to help!''';
  }
  
  String _cleanResponse(String response) {
    response = response.trim();
    if (response.isNotEmpty) {
      response = response[0].toUpperCase() + response.substring(1);
    }
    return response;
  }
  
  String _getFallbackResponse(String query) {
    return 'Sir, main aapki baat samajh gaya. Lekin abhi main demo mode mein hu. Internet check karo aur dobara try karo. 🔥';
  }
}