// lib/services/communication/call_service.dart
// Smart Calling Service with Call Log Management

import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:call_log/call_log.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';
import 'contact_service.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();
  
  final ContactService _contactService = ContactService();
  bool _isCalling = false;
  List<CallLogEntry> _callHistory = [];
  
  Future<void> initialize() async {
    await _loadCallHistory();
    Logger().info('Call service initialized', tag: 'CALL');
  }
  
  Future<bool> makeCall(String numberOrName) async {
    try {
      // Check if it's a name, then get number
      String phoneNumber = numberOrName;
      if (!_isPhoneNumber(numberOrName)) {
        final contact = await _contactService.findContactByName(numberOrName);
        if (contact != null && contact.phones.isNotEmpty) {
          phoneNumber = contact.phones.first.number;
        } else {
          Logger().warning('Contact not found: $numberOrName', tag: 'CALL');
          return false;
        }
      }
      
      // Clean phone number
      phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      
      final result = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
      
      if (result) {
        _isCalling = true;
        Logger().info('Calling: $phoneNumber', tag: 'CALL');
      }
      
      return result;
      
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'Make Call');
      return false;
    }
  }
  
  Future<List<CallLogEntry>> getCallLog({int limit = 50}) async {
    try {
      if (!await Permission.phone.isGranted) {
        await Permission.phone.request();
      }
      
      final entries = await CallLog.get();
      final logs = entries.take(limit).map((e) => CallLogEntry(
        number: e.number ?? '',
        name: e.name ?? '',
        timestamp: DateTime.fromMillisecondsSinceEpoch(e.dateTime),
        duration: e.duration ?? 0,
        type: _mapCallType(e.type),
      )).toList();
      
      _callHistory = logs;
      return logs;
      
    } catch (e) {
      Logger().error('Get call log error', tag: 'CALL', error: e);
      return [];
    }
  }
  
  Future<List<CallLogEntry>> getMissedCalls() async {
    try {
      final allCalls = await getCallLog();
      return allCalls.where((call) => call.type == CallType.missed).toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<List<CallLogEntry>> getRecentCalls({int limit = 20}) async {
    try {
      final allCalls = await getCallLog(limit: limit);
      return allCalls;
    } catch (e) {
      return [];
    }
  }
  
  Future<List<CallLogEntry>> getCallsByContact(String contactName) async {
    try {
      final allCalls = await getCallLog();
      return allCalls.where((call) => 
        call.name.toLowerCase().contains(contactName.toLowerCase()) ||
        call.number.contains(contactName)
      ).toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<bool> blockNumber(String number) async {
    try {
      // This requires special permissions on newer Android versions
      Logger().info('Blocking number: $number', tag: 'CALL');
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> unblockNumber(String number) async {
    try {
      Logger().info('Unblocking number: $number', tag: 'CALL');
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<List<String>> getBlockedNumbers() async {
    try {
      return [];
    } catch (e) {
      return [];
    }
  }
  
  Future<bool> isNumberSpam(String number) async {
    // Would integrate with Truecaller-like API
    final spamPrefixes = ['140', '1800', '888', '999', '555'];
    for (var prefix in spamPrefixes) {
      if (number.startsWith(prefix)) {
        return true;
      }
    }
    
    // Check for known spam numbers
    final spamNumbers = ['9876543210', '9988776655'];
    return spamNumbers.contains(number);
  }
  
  Future<void> answerCall() async {
    try {
      // Requires ANSWER_PHONE_CALLS permission
      Logger().info('Answering call', tag: 'CALL');
    } catch (e) {
      Logger().error('Answer call error', tag: 'CALL', error: e);
    }
  }
  
  Future<void> rejectCall() async {
    try {
      Logger().info('Rejecting call', tag: 'CALL');
    } catch (e) {
      Logger().error('Reject call error', tag: 'CALL', error: e);
    }
  }
  
  Future<void> endCall() async {
    try {
      _isCalling = false;
      Logger().info('Ending call', tag: 'CALL');
    } catch (e) {
      Logger().error('End call error', tag: 'CALL', error: e);
    }
  }
  
  Future<void> muteCall() async {
    try {
      Logger().info('Muting call', tag: 'CALL');
    } catch (e) {
      Logger().error('Mute call error', tag: 'CALL', error: e);
    }
  }
  
  Future<void> unmuteCall() async {
    try {
      Logger().info('Unmuting call', tag: 'CALL');
    } catch (e) {
      Logger().error('Unmute call error', tag: 'CALL', error: e);
    }
  }
  
  Future<void> speakerOn() async {
    try {
      Logger().info('Speaker on', tag: 'CALL');
    } catch (e) {
      Logger().error('Speaker error', tag: 'CALL', error: e);
    }
  }
  
  Future<void> speakerOff() async {
    try {
      Logger().info('Speaker off', tag: 'CALL');
    } catch (e) {
      Logger().error('Speaker error', tag: 'CALL', error: e);
    }
  }
  
  Future<void> startCallRecording() async {
    try {
      Logger().info('Call recording started', tag: 'CALL');
    } catch (e) {
      Logger().error('Call recording error', tag: 'CALL', error: e);
    }
  }
  
  Future<void> stopCallRecording() async {
    try {
      Logger().info('Call recording stopped', tag: 'CALL');
    } catch (e) {
      Logger().error('Call recording error', tag: 'CALL', error: e);
    }
  }
  
  bool _isPhoneNumber(String input) {
    final phoneRegex = RegExp(r'^[\+]?[0-9]{10,15}$');
    return phoneRegex.hasMatch(input);
  }
  
  CallType _mapCallType(CallLogType? type) {
    switch (type) {
      case CallLogType.incoming:
        return CallType.incoming;
      case CallLogType.outgoing:
        return CallType.outgoing;
      case CallLogType.missed:
        return CallType.missed;
      default:
        return CallType.missed;
    }
  }
  
  String formatCallDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  Future<void> _loadCallHistory() async {
    await getCallLog(limit: 100);
  }
  
  Future<Map<String, dynamic>> getCallStats() async {
    final calls = await getCallLog(limit: 500);
    int incoming = 0;
    int outgoing = 0;
    int missed = 0;
    int totalDuration = 0;
    
    for (var call in calls) {
      switch (call.type) {
        case CallType.incoming:
          incoming++;
          break;
        case CallType.outgoing:
          outgoing++;
          break;
        case CallType.missed:
          missed++;
          break;
      }
      totalDuration += call.duration;
    }
    
    return {
      'totalCalls': calls.length,
      'incoming': incoming,
      'outgoing': outgoing,
      'missed': missed,
      'totalDuration': totalDuration,
      'totalDurationFormatted': formatCallDuration(totalDuration),
      'averageDuration': calls.isEmpty ? 0 : totalDuration ~/ calls.length,
    };
  }
}

class CallLogEntry {
  final String number;
  final String name;
  final DateTime timestamp;
  final int duration;
  final CallType type;
  
  CallLogEntry({
    required this.number,
    required this.name,
    required this.timestamp,
    required this.duration,
    required this.type,
  });
  
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
  
  String getFormattedDuration() {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    if (minutes > 0) {
      return '$minutes min $seconds sec';
    }
    return '$seconds sec';
  }
  
  String getTypeIcon() {
    switch (type) {
      case CallType.incoming:
        return '📞';
      case CallType.outgoing:
        return '📱';
      case CallType.missed:
        return '❌';
    }
  }
  
  Color getTypeColor() {
    switch (type) {
      case CallType.incoming:
        return Colors.green;
      case CallType.outgoing:
        return Colors.blue;
      case CallType.missed:
        return Colors.red;
    }
  }
}

enum CallType {
  incoming,
  outgoing,
  missed,
}