// lib/models/chat_message.dart
// Chat Message Model for Conversation History

import 'package:flutter/material.dart';

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isFromUser;
  final String? commandCategory;
  final bool isTyping;
  final MessageStatus status;
  final String? senderName;
  final String? senderAvatar;
  
  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.isFromUser,
    this.commandCategory,
    this.isTyping = false,
    this.status = MessageStatus.sent,
    this.senderName,
    this.senderAvatar,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'type': type.index,
      'timestamp': timestamp.toIso8601String(),
      'isFromUser': isFromUser ? 1 : 0,
      'commandCategory': commandCategory,
      'status': status.index,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
    };
  }
  
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      content: map['content'],
      type: MessageType.values[map['type']],
      timestamp: DateTime.parse(map['timestamp']),
      isFromUser: map['isFromUser'] == 1,
      commandCategory: map['commandCategory'],
      status: MessageStatus.values[map['status']],
      senderName: map['senderName'],
      senderAvatar: map['senderAvatar'],
    );
  }
  
  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isFromUser,
    String? commandCategory,
    bool? isTyping,
    MessageStatus? status,
    String? senderName,
    String? senderAvatar,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isFromUser: isFromUser ?? this.isFromUser,
      commandCategory: commandCategory ?? this.commandCategory,
      isTyping: isTyping ?? this.isTyping,
      status: status ?? this.status,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
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
}

enum MessageType {
  text,
  command,
  response,
  info,
  error,
  warning,
  success,
  thinking,
  voice,
  image,
  file,
  telegram,
  whatsapp,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
  seen,
}

class MessageBubbleStyle {
  static const userBubbleColor = Color(0xFF0088FF);
  static const jarvisBubbleColor = Color(0xFF16213E);
  static const errorBubbleColor = Color(0xFF330000);
  static const warningBubbleColor = Color(0xFF332200);
  static const successBubbleColor = Color(0xFF003300);
  static const infoBubbleColor = Color(0xFF001133);
  static const telegramBubbleColor = Color(0xFF1A3A5C);
  static const whatsappBubbleColor = Color(0xFF1A5C3A);
  
  static const userTextColor = Colors.white;
  static const jarvisTextColor = Colors.white;
  static const timestampColor = Color(0xFFB0BEC5);
  
  static const borderRadius = 20.0;
  static const maxWidth = 0.8;
}

class ConversationContext {
  String lastTopic;
  List<String> previousCommands;
  Map<String, dynamic> userPreferences;
  DateTime lastInteraction;
  int conversationTurn;
  Map<String, dynamic> lastResponse;
  List<String> pendingQuestions;
  
  ConversationContext({
    this.lastTopic = '',
    this.previousCommands = const [],
    this.userPreferences = const {},
    required this.lastInteraction,
    this.conversationTurn = 0,
    this.lastResponse = const {},
    this.pendingQuestions = const [],
  });
  
  void addCommand(String command) {
    previousCommands.add(command);
    if (previousCommands.length > 20) {
      previousCommands.removeAt(0);
    }
    conversationTurn++;
    lastInteraction = DateTime.now();
  }
  
  String getLastCommand() {
    return previousCommands.isNotEmpty ? previousCommands.last : '';
  }
  
  String getPreviousCommand(int index) {
    if (index < previousCommands.length) {
      return previousCommands[previousCommands.length - 1 - index];
    }
    return '';
  }
  
  void addResponse(String response, {String? topic}) {
    lastResponse = {
      'content': response,
      'topic': topic ?? lastTopic,
      'timestamp': DateTime.now().toIso8601String(),
    };
    if (topic != null) {
      lastTopic = topic;
    }
  }
  
  void addPendingQuestion(String question) {
    pendingQuestions.add(question);
  }
  
  String? getNextPendingQuestion() {
    if (pendingQuestions.isNotEmpty) {
      return pendingQuestions.removeAt(0);
    }
    return null;
  }
  
  void clear() {
    lastTopic = '';
    previousCommands.clear();
    conversationTurn = 0;
    pendingQuestions.clear();
  }
  
  Map<String, dynamic> toMap() {
    return {
      'lastTopic': lastTopic,
      'previousCommands': previousCommands,
      'userPreferences': userPreferences,
      'lastInteraction': lastInteraction.toIso8601String(),
      'conversationTurn': conversationTurn,
      'lastResponse': lastResponse,
      'pendingQuestions': pendingQuestions,
    };
  }
  
  factory ConversationContext.fromMap(Map<String, dynamic> map) {
    return ConversationContext(
      lastTopic: map['lastTopic'] ?? '',
      previousCommands: List<String>.from(map['previousCommands'] ?? []),
      userPreferences: map['userPreferences'] ?? {},
      lastInteraction: DateTime.parse(map['lastInteraction']),
      conversationTurn: map['conversationTurn'] ?? 0,
      lastResponse: map['lastResponse'] ?? {},
      pendingQuestions: List<String>.from(map['pendingQuestions'] ?? []),
    );
  }
}

class MoodAnalysis {
  final MoodType mood;
  final double confidence;
  final List<String> keywords;
  final String suggestedResponse;
  
  MoodAnalysis({
    required this.mood,
    required this.confidence,
    required this.keywords,
    required this.suggestedResponse,
  });
  
  factory MoodAnalysis.fromText(String text) {
    final lowerText = text.toLowerCase();
    
    if (lowerText.contains('sad') || lowerText.contains('depressed') || 
        lowerText.contains('upset') || lowerText.contains('gum') ||
        lowerText.contains('dukh') || lowerText.contains('bura')) {
      return MoodAnalysis(
        mood: MoodType.sad,
        confidence: 0.85,
        keywords: ['sad', 'depressed', 'upset', 'dukh', 'bura'],
        suggestedResponse: 'Sir, main aapke saath hu. Kuch share karna chahenge? Main sun sakta hu. 💙',
      );
    }
    
    if (lowerText.contains('angry') || lowerText.contains('frustrated') ||
        lowerText.contains('gussa') || lowerText.contains('naraaz') ||
        lowerText.contains('annoyed')) {
      return MoodAnalysis(
        mood: MoodType.angry,
        confidence: 0.80,
        keywords: ['angry', 'gussa', 'naraaz', 'frustrated'],
        suggestedResponse: 'Sir, calm down. Main aapki help kar raha hu. Kya problem hai? 🧘',
      );
    }
    
    if (lowerText.contains('happy') || lowerText.contains('excited') ||
        lowerText.contains('great') || lowerText.contains('awesome') ||
        lowerText.contains('khush') || lowerText.contains('mast')) {
      return MoodAnalysis(
        mood: MoodType.happy,
        confidence: 0.90,
        keywords: ['happy', 'great', 'awesome', 'khush', 'mast'],
        suggestedResponse: 'Bahut badhiya Sir! Main bhi khush hu. Aage bolo! 😊',
      );
    }
    
    if (lowerText.contains('tired') || lowerText.contains('exhausted') ||
        lowerText.contains('sleepy') || lowerText.contains('thak') ||
        lowerText.contains('neend')) {
      return MoodAnalysis(
        mood: MoodType.tired,
        confidence: 0.85,
        keywords: ['tired', 'sleepy', 'thak', 'neend'],
        suggestedResponse: 'Sir, aap thak gaye lag rahe ho. Rest karo. Main alarm laga du? 💤',
      );
    }
    
    if (lowerText.contains('stressed') || lowerText.contains('anxious') ||
        lowerText.contains('worry') || lowerText.contains('tension') ||
        lowerText.contains('fikkar')) {
      return MoodAnalysis(
        mood: MoodType.stressed,
        confidence: 0.85,
        keywords: ['stressed', 'anxious', 'tension', 'fikkar'],
        suggestedResponse: 'Sir, tension mat lo. Deep breath lo. Main aapki help karunga. Main motivational quote sunau? 🧘‍♂️',
      );
    }
    
    return MoodAnalysis(
      mood: MoodType.neutral,
      confidence: 0.70,
      keywords: [],
      suggestedResponse: 'Sir, main sun raha hu. Aage boliye. 🎤',
    );
  }
  
  String getMoodEmoji() {
    switch (mood) {
      case MoodType.happy:
        return '😊';
      case MoodType.sad:
        return '😢';
      case MoodType.angry:
        return '😠';
      case MoodType.tired:
        return '😴';
      case MoodType.stressed:
        return '😰';
      case MoodType.neutral:
        return '😐';
      case MoodType.excited:
        return '🤩';
      case MoodType.confused:
        return '😕';
    }
  }
  
  Color getMoodColor() {
    switch (mood) {
      case MoodType.happy:
        return Colors.green;
      case MoodType.sad:
        return Colors.blue;
      case MoodType.angry:
        return Colors.red;
      case MoodType.tired:
        return Colors.purple;
      case MoodType.stressed:
        return Colors.orange;
      case MoodType.neutral:
        return Colors.grey;
      case MoodType.excited:
        return Colors.yellow;
      case MoodType.confused:
        return Colors.brown;
    }
  }
}

enum MoodType {
  happy,
  sad,
  angry,
  tired,
  stressed,
  neutral,
  excited,
  confused,
}