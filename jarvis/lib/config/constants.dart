// lib/config/constants.dart
// JARVIS App Configuration Constants - WITH ACTIVE KEYS

class AppConstants {
  // App Information
  static const String appName = 'JARVIS';
  static const String appVersion = '4.0.0';
  static const String appCodename = 'ULTIMATE';
  static const String fullName = 'Just A Rather Very Intelligent System';
  static const String ownerName = 'Mukul';
  static const String ownerTitle = 'Sir';
  
  // ===== YOUR ACTIVE API KEYS =====
  static const String geminiApiKey = 'AIzaSyB0XEtmp2JP-1NQOFhoWxJMM3YaKRyM3Kw';
  static const String telegramBotToken = '8650822300:AAEe2r94dOGMBI9co7Lh5PKxuas8rjO_zvQ';
  
  // Other API Keys (Optional - Add if you have)
  static const String openAiApiKey = 'YOUR_OPENAI_API_KEY_HERE';
  static const String weatherApiKey = 'YOUR_WEATHER_API_KEY_HERE';
  static const String newsApiKey = 'YOUR_NEWS_API_KEY_HERE';
  
  // API Endpoints
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String geminiModel = 'gemini-1.5-flash';
  static const String telegramApiBase = 'https://api.telegram.org/bot';
  
  // Security Settings
  static const double faceRecognitionThreshold = 0.85;
  static const double voiceIdThreshold = 0.85;
  static const int maxLoginAttempts = 3;
  static const int intruderPhotoCaptureDelay = 500;
  static const String encryptionKey = 'JARVIS_SECURE_KEY_2024';
  
  // Database Names
  static const String dbName = 'jarvis_database.db';
  static const int dbVersion = 1;
  
  // Table Names
  static const String tableChatHistory = 'chat_history';
  static const String tableIntruderLogs = 'intruder_logs';
  static const String tableRoutines = 'routines';
  static const String tableScheduledTasks = 'scheduled_tasks';
  static const String tableVoiceProfile = 'voice_profile';
  static const String tableFaceEmbeddings = 'face_embeddings';
  static const String tableUsageStats = 'usage_stats';
  static const String tableNotifications = 'notifications';
  
  // Shared Preferences Keys
  static const String prefFirstLaunch = 'first_launch';
  static const String prefOwnerRegistered = 'owner_registered';
  static const String prefFaceRegistered = 'face_registered';
  static const String prefVoiceRegistered = 'voice_registered';
  static const String prefPinCode = 'pin_code';
  static const String prefSecurityLevel = 'security_level';
  static const String prefAiProvider = 'ai_provider';
  static const String prefWakeWord = 'wake_word';
  static const String prefThemeColor = 'theme_color';
  static const String prefAnimationsEnabled = 'animations_enabled';
  static const String prefLanguage = 'language';
  static const String prefVoiceSpeed = 'voice_speed';
  static const String prefVoicePitch = 'voice_pitch';
  static const String prefTelegramBotToken = 'telegram_bot_token';
  
  // Wake Words
  static const List<String> wakeWords = [
    'jarvis', 'hey jarvis', 'hello jarvis', 'jarvis ji',
    'suno jarvis', 'jarvis suno', 'ok jarvis', 'jarvis bhai',
    'jarvis bhaiya', 'jarvis sir', 'jarvis boss', 'jarvis wake up',
    'mukul sir',
  ];
  
  // Response Types
  static const String responseTypeInfo = 'info';
  static const String responseTypeSuccess = 'success';
  static const String responseTypeError = 'error';
  static const String responseTypeWarning = 'warning';
  static const String responseTypeThinking = 'thinking';
  
  // Animation Durations
  static const int splashDuration = 5500;
  static const int animationDuration = 300;
  static const int typingSpeed = 50;
  static const int micAnimationDuration = 200;
  
  // Timeouts
  static const int aiRequestTimeout = 30;
  static const int voiceRecognitionTimeout = 10;
  static const int faceScanTimeout = 20;
  
  // File Paths
  static const String vaultDirectory = 'JARVIS_Vault';
  static const String backupDirectory = 'JARVIS_Backups';
  static const String intruderPhotosDirectory = 'Intruder_Photos';
  static const String logsDirectory = 'Logs';
  
  // Maximum Values
  static const int maxChatHistory = 500;
  static const int maxConsecutiveFailures = 3;
  static const int maxFileSizeForAnalysis = 10485760;
  
  // Error Messages
  static const String errorNoInternet = 'Sir, internet connection nahi hai. Offline mode mein baat kar rahe hain.';
  static const String errorPermissionDenied = 'Sir, permission chahiye. Settings se enable karo.';
  static const String errorFaceNotRecognized = 'Face verify nahi hua. Sirf aap hi sensitive commands de sakte hain.';
  static const String errorVoiceNotRecognized = 'Aapki voice match nahi hui. Sirf Mukul Sir commands de sakte hain.';
  static const String errorCommandNotFound = 'Sir, ye command samajh nahi aaya. "JARVIS help" bolo saari commands ke liye.';
  static const String errorAiFailed = 'AI service down hai. Offline mode mein shift ho raha hu.';
  
  // Success Messages
  static const String successCommandExecuted = 'Command execute ho gaya, Sir.';
  static const String successSetupComplete = 'Setup complete! Aap ready hain.';
  static const String successFaceRegistered = 'Face register ho gaya, Sir. Ab security aur strong hai.';
  static const String successVoiceRegistered = 'Voice profile saved. Ab sirf aapki voice pe reply karunga sensitive commands par.';
  static const String successTelegramConnected = 'Telegram bot connected! Ab messages bhej sakte ho.';
}

class SecurityConstants {
  static const int securityLevelLow = 0;
  static const int securityLevelMedium = 1;
  static const int securityLevelHigh = 2;
  static const int securityLevelMaximum = 3;
  
  static const String intruderActionWrongPin = 'WRONG_PIN';
  static const String intruderActionWrongPattern = 'WRONG_PATTERN';
  static const String intruderActionUnknownFace = 'UNKNOWN_FACE';
  static const String intruderActionUnknownVoice = 'UNKNOWN_VOICE';
  static const String intruderActionFailedBiometric = 'FAILED_BIOMETRIC';
  static const String intruderActionPhoneLifted = 'PHONE_LIFTED';
  static const String intruderActionUsbConnected = 'USB_CONNECTED';
  
  static const String vaultCalculatorCode = '12345';
  static const int vaultMaxAttempts = 3;
  static const int vaultLockoutDuration = 30;
}