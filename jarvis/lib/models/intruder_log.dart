// lib/models/intruder_log.dart
// Intruder Detection Log Model with Photo Capture

class IntruderLog {
  final String id;
  final DateTime timestamp;
  final String actionType;
  final String? photoPath;
  final double? latitude;
  final double? longitude;
  final String? locationAddress;
  final String? attemptedAccess;
  final int attemptDuration;
  final bool wasSuccessful;
  final String? deviceInfo;
  final String? voiceSamplePath;
  final String? confidenceScore;
  final bool isOwner;
  
  IntruderLog({
    required this.id,
    required this.timestamp,
    required this.actionType,
    this.photoPath,
    this.latitude,
    this.longitude,
    this.locationAddress,
    this.attemptedAccess,
    this.attemptDuration = 0,
    this.wasSuccessful = false,
    this.deviceInfo,
    this.voiceSamplePath,
    this.confidenceScore,
    this.isOwner = false,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'actionType': actionType,
      'photoPath': photoPath,
      'latitude': latitude,
      'longitude': longitude,
      'locationAddress': locationAddress,
      'attemptedAccess': attemptedAccess,
      'attemptDuration': attemptDuration,
      'wasSuccessful': wasSuccessful ? 1 : 0,
      'deviceInfo': deviceInfo,
      'voiceSamplePath': voiceSamplePath,
      'confidenceScore': confidenceScore,
      'isOwner': isOwner ? 1 : 0,
    };
  }
  
  factory IntruderLog.fromMap(Map<String, dynamic> map) {
    return IntruderLog(
      id: map['id'],
      timestamp: DateTime.parse(map['timestamp']),
      actionType: map['actionType'],
      photoPath: map['photoPath'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      locationAddress: map['locationAddress'],
      attemptedAccess: map['attemptedAccess'],
      attemptDuration: map['attemptDuration'],
      wasSuccessful: map['wasSuccessful'] == 1,
      deviceInfo: map['deviceInfo'],
      voiceSamplePath: map['voiceSamplePath'],
      confidenceScore: map['confidenceScore'],
      isOwner: map['isOwner'] == 1,
    );
  }
  
  String getFormattedTimestamp() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago at ${_formatTime(timestamp)}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago at ${_formatTime(timestamp)}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  String getActionIcon() {
    switch (actionType) {
      case 'WRONG_PIN':
        return '🔐';
      case 'WRONG_PATTERN':
        return '📱';
      case 'UNKNOWN_FACE':
        return '👤';
      case 'UNKNOWN_VOICE':
        return '🎤';
      case 'FAILED_BIOMETRIC':
        return '👆';
      case 'PHONE_LIFTED':
        return '📱';
      case 'USB_CONNECTED':
        return '🔌';
      case 'SCREEN_UNLOCK_ATTEMPT':
        return '🔓';
      case 'APP_ACCESS_ATTEMPT':
        return '📲';
      case 'FILE_ACCESS_ATTEMPT':
        return '📁';
      case 'VAULT_ACCESS_ATTEMPT':
        return '🔒';
      default:
        return '⚠️';
    }
  }
  
  String getActionDescription() {
    switch (actionType) {
      case 'WRONG_PIN':
        return 'Wrong PIN entered multiple times';
      case 'WRONG_PATTERN':
        return 'Wrong pattern entered multiple times';
      case 'UNKNOWN_FACE':
        return 'Unknown face detected attempting to access';
      case 'UNKNOWN_VOICE':
        return 'Unknown voice detected giving command';
      case 'FAILED_BIOMETRIC':
        return 'Failed biometric authentication attempt';
      case 'PHONE_LIFTED':
        return 'Phone lifted while owner was away';
      case 'USB_CONNECTED':
        return 'USB debugging connection detected';
      case 'SCREEN_UNLOCK_ATTEMPT':
        return 'Unauthorized screen unlock attempt';
      case 'APP_ACCESS_ATTEMPT':
        return 'Attempted to access restricted app';
      case 'FILE_ACCESS_ATTEMPT':
        return 'Attempted to access protected file';
      case 'VAULT_ACCESS_ATTEMPT':
        return 'Attempted to access private vault';
      default:
        return 'Unknown security event detected';
    }
  }
  
  String getSeverityLevel() {
    switch (actionType) {
      case 'WRONG_PIN':
      case 'WRONG_PATTERN':
        return 'Medium';
      case 'UNKNOWN_FACE':
      case 'UNKNOWN_VOICE':
        return 'High';
      case 'FAILED_BIOMETRIC':
        return 'Medium';
      case 'PHONE_LIFTED':
        return 'Low';
      case 'USB_CONNECTED':
        return 'Critical';
      case 'VAULT_ACCESS_ATTEMPT':
        return 'Critical';
      default:
        return 'Medium';
    }
  }
  
  Color getSeverityColor() {
    switch (getSeverityLevel()) {
      case 'Low':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.red;
      case 'Critical':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

class SecurityStats {
  int totalAttempts;
  int successfulAttempts;
  int failedAttempts;
  int uniqueIntruders;
  DateTime lastAttempt;
  Map<String, int> attemptsByType;
  Map<String, int> attemptsByHour;
  List<String> uniqueFaceIds;
  List<String> uniqueVoiceIds;
  
  SecurityStats({
    this.totalAttempts = 0,
    this.successfulAttempts = 0,
    this.failedAttempts = 0,
    this.uniqueIntruders = 0,
    required this.lastAttempt,
    this.attemptsByType = const {},
    this.attemptsByHour = const {},
    this.uniqueFaceIds = const [],
    this.uniqueVoiceIds = const [],
  });
  
  double getSuccessRate() {
    if (totalAttempts == 0) return 0;
    return (successfulAttempts / totalAttempts) * 100;
  }
  
  double getFailureRate() {
    if (totalAttempts == 0) return 0;
    return (failedAttempts / totalAttempts) * 100;
  }
  
  String getSecurityScore() {
    if (totalAttempts == 0) return 'Excellent';
    if (failedAttempts < 3) return 'Good';
    if (failedAttempts < 10) return 'Fair';
    if (failedAttempts < 20) return 'Poor';
    return 'Critical';
  }
  
  String getMostCommonAttackType() {
    if (attemptsByType.isEmpty) return 'None';
    return attemptsByType.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
  
  String getPeakAttackHour() {
    if (attemptsByHour.isEmpty) return 'Unknown';
    return attemptsByHour.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
  
  Map<String, dynamic> toMap() {
    return {
      'totalAttempts': totalAttempts,
      'successfulAttempts': successfulAttempts,
      'failedAttempts': failedAttempts,
      'uniqueIntruders': uniqueIntruders,
      'lastAttempt': lastAttempt.toIso8601String(),
      'attemptsByType': attemptsByType,
      'attemptsByHour': attemptsByHour,
      'uniqueFaceIds': uniqueFaceIds,
      'uniqueVoiceIds': uniqueVoiceIds,
    };
  }
  
  factory SecurityStats.fromMap(Map<String, dynamic> map) {
    return SecurityStats(
      totalAttempts: map['totalAttempts'],
      successfulAttempts: map['successfulAttempts'],
      failedAttempts: map['failedAttempts'],
      uniqueIntruders: map['uniqueIntruders'],
      lastAttempt: DateTime.parse(map['lastAttempt']),
      attemptsByType: Map<String, int>.from(map['attemptsByType'] ?? {}),
      attemptsByHour: Map<String, int>.from(map['attemptsByHour'] ?? {}),
      uniqueFaceIds: List<String>.from(map['uniqueFaceIds'] ?? []),
      uniqueVoiceIds: List<String>.from(map['uniqueVoiceIds'] ?? []),
    );
  }
}

class FaceEmbedding {
  final String id;
  final List<double> embedding;
  final DateTime createdAt;
  final String angle;
  final double quality;
  final bool isOwner;
  
  FaceEmbedding({
    required this.id,
    required this.embedding,
    required this.createdAt,
    required this.angle,
    this.quality = 0.0,
    this.isOwner = true,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'embedding': embedding.join(','),
      'createdAt': createdAt.toIso8601String(),
      'angle': angle,
      'quality': quality,
      'isOwner': isOwner ? 1 : 0,
    };
  }
  
  factory FaceEmbedding.fromMap(Map<String, dynamic> map) {
    return FaceEmbedding(
      id: map['id'],
      embedding: (map['embedding'] as String).split(',').map(double.parse).toList(),
      createdAt: DateTime.parse(map['createdAt']),
      angle: map['angle'],
      quality: map['quality'] ?? 0.0,
      isOwner: map['isOwner'] == 1,
    );
  }
  
  double calculateSimilarity(FaceEmbedding other) {
    if (embedding.length != other.embedding.length) return 0;
    
    double dotProduct = 0;
    double norm1 = 0;
    double norm2 = 0;
    
    for (int i = 0; i < embedding.length; i++) {
      dotProduct += embedding[i] * other.embedding[i];
      norm1 += embedding[i] * embedding[i];
      norm2 += other.embedding[i] * other.embedding[i];
    }
    
    if (norm1 == 0 || norm2 == 0) return 0;
    return dotProduct / (norm1 * norm2);
  }
}

class VoicePrint {
  final String id;
  final List<double> features;
  final DateTime createdAt;
  final String sampleText;
  final double quality;
  final bool isOwner;
  final String? voiceCharacteristics;
  
  VoicePrint({
    required this.id,
    required this.features,
    required this.createdAt,
    required this.sampleText,
    this.quality = 0.0,
    this.isOwner = true,
    this.voiceCharacteristics,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'features': features.join(','),
      'createdAt': createdAt.toIso8601String(),
      'sampleText': sampleText,
      'quality': quality,
      'isOwner': isOwner ? 1 : 0,
      'voiceCharacteristics': voiceCharacteristics,
    };
  }
  
  factory VoicePrint.fromMap(Map<String, dynamic> map) {
    return VoicePrint(
      id: map['id'],
      features: (map['features'] as String).split(',').map(double.parse).toList(),
      createdAt: DateTime.parse(map['createdAt']),
      sampleText: map['sampleText'],
      quality: map['quality'] ?? 0.0,
      isOwner: map['isOwner'] == 1,
      voiceCharacteristics: map['voiceCharacteristics'],
    );
  }
  
  double calculateSimilarity(VoicePrint other) {
    if (features.length != other.features.length) return 0;
    
    double dotProduct = 0;
    double norm1 = 0;
    double norm2 = 0;
    
    for (int i = 0; i < features.length; i++) {
      dotProduct += features[i] * other.features[i];
      norm1 += features[i] * features[i];
      norm2 += other.features[i] * other.features[i];
    }
    
    if (norm1 == 0 || norm2 == 0) return 0;
    return dotProduct / (norm1 * norm2);
  }
  
  String getVoiceGender() {
    if (voiceCharacteristics == null) return 'Unknown';
    // Analyze voice characteristics to determine gender
    // This would use ML model in production
    return 'Male';
  }
  
  String getVoiceAge() {
    // Estimate age from voice characteristics
    return 'Adult';
  }
}