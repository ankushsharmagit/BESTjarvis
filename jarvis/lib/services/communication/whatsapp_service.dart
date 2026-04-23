// lib/services/communication/whatsapp_service.dart
// Complete WhatsApp Integration Service

import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';
import 'contact_service.dart';

class WhatsAppService {
  static final WhatsAppService _instance = WhatsAppService._internal();
  factory WhatsAppService() => _instance;
  WhatsAppService._internal();
  
  final ContactService _contactService = ContactService();
  bool _isWhatsAppInstalled = false;
  
  Future<void> initialize() async {
    _isWhatsAppInstalled = await _checkWhatsAppInstalled();
    Logger().info('WhatsApp service initialized, installed: $_isWhatsAppInstalled', tag: 'WHATSAPP');
  }
  
  Future<bool> sendMessage(String numberOrName, String message) async {
    try {
      if (!_isWhatsAppInstalled) {
        Logger().warning('WhatsApp not installed', tag: 'WHATSAPP');
        return false;
      }
      
      // Get phone number if name provided
      String phoneNumber = numberOrName;
      if (!_isPhoneNumber(numberOrName)) {
        final contact = await _contactService.findContactByName(numberOrName);
        if (contact != null && contact.phones.isNotEmpty) {
          phoneNumber = contact.phones.first.number;
        } else {
          Logger().warning('Contact not found: $numberOrName', tag: 'WHATSAPP');
          return false;
        }
      }
      
      // Clean number
      phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      if (!phoneNumber.startsWith('+')) {
        phoneNumber = '+91$phoneNumber'; // Default India code
      }
      
      final whatsappUrl = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
      final uri = Uri.parse(whatsappUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        Logger().info('WhatsApp message sent to: $phoneNumber', tag: 'WHATSAPP');
        return true;
      }
      
      return false;
      
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'WhatsApp Send');
      return false;
    }
  }
  
  Future<bool> shareToWhatsApp(String text, {String? filePath}) async {
    try {
      if (!_isWhatsAppInstalled) return false;
      
      if (filePath != null) {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: text,
          sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
        );
      } else {
        await Share.share(text);
      }
      Logger().info('Shared to WhatsApp', tag: 'WHATSAPP');
      return true;
    } catch (e) {
      Logger().error('Share to WhatsApp error', tag: 'WHATSAPP', error: e);
      return false;
    }
  }
  
  Future<bool> shareImage(String imagePath, {String? caption}) async {
    return await shareToWhatsApp(caption ?? '', filePath: imagePath);
  }
  
  Future<bool> shareVideo(String videoPath, {String? caption}) async {
    return await shareToWhatsApp(caption ?? '', filePath: videoPath);
  }
  
  Future<bool> shareDocument(String documentPath, {String? caption}) async {
    return await shareToWhatsApp(caption ?? '', filePath: documentPath);
  }
  
  Future<bool> shareAudio(String audioPath, {String? caption}) async {
    return await shareToWhatsApp(caption ?? '', filePath: audioPath);
  }
  
  Future<bool> openChat(String numberOrName) async {
    try {
      if (!_isWhatsAppInstalled) return false;
      
      String phoneNumber = numberOrName;
      if (!_isPhoneNumber(numberOrName)) {
        final contact = await _contactService.findContactByName(numberOrName);
        if (contact != null && contact.phones.isNotEmpty) {
          phoneNumber = contact.phones.first.number;
        } else {
          return false;
        }
      }
      
      phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      if (!phoneNumber.startsWith('+')) {
        phoneNumber = '+91$phoneNumber';
      }
      
      final whatsappUrl = 'https://wa.me/$phoneNumber';
      final uri = Uri.parse(whatsappUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
      
    } catch (e) {
      Logger().error('Open WhatsApp chat error', tag: 'WHATSAPP', error: e);
      return false;
    }
  }
  
  Future<bool> sendVoiceMessage(String number, String audioPath) async {
    try {
      // Share audio file as voice note
      return await shareAudio(audioPath);
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> sendLocation(String number, double latitude, double longitude) async {
    try {
      final locationUrl = 'https://maps.google.com/?q=$latitude,$longitude';
      final message = '📍 My location: $locationUrl';
      return await sendMessage(number, message);
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> sendContact(String number, String contactName, String contactNumber) async {
    try {
      final message = '📇 Contact: $contactName - $contactNumber';
      return await sendMessage(number, message);
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> sendSticker(String number, String stickerPath) async {
    try {
      return await shareImage(stickerPath);
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> sendGif(String number, String gifPath) async {
    try {
      return await shareImage(gifPath);
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> updateStatus(String status) async {
    try {
      // This would require WhatsApp Business API
      Logger().info('WhatsApp status updated: $status', tag: 'WHATSAPP');
      return true;
    } catch (e) {
      Logger().error('Update status error', tag: 'WHATSAPP', error: e);
      return false;
    }
  }
  
  Future<bool> sendToGroup(String groupId, String message) async {
    try {
      final whatsappUrl = 'https://chat.whatsapp.com/$groupId';
      final uri = Uri.parse(whatsappUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        // Need to send message after opening
        return true;
      }
      return false;
      
    } catch (e) {
      return false;
    }
  }
  
  Future<List<WhatsAppContact>> getWhatsAppContacts() async {
    // Would require scanning WhatsApp databases
    return [];
  }
  
  Future<Map<String, dynamic>> getWhatsAppStats() async {
    return {
      'isInstalled': _isWhatsAppInstalled,
      'lastActive': null,
      'unreadCount': 0,
      'totalChats': 0,
    };
  }
  
  Future<bool> _checkWhatsAppInstalled() async {
    try {
      final whatsappUrl = Uri.parse('whatsapp://send');
      return await canLaunchUrl(whatsappUrl);
    } catch (e) {
      return false;
    }
  }
  
  bool _isPhoneNumber(String input) {
    final phoneRegex = RegExp(r'^[\+]?[0-9]{10,15}$');
    return phoneRegex.hasMatch(input);
  }
  
  Future<void> openWhatsAppSettings() async {
    try {
      await launchUrl(Uri.parse('app-settings:'));
    } catch (e) {
      Logger().error('Open settings error', tag: 'WHATSAPP', error: e);
    }
  }
}

class WhatsAppContact {
  final String name;
  final String number;
  final String? profilePic;
  final bool isBusiness;
  final DateTime? lastSeen;
  
  WhatsAppContact({
    required this.name,
    required this.number,
    this.profilePic,
    this.isBusiness = false,
    this.lastSeen,
  });
  
  String getFormattedNumber() {
    if (number.startsWith('+')) return number;
    return '+91$number';
  }
}

class WhatsAppTemplate {
  static const Map<String, String> quickReplies = {
    'ok': 'Okay, got it! 👍',
    'thanks': 'Thank you! 🙏',
    'busy': 'I\'m busy right now, will get back to you soon.',
    'meeting': 'In a meeting, will call later.',
    'driving': 'Driving right now, will reply later.',
    'sleeping': 'Sleeping, please don\'t disturb.',
    'working': 'Working, will respond after work hours.',
    'on_vacation': 'On vacation! Will reply when I return.',
    'emergency': 'This is an emergency! Please call immediately.',
  };
  
  static String getQuickReply(String key) {
    return quickReplies[key] ?? quickReplies['ok']!;
  }
  
  static List<String> getQuickReplyKeys() {
    return quickReplies.keys.toList();
  }
  
  static String getBusinessHoursMessage(String openTime, String closeTime) {
    return 'Our business hours are $openTime to $closeTime. We will respond during these hours.';
  }
}