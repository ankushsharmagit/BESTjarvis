// lib/models/user_profile.dart
// Owner Profile Model with Security Settings

class UserProfile {
  final String id;
  final String name;
  final String preferredTitle;
  final DateTime registrationDate;
  final String? profilePhotoPath;
  final String? wakeWord;
  final String? preferredLanguage;
  final bool faceRegistered;
  final bool voiceRegistered;
  final int securityLevel;
  final List<String> trustedDevices;
  final Map<String, dynamic> preferences;
  final DateTime lastActive;
  final String? emergencyContact;
  final List<String> emergencyContacts;
  final String? defaultLocation;
  final Map<String, dynamic> routinePreferences;
  final Map<String, dynamic> aiSettings;
  
  UserProfile({
    required this.id,
    required this.name,
    required this.preferredTitle,
    required this.registrationDate,
    this.profilePhotoPath,
    this.wakeWord,
    this.preferredLanguage = 'hinglish',
    this.faceRegistered = false,
    this.voiceRegistered = false,
    this.securityLevel = 2,
    this.trustedDevices = const [],
    this.preferences = const {},
    required this.lastActive,
    this.emergencyContact,
    this.emergencyContacts = const [],
    this.defaultLocation,
    this.routinePreferences = const {},
    this.aiSettings = const {},
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'preferredTitle': preferredTitle,
      'registrationDate': registrationDate.toIso8601String(),
      'profilePhotoPath': profilePhotoPath,
      'wakeWord': wakeWord,
      'preferredLanguage': preferredLanguage,
      'faceRegistered': faceRegistered ? 1 : 0,
      'voiceRegistered': voiceRegistered ? 1 : 0,
      'securityLevel': securityLevel,
      'trustedDevices': trustedDevices.join(','),
      'preferences': preferences,
      'lastActive': lastActive.toIso8601String(),
      'emergencyContact': emergencyContact,
      'emergencyContacts': emergencyContacts.join(','),
      'defaultLocation': defaultLocation,
      'routinePreferences': routinePreferences,
      'aiSettings': aiSettings,
    };
  }
  
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      preferredTitle: map['preferredTitle'],
      registrationDate: DateTime.parse(map['registrationDate']),
      profilePhotoPath: map['profilePhotoPath'],
      wakeWord: map['wakeWord'],
      preferredLanguage: map['preferredLanguage'],
      faceRegistered: map['faceRegistered'] == 1,
      voiceRegistered: map['voiceRegistered'] == 1,
      securityLevel: map['securityLevel'],
      trustedDevices: map['trustedDevices']?.split(',') ?? [],
      preferences: map['preferences'] ?? {},
      lastActive: DateTime.parse(map['lastActive']),
      emergencyContact: map['emergencyContact'],
      emergencyContacts: map['emergencyContacts']?.split(',') ?? [],
      defaultLocation: map['defaultLocation'],
      routinePreferences: map['routinePreferences'] ?? {},
      aiSettings: map['aiSettings'] ?? {},
    );
  }
  
  UserProfile copyWith({
    String? id,
    String? name,
    String? preferredTitle,
    DateTime? registrationDate,
    String? profilePhotoPath,
    String? wakeWord,
    String? preferredLanguage,
    bool? faceRegistered,
    bool? voiceRegistered,
    int? securityLevel,
    List<String>? trustedDevices,
    Map<String, dynamic>? preferences,
    DateTime? lastActive,
    String? emergencyContact,
    List<String>? emergencyContacts,
    String? defaultLocation,
    Map<String, dynamic>? routinePreferences,
    Map<String, dynamic>? aiSettings,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      preferredTitle: preferredTitle ?? this.preferredTitle,
      registrationDate: registrationDate ?? this.registrationDate,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      wakeWord: wakeWord ?? this.wakeWord,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      faceRegistered: faceRegistered ?? this.faceRegistered,
      voiceRegistered: voiceRegistered ?? this.voiceRegistered,
      securityLevel: securityLevel ?? this.securityLevel,
      trustedDevices: trustedDevices ?? this.trustedDevices,
      preferences: preferences ?? this.preferences,
      lastActive: lastActive ?? this.lastActive,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      defaultLocation: defaultLocation ?? this.defaultLocation,
      routinePreferences: routinePreferences ?? this.routinePreferences,
      aiSettings: aiSettings ?? this.aiSettings,
    );
  }
  
  String getDisplayName() {
    return '$preferredTitle $name';
  }
  
  String getShortName() {
    return name.split(' ').first;
  }
  
  bool isFullySetup() {
    return faceRegistered && voiceRegistered;
  }
  
  bool isEmergencyContact(String number) {
    return emergencyContacts.contains(number) || emergencyContact == number;
  }
  
  int getSecurityLevelPercent() {
    int percent = 0;
    if (faceRegistered) percent += 25;
    if (voiceRegistered) percent += 25;
    if (securityLevel >= 2) percent += 25;
    if (emergencyContacts.isNotEmpty) percent += 25;
    return percent;
  }
  
  String getSecurityLevelName() {
    switch (securityLevel) {
      case 0:
        return 'Low';
      case 1:
        return 'Medium';
      case 2:
        return 'High';
      case 3:
        return 'Maximum';
      default:
        return 'Unknown';
    }
  }
}

class UserPreferences {
  String themeColor;
  bool animationsEnabled;
  bool hapticFeedback;
  String voiceGender;
  double voiceSpeed;
  double voicePitch;
  bool autoListen;
  bool wakeWordEnabled;
  bool showNotifications;
  bool autoBackup;
  int backupFrequency;
  bool locationTracking;
  bool usageAnalytics;
  bool telegramIntegration;
  bool whatsappIntegration;
  bool socialMediaIntegration;
  String defaultAiProvider;
  double aiTemperature;
  int maxTokens;
  bool offlineModeEnabled;
  bool proactiveSuggestions;
  
  UserPreferences({
    this.themeColor = 'cyan',
    this.animationsEnabled = true,
    this.hapticFeedback = true,
    this.voiceGender = 'male',
    this.voiceSpeed = 1.0,
    this.voicePitch = 1.0,
    this.autoListen = false,
    this.wakeWordEnabled = true,
    this.showNotifications = true,
    this.autoBackup = true,
    this.backupFrequency = 7,
    this.locationTracking = true,
    this.usageAnalytics = true,
    this.telegramIntegration = false,
    this.whatsappIntegration = true,
    this.socialMediaIntegration = false,
    this.defaultAiProvider = 'gemini',
    this.aiTemperature = 0.7,
    this.maxTokens = 1024,
    this.offlineModeEnabled = true,
    this.proactiveSuggestions = true,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'themeColor': themeColor,
      'animationsEnabled': animationsEnabled,
      'hapticFeedback': hapticFeedback,
      'voiceGender': voiceGender,
      'voiceSpeed': voiceSpeed,
      'voicePitch': voicePitch,
      'autoListen': autoListen,
      'wakeWordEnabled': wakeWordEnabled,
      'showNotifications': showNotifications,
      'autoBackup': autoBackup,
      'backupFrequency': backupFrequency,
      'locationTracking': locationTracking,
      'usageAnalytics': usageAnalytics,
      'telegramIntegration': telegramIntegration,
      'whatsappIntegration': whatsappIntegration,
      'socialMediaIntegration': socialMediaIntegration,
      'defaultAiProvider': defaultAiProvider,
      'aiTemperature': aiTemperature,
      'maxTokens': maxTokens,
      'offlineModeEnabled': offlineModeEnabled,
      'proactiveSuggestions': proactiveSuggestions,
    };
  }
  
  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      themeColor: map['themeColor'] ?? 'cyan',
      animationsEnabled: map['animationsEnabled'] ?? true,
      hapticFeedback: map['hapticFeedback'] ?? true,
      voiceGender: map['voiceGender'] ?? 'male',
      voiceSpeed: map['voiceSpeed'] ?? 1.0,
      voicePitch: map['voicePitch'] ?? 1.0,
      autoListen: map['autoListen'] ?? false,
      wakeWordEnabled: map['wakeWordEnabled'] ?? true,
      showNotifications: map['showNotifications'] ?? true,
      autoBackup: map['autoBackup'] ?? true,
      backupFrequency: map['backupFrequency'] ?? 7,
      locationTracking: map['locationTracking'] ?? true,
      usageAnalytics: map['usageAnalytics'] ?? true,
      telegramIntegration: map['telegramIntegration'] ?? false,
      whatsappIntegration: map['whatsappIntegration'] ?? true,
      socialMediaIntegration: map['socialMediaIntegration'] ?? false,
      defaultAiProvider: map['defaultAiProvider'] ?? 'gemini',
      aiTemperature: map['aiTemperature'] ?? 0.7,
      maxTokens: map['maxTokens'] ?? 1024,
      offlineModeEnabled: map['offlineModeEnabled'] ?? true,
      proactiveSuggestions: map['proactiveSuggestions'] ?? true,
    );
  }
}

class SecuritySettings {
  bool faceAuthEnabled;
  bool voiceAuthEnabled;
  bool pinEnabled;
  String pinCode;
  bool patternEnabled;
  String patternCode;
  bool biometricEnabled;
  int autoLockTimeout;
  bool intruderDetection;
  bool captureIntruderPhoto;
  bool sendAlertOnIntruder;
  String? emergencyContact;
  bool lockdownOnTheft;
  bool fakeScreenOnIntruder;
  bool logAllAttempts;
  bool notifyOnNewDevice;
  
  SecuritySettings({
    this.faceAuthEnabled = true,
    this.voiceAuthEnabled = true,
    this.pinEnabled = false,
    this.pinCode = '',
    this.patternEnabled = false,
    this.patternCode = '',
    this.biometricEnabled = true,
    this.autoLockTimeout = 5,
    this.intruderDetection = true,
    this.captureIntruderPhoto = true,
    this.sendAlertOnIntruder = true,
    this.emergencyContact,
    this.lockdownOnTheft = true,
    this.fakeScreenOnIntruder = true,
    this.logAllAttempts = true,
    this.notifyOnNewDevice = true,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'faceAuthEnabled': faceAuthEnabled,
      'voiceAuthEnabled': voiceAuthEnabled,
      'pinEnabled': pinEnabled,
      'pinCode': pinCode,
      'patternEnabled': patternEnabled,
      'patternCode': patternCode,
      'biometricEnabled': biometricEnabled,
      'autoLockTimeout': autoLockTimeout,
      'intruderDetection': intruderDetection,
      'captureIntruderPhoto': captureIntruderPhoto,
      'sendAlertOnIntruder': sendAlertOnIntruder,
      'emergencyContact': emergencyContact,
      'lockdownOnTheft': lockdownOnTheft,
      'fakeScreenOnIntruder': fakeScreenOnIntruder,
      'logAllAttempts': logAllAttempts,
      'notifyOnNewDevice': notifyOnNewDevice,
    };
  }
  
  factory SecuritySettings.fromMap(Map<String, dynamic> map) {
    return SecuritySettings(
      faceAuthEnabled: map['faceAuthEnabled'] ?? true,
      voiceAuthEnabled: map['voiceAuthEnabled'] ?? true,
      pinEnabled: map['pinEnabled'] ?? false,
      pinCode: map['pinCode'] ?? '',
      patternEnabled: map['patternEnabled'] ?? false,
      patternCode: map['patternCode'] ?? '',
      biometricEnabled: map['biometricEnabled'] ?? true,
      autoLockTimeout: map['autoLockTimeout'] ?? 5,
      intruderDetection: map['intruderDetection'] ?? true,
      captureIntruderPhoto: map['captureIntruderPhoto'] ?? true,
      sendAlertOnIntruder: map['sendAlertOnIntruder'] ?? true,
      emergencyContact: map['emergencyContact'],
      lockdownOnTheft: map['lockdownOnTheft'] ?? true,
      fakeScreenOnIntruder: map['fakeScreenOnIntruder'] ?? true,
      logAllAttempts: map['logAllAttempts'] ?? true,
      notifyOnNewDevice: map['notifyOnNewDevice'] ?? true,
    );
  }
}