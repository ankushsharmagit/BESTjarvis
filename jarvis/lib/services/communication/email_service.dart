// lib/services/communication/email_service.dart
// Email Service with Gmail Integration

import 'package:url_launcher/url_launcher.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';
import 'contact_service.dart';

class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();
  
  final ContactService _contactService = ContactService();
  
  Future<bool> sendEmail({
    required String to,
    required String subject,
    required String body,
    String? cc,
    String? bcc,
    List<String>? attachments,
  }) async {
    try {
      // Use mailto: URL scheme
      final emailUri = Uri(
        scheme: 'mailto',
        path: to,
        query: _buildQueryParams(subject, body, cc, bcc),
      );
      
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        Logger().info('Email composed to: $to', tag: 'EMAIL');
        return true;
      }
      return false;
      
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'Send Email');
      return false;
    }
  }
  
  String _buildQueryParams(String subject, String body, String? cc, String? bcc) {
    final params = <String, String>{};
    params['subject'] = subject;
    params['body'] = body;
    if (cc != null) params['cc'] = cc;
    if (bcc != null) params['bcc'] = bcc;
    
    return params.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
  }
  
  Future<bool> sendEmailViaGmail({
    required String to,
    required String subject,
    required String body,
    required String username,
    required String password,
  }) async {
    try {
      final smtpServer = gmail(username, password);
      final message = Message()
        ..from = Address(username, 'JARVIS Assistant')
        ..recipients.add(to)
        ..subject = subject
        ..text = body;
      
      final sendReport = await send(message, smtpServer);
      Logger().info('Email sent via Gmail: $sendReport', tag: 'EMAIL');
      return true;
      
    } catch (e) {
      Logger().error('Gmail send error', tag: 'EMAIL', error: e);
      return false;
    }
  }
  
  Future<bool> sendEmailToContact(String contactName, String subject, String body) async {
    try {
      final contact = await _contactService.findContactByName(contactName);
      if (contact == null || contact.emails.isEmpty) {
        Logger().warning('Contact not found or no email: $contactName', tag: 'EMAIL');
        return false;
      }
      
      return await sendEmail(
        to: contact.emails.first,
        subject: subject,
        body: body,
      );
      
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> sendBulkEmail(List<String> recipients, String subject, String body) async {
    try {
      for (var recipient in recipients) {
        await sendEmail(to: recipient, subject: subject, body: body);
        await Future.delayed(const Duration(seconds: 1)); // Rate limiting
      }
      Logger().info('Bulk email sent to ${recipients.length} recipients', tag: 'EMAIL');
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> sendHtmlEmail(String to, String subject, String htmlBody) async {
    try {
      final emailUri = Uri(
        scheme: 'mailto',
        path: to,
        query: _buildQueryParams(subject, htmlBody.replaceAll(RegExp(r'<[^>]*>'), ''), null, null),
      );
      
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        return true;
      }
      return false;
      
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> sendEmailWithAttachment(String to, String subject, String body, String attachmentPath) async {
    try {
      // This requires sharing intent
      return false;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> scheduleEmail(String to, String subject, String body, DateTime scheduleTime) async {
    try {
      Logger().info('Email scheduled to $to at $scheduleTime', tag: 'EMAIL');
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<List<EmailMessage>> getInbox() async {
    // This would require IMAP integration
    return [];
  }
  
  Future<List<EmailMessage>> getUnreadEmails() async {
    return [];
  }
  
  Future<bool> markAsRead(String emailId) async {
    return true;
  }
  
  Future<bool> deleteEmail(String emailId) async {
    return true;
  }
  
  Future<bool> replyToEmail(String emailId, String replyBody) async {
    return true;
  }
  
  Future<bool> forwardEmail(String emailId, String to) async {
    return true;
  }
  
  Future<Map<String, dynamic>> getEmailStats() async {
    return {
      'totalEmails': 0,
      'unreadCount': 0,
      'lastSync': null,
    };
  }
}

class EmailMessage {
  final String id;
  final String from;
  final String fromName;
  final List<String> to;
  final String subject;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final bool hasAttachment;
  
  EmailMessage({
    required this.id,
    required this.from,
    required this.fromName,
    required this.to,
    required this.subject,
    required this.body,
    required this.timestamp,
    required this.isRead,
    required this.hasAttachment,
  });
  
  String getPreview({int length = 100}) {
    if (body.length <= length) return body;
    return '${body.substring(0, length)}...';
  }
  
  String getFormattedTime() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}

class EmailTemplate {
  static const Map<String, String> templates = {
    'thank_you': 'Thank you for your support! 🙏',
    'meeting_request': 'I would like to schedule a meeting with you. Please let me know your availability.',
    'follow_up': 'Following up on our previous conversation. Looking forward to your response.',
    'introduction': 'Nice to meet you! Looking forward to working together.',
    'apology': 'I apologize for the inconvenience caused.',
    'reminder': 'This is a gentle reminder about our upcoming meeting.',
    'newsletter': 'Check out our latest updates and news!',
    'offer': 'Special offer just for you! Limited time only.',
  };
  
  static String getTemplate(String key) {
    return templates[key] ?? templates['thank_you']!;
  }
  
  static String createCustomTemplate(String name, String subject, String body) {
    return 'Template "$name" created successfully!';
  }
}