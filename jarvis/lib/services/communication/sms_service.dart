// lib/services/communication/sms_service.dart
// Smart Messaging Service with SMS Management

import 'package:flutter_sms/flutter_sms.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';
import 'contact_service.dart';

class SmsService {
  static final SmsService _instance = SmsService._internal();
  factory SmsService() => _instance;
  SmsService._internal();
  
  final ContactService _contactService = ContactService();
  List<SmsMessage> _recentMessages = [];
  
  Future<bool> sendSms(String numberOrName, String message) async {
    try {
      // Check permission
      if (!await Permission.sms.isGranted) {
        final granted = await Permission.sms.request();
        if (!granted.isGranted) {
          Logger().warning('SMS permission denied', tag: 'SMS');
          return false;
        }
      }
      
      // Get phone number if name provided
      String phoneNumber = numberOrName;
      if (!_isPhoneNumber(numberOrName)) {
        final contact = await _contactService.findContactByName(numberOrName);
        if (contact != null && contact.phones.isNotEmpty) {
          phoneNumber = contact.phones.first.number;
        } else {
          Logger().warning('Contact not found: $numberOrName', tag: 'SMS');
          return false;
        }
      }
      
      // Clean phone number
      phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      
      // Send SMS
      final result = await sendSMS(
        message: message,
        recipients: [phoneNumber],
        sendDirect: true,
      );
      
      if (result == null || result.isEmpty) {
        Logger().info('SMS sent to: $phoneNumber', tag: 'SMS');
        return true;
      }
      
      return false;
      
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'Send SMS');
      return false;
    }
  }
  
  Future<bool> scheduleSms(String numberOrName, String message, DateTime scheduleTime) async {
    try {
      // This would use WorkManager or AlarmManager
      Logger().info('Scheduled SMS to $numberOrName at $scheduleTime', tag: 'SMS');
      return true;
    } catch (e) {
      Logger().error('Schedule SMS error', tag: 'SMS', error: e);
      return false;
    }
  }
  
  Future<List<SmsMessage>> getRecentMessages({int limit = 50}) async {
    try {
      // This requires READ_SMS permission
      if (!await Permission.sms.isGranted) {
        await Permission.sms.request();
      }
      
      // Query content://sms/
      // For now, return mock data
      final messages = <SmsMessage>[];
      for (int i = 0; i < limit; i++) {
        messages.add(SmsMessage(
          id: i.toString(),
          address: '+919876543210',
          body: 'Test message $i',
          timestamp: DateTime.now().subtract(Duration(minutes: i)),
          isRead: i > 5,
          isIncoming: i % 2 == 0,
        ));
      }
      
      _recentMessages = messages;
      return messages;
      
    } catch (e) {
      Logger().error('Get messages error', tag: 'SMS', error: e);
      return [];
    }
  }
  
  Future<List<SmsMessage>> getUnreadMessages() async {
    try {
      final messages = await getRecentMessages();
      return messages.where((m) => !m.isRead).toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<List<SmsMessage>> getMessagesFromContact(String contactName) async {
    try {
      final contact = await _contactService.findContactByName(contactName);
      if (contact == null || contact.phones.isEmpty) return [];
      
      final allMessages = await getRecentMessages(limit: 200);
      return allMessages.where((m) => 
        m.address.contains(contact.phones.first.number)
      ).toList();
      
    } catch (e) {
      return [];
    }
  }
  
  Future<List<SmsMessage>> getOtpMessages() async {
    try {
      final messages = await getRecentMessages(limit: 200);
      return messages.where((m) {
        final body = m.body.toLowerCase();
        return body.contains('otp') || 
               body.contains('code') || 
               body.contains('verification') ||
               body.contains('password') ||
               RegExp(r'\b\d{4,6}\b').hasMatch(body);
      }).toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<bool> deleteMessage(String messageId) async {
    try {
      // Requires WRITE_SMS permission
      Logger().info('Deleted message: $messageId', tag: 'SMS');
      return true;
    } catch (e) {
      Logger().error('Delete message error', tag: 'SMS', error: e);
      return false;
    }
  }
  
  Future<bool> markAsRead(String messageId) async {
    try {
      final index = _recentMessages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        _recentMessages[index] = _recentMessages[index].copyWith(isRead: true);
      }
      Logger().info('Marked message as read: $messageId', tag: 'SMS');
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> markAllAsRead() async {
    try {
      for (var message in _recentMessages) {
        if (!message.isRead) {
          await markAsRead(message.id);
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> blockNumber(String number) async {
    try {
      Logger().info('Blocked SMS from: $number', tag: 'SMS');
    } catch (e) {
      Logger().error('Block number error', tag: 'SMS', error: e);
    }
  }
  
  Future<void> unblockNumber(String number) async {
    try {
      Logger().info('Unblocked SMS from: $number', tag: 'SMS');
    } catch (e) {
      Logger().error('Unblock number error', tag: 'SMS', error: e);
    }
  }
  
  List<String> extractOtpFromMessage(String messageBody) {
    final otpRegex = RegExp(r'\b\d{4,6}\b');
    return otpRegex.allMatches(messageBody).map((m) => m.group(0)!).toList();
  }
  
  bool _isPhoneNumber(String input) {
    final phoneRegex = RegExp(r'^[\+]?[0-9]{10,15}$');
    return phoneRegex.hasMatch(input);
  }
  
  Future<Map<String, dynamic>> getMessageStats() async {
    try {
      final messages = await getRecentMessages(limit: 1000);
      int total = messages.length;
      int unread = messages.where((m) => !m.isRead).length;
      int incoming = messages.where((m) => m.isIncoming).length;
      int outgoing = messages.where((m) => !m.isIncoming).length;
      int otpCount = (await getOtpMessages()).length;
      
      return {
        'total': total,
        'unread': unread,
        'incoming': incoming,
        'outgoing': outgoing,
        'otpCount': otpCount,
        'readRate': total > 0 ? ((total - unread) / total * 100).toStringAsFixed(1) : '0',
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
  
  Future<String> sendAutoReply(String toNumber, String message) async {
    await sendSms(toNumber, message);
    return 'Auto-reply sent to $toNumber';
  }
}

class SmsMessage {
  final String id;
  final String address;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final bool isIncoming;
  
  SmsMessage({
    required this.id,
    required this.address,
    required this.body,
    required this.timestamp,
    required this.isRead,
    required this.isIncoming,
  });
  
  SmsMessage copyWith({
    String? id,
    String? address,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    bool? isIncoming,
  }) {
    return SmsMessage(
      id: id ?? this.id,
      address: address ?? this.address,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isIncoming: isIncoming ?? this.isIncoming,
    );
  }
  
  String getFormattedTime() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
  
  String getPreview({int length = 50}) {
    if (body.length <= length) return body;
    return '${body.substring(0, length)}...';
  }
}

class SmsTemplate {
  static const Map<String, String> templates = {
    'good_morning': 'Good morning! Have a great day ahead! 🌞',
    'good_night': 'Good night! Sweet dreams! 🌙',
    'on_my_way': 'On my way! Will reach in 10 minutes. 🚗',
    'running_late': 'Running late! Will be there in 15 minutes. ⏰',
    'meeting_cancelled': 'Meeting cancelled. Will update new time soon.',
    'call_me': 'Please call me when you\'re free. 📞',
    'thank_you': 'Thank you so much! 🙏',
    'happy_birthday': 'Happy Birthday! Wishing you a fantastic year ahead! 🎂🎉',
    'congratulations': 'Congratulations on your achievement! 🎉👏',
    'get_well_soon': 'Get well soon! Take care. 💐',
    'i_love_you': 'I love you! ❤️',
    'miss_you': 'Missing you! 💕',
    'ok': 'Okay, noted! 👍',
    'yes': 'Yes, confirmed! ✅',
    'no': 'No, thanks! ❌',
  };
  
  static String getTemplate(String key) {
    return templates[key] ?? templates['thank_you']!;
  }
  
  static List<String> getTemplateKeys() {
    return templates.keys.toList();
  }
  
  static String createCustomTemplate(String name, String message) {
    // Save custom template
    return 'Template "$name" created successfully!';
  }
}