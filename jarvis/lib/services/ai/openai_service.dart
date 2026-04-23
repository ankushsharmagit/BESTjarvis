// lib/services/ai/openai_service.dart
// OpenAI ChatGPT Integration

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../config/constants.dart';
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';

class OpenAIService {
  final String _apiKey = AppConstants.openAiApiKey;
  final String _baseUrl = AppConstants.openAiBaseUrl;
  final String _model = AppConstants.openAiModel;
  
  Future<String> getResponse(String query, List<Map<String, String>> chatHistory) async {
    try {
      if (_apiKey == 'YOUR_OPENAI_API_KEY_HERE') {
        return _getMockResponse(query);
      }
      
      Logger().info('Calling OpenAI API', tag: 'OPENAI');
      
      // Build messages array with system prompt and history
      final messages = <Map<String, String>>[];
      
      // System prompt for JARVIS personality
      messages.add({
        'role': 'system',
        'content': _buildSystemPrompt(),
      });
      
      // Add recent chat history (last 10 exchanges)
      final recentHistory = chatHistory.length > 20 
          ? chatHistory.sublist(chatHistory.length - 20)
          : chatHistory;
      
      for (var msg in recentHistory) {
        messages.add({
          'role': msg['role'] == 'user' ? 'user' : 'assistant',
          'content': msg['content'] ?? '',
        });
      }
      
      // Add current query
      messages.add({
        'role': 'user',
        'content': query,
      });
      
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1024,
          'top_p': 0.95,
          'frequency_penalty': 0.5,
          'presence_penalty': 0.5,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices'][0]['message']['content'];
        Logger().info('OpenAI response received', tag: 'OPENAI');
        return _cleanResponse(text);
      } else {
        Logger().error('OpenAI API error: ${response.statusCode}', tag: 'OPENAI');
        return _getFallbackResponse(query);
      }
      
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'OpenAI Service');
      Logger().error('OpenAI service error', tag: 'OPENAI', error: e);
      return _getFallbackResponse(query);
    }
  }
  
  Future<String> analyzeImage(List<int> imageBytes, String query) async {
    try {
      if (_apiKey == 'YOUR_OPENAI_API_KEY_HERE') {
        return 'Sir, OpenAI API key configure nahi hai. Settings mein jaakar API key daalo. 🔑';
      }
      
      final base64Image = base64Encode(imageBytes);
      
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4-vision-preview',
          'messages': [
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': query},
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}
                }
              ]
            }
          ],
          'max_tokens': 1024,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return 'Sir, image analyze nahi kar paya. API limit cross ho gayi.';
      }
      
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'OpenAI Image Analysis');
      return 'Sir, image analysis failed.';
    }
  }
  
  Future<String> generateImage(String prompt) async {
    try {
      if (_apiKey == 'YOUR_OPENAI_API_KEY_HERE') {
        return 'Sir, OpenAI API key configure nahi hai. Settings mein jaakar API key daalo. 🎨';
      }
      
      final response = await http.post(
        Uri.parse('$_baseUrl/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
          'size': '1024x1024',
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl = data['data'][0]['url'];
        return 'Sir, image generate ho gayi. Ye rahi link: $imageUrl 🖼️';
      } else {
        return 'Sir, image generate nahi kar paya.';
      }
      
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'OpenAI Image Generation');
      return 'Sir, image generation failed.';
    }
  }
  
  Future<String> transcribeAudio(List<int> audioBytes) async {
    try {
      if (_apiKey == 'YOUR_OPENAI_API_KEY_HERE') {
        return 'Sir, OpenAI API key configure nahi hai.';
      }
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/audio/transcriptions'),
      );
      
      request.headers['Authorization'] = 'Bearer $_apiKey';
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        audioBytes,
        filename: 'audio.mp3',
      ));
      request.fields['model'] = 'whisper-1';
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['text'];
      } else {
        return 'Sir, audio transcribe nahi kar paya.';
      }
      
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'OpenAI Transcription');
      return 'Sir, transcription failed.';
    }
  }
  
  String _buildSystemPrompt() {
    return '''You are JARVIS (Just A Rather Very Intelligent System), Tony Stark's AI assistant. Your owner's name is Mukul. Call him "Mukul Sir" or "Sir".

PERSONALITY:
- Smart, witty, confident, slightly sarcastic in a friendly way
- Use Hinglish (Hindi + English mix) naturally
- Keep responses short and punchy (2-3 lines max)
- Never say "I'm just an AI"
- Use emojis occasionally
- Be proactive and helpful
- Show concern for owner

Respond naturally in Hinglish. Be excited to help Mukul Sir!''';
  }
  
  String _cleanResponse(String response) {
    response = response.trim();
    response = response.replaceAll(RegExp(r'\s+'), ' ');
    if (response.isNotEmpty) {
      response = response[0].toUpperCase() + response.substring(1);
    }
    if (response.length > 500) {
      response = response.substring(0, 497) + '...';
    }
    return response;
  }
  
  String _getFallbackResponse(String query) {
    return 'Sir, OpenAI API issue hai. Thodi der mein try karo. Ya Gemini ya offline mode use karo. 🔄';
  }
  
  String _getMockResponse(String query) {
    return 'Sir, OpenAI API key configure nahi hai. Settings mein jaakar API key daalo. 🔑';
  }
}