// lib/services/communication/telegram_service.dart
// Complete Telegram Bot Integration Service

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';

class TelegramService {
  static final TelegramService _instance = TelegramService._internal();
  factory TelegramService() => _instance;
  TelegramService._internal();
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _botToken;
  String? _botUsername;
  bool _isConnected = false;
  
  Future<void> initialize() async {
    await _loadBotToken();
    if (_botToken != null && _botToken!.isNotEmpty && _botToken != 'YOUR_TELEGRAM_BOT_TOKEN_HERE') {
      await _verifyBot();
    }
    Logger().info('Telegram service initialized, connected: $_isConnected', tag: 'TELEGRAM');
  }
  
  Future<void> _loadBotToken() async {
    _botToken = await _secureStorage.read(key: 'telegram_bot_token');
  }
  
  Future<void> saveBotToken(String token) async {
    _botToken = token;
    await _secureStorage.write(key: 'telegram_bot_token', value: token);
    await _verifyBot();
    Logger().info('Telegram bot token saved', tag: 'TELEGRAM');
  }
  
  Future<bool> _verifyBot() async {
    if (_botToken == null || _botToken!.isEmpty) {
      _isConnected = false;
      return false;
    }
    
    try {
      final response = await http.get(
        Uri.parse('https://api.telegram.org/bot${_botToken}/getMe'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          _botUsername = data['result']['username'];
          _isConnected = true;
          Logger().info('Telegram bot verified: @$_botUsername', tag: 'TELEGRAM');
          return true;
        }
      }
      _isConnected = false;
      return false;
      
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }
  
  Future<bool> sendMessage(String chatId, String message) async {
    if (!_isConnected) return false;
    
    try {
      final response = await http.post(
        Uri.parse('https://api.telegram.org/bot${_botToken}/sendMessage'),
        body: {
          'chat_id': chatId,
          'text': message,
          'parse_mode': 'HTML',
        },
      );
      
      return response.statusCode == 200;
      
    } catch (e) {
      Logger().error('Send message error', tag: 'TELEGRAM', error: e);
      return false;
    }
  }
  
  Future<bool> sendPhoto(String chatId, String photoPath, {String? caption}) async {
    if (!_isConnected) return false;
    
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.telegram.org/bot${_botToken}/sendPhoto'),
      );
      
      request.fields['chat_id'] = chatId;
      if (caption != null) request.fields['caption'] = caption;
      request.files.add(await http.MultipartFile.fromPath('photo', photoPath));
      
      var response = await request.send();
      return response.statusCode == 200;
      
    } catch (e) {
      Logger().error('Send photo error', tag: 'TELEGRAM', error: e);
      return false;
    }
  }
  
  Future<bool> isConnected() async {
    return _isConnected;
  }
  
  String? getBotUsername() => _botUsername;
}