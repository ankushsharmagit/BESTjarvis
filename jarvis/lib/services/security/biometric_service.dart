// lib/services/security/biometric_service.dart
// Multi-layer Biometric Authentication Service

import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';
import 'face_recognition.dart';
import '../voice/voice_id_service.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();
  
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FaceRecognitionService _faceService = FaceRecognitionService();
  final VoiceIDService _voiceService = VoiceIDService();
  
  bool _isDeviceSupported = false;
  bool _hasBiometrics = false;
  List<BiometricType> _availableBiometrics = [];
  
  Future<void> initialize() async {
    try {
      _isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (_isDeviceSupported) {
        _hasBiometrics = await _localAuth.canCheckBiometrics;
        _availableBiometrics = await _localAuth.getAvailableBiometrics();
      }
      
      await _faceService.initialize();
      await _voiceService.initialize();
      
      Logger().info('Biometric service initialized - Supported: $_isDeviceSupported, Has Biometrics: $_hasBiometrics', tag: 'BIOMETRIC');
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'Biometric Init');
    }
  }
  
  Future<bool> authenticateWithBiometrics({
    String reason = 'Verify your identity for JARVIS',
    bool stickyAuth = true,
  }) async {
    try {
      if (!_isDeviceSupported || !_hasBiometrics) {
        Logger().warning('Biometrics not supported or available', tag: 'BIOMETRIC');
        return false;
      }
      
      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );
      
      if (authenticated) {
        Logger().info('Biometric authentication successful', tag: 'BIOMETRIC');
      } else {
        Logger().warning('Biometric authentication failed', tag: 'BIOMETRIC');
      }
      
      return authenticated;
      
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'Biometric Auth');
      return false;
    }
  }
  
  Future<MultiFactorAuthResult> authenticateMultiFactor({
    required bool requireFace,
    required bool requireVoice,
    required bool requireBiometric,
    bool requirePin = false,
    String? pin,
  }) async {
    final result = MultiFactorAuthResult();
    result.startTime = DateTime.now();
    
    try {
      // Face recognition
      if (requireFace) {
        result.facePassed = await _faceService.verifyOwnerFace();
        if (!result.facePassed) {
          result.message = 'Face verification failed';
          result.endTime = DateTime.now();
          return result;
        }
      }
      
      // Voice identification
      if (requireVoice) {
        // Need to capture a voice sample for verification
        result.voicePassed = true; // Placeholder
        if (!result.voicePassed) {
          result.message = 'Voice verification failed';
          result.endTime = DateTime.now();
          return result;
        }
      }
      
      // Biometric (fingerprint/face)
      if (requireBiometric) {
        result.biometricPassed = await authenticateWithBiometrics();
        if (!result.biometricPassed) {
          result.message = 'Biometric verification failed';
          result.endTime = DateTime.now();
          return result;
        }
      }
      
      // PIN verification
      if (requirePin && pin != null) {
        final storedPin = await _getStoredPin();
        result.pinPassed = pin == storedPin;
        if (!result.pinPassed) {
          result.message = 'PIN verification failed';
          result.endTime = DateTime.now();
          return result;
        }
      }
      
      result.success = true;
      result.message = 'Authentication successful';
      result.endTime = DateTime.now();
      
    } catch (e) {
      result.message = 'Authentication error: $e';
      result.endTime = DateTime.now();
      Logger().error('Multi-factor auth error', tag: 'BIOMETRIC', error: e);
    }
    
    return result;
  }
  
  Future<String?> _getStoredPin() async {
    // Get stored PIN from secure storage
    return null;
  }
  
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      Logger().error('Error getting biometrics', tag: 'BIOMETRIC', error: e);
      return [];
    }
  }
  
  Future<bool> authenticateWithPin(String enteredPin, String storedPin) async {
    final isMatch = enteredPin == storedPin;
    if (isMatch) {
      Logger().info('PIN authentication successful', tag: 'BIOMETRIC');
    } else {
      Logger().warning('PIN authentication failed', tag: 'BIOMETRIC');
    }
    return isMatch;
  }
  
  Future<bool> authenticateWithPattern(String enteredPattern, String storedPattern) async {
    final isMatch = enteredPattern == storedPattern;
    if (isMatch) {
      Logger().info('Pattern authentication successful', tag: 'BIOMETRIC');
    } else {
      Logger().warning('Pattern authentication failed', tag: 'BIOMETRIC');
    }
    return isMatch;
  }
  
  Future<bool> isBiometricAvailable() async {
    return _isDeviceSupported && _hasBiometrics;
  }
  
  String getBiometricType() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return 'Iris';
    }
    return 'None';
  }
  
  Map<String, dynamic> getBiometricStatus() {
    return {
      'isSupported': _isDeviceSupported,
      'hasBiometrics': _hasBiometrics,
      'availableTypes': _availableBiometrics.map((t) => t.toString()).toList(),
      'primaryType': getBiometricType(),
    };
  }
}

class MultiFactorAuthResult {
  bool success = false;
  bool facePassed = false;
  bool voicePassed = false;
  bool biometricPassed = false;
  bool pinPassed = false;
  String message = '';
  DateTime? startTime;
  DateTime? endTime;
  
  int get successCount {
    int count = 0;
    if (facePassed) count++;
    if (voicePassed) count++;
    if (biometricPassed) count++;
    if (pinPassed) count++;
    return count;
  }
  
  double get confidenceScore {
    return successCount / 4.0;
  }
  
  Duration get duration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    return Duration.zero;
  }
  
  String getFormattedDuration() {
    final ms = duration.inMilliseconds;
    return '${ms}ms';
  }
  
  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'facePassed': facePassed,
      'voicePassed': voicePassed,
      'biometricPassed': biometricPassed,
      'pinPassed': pinPassed,
      'message': message,
      'duration': duration.inMilliseconds,
      'confidence': confidenceScore,
    };
  }
}

class SecurityLevelManager {
  static const int LEVEL_LOW = 0;
  static const int LEVEL_MEDIUM = 1;
  static const int LEVEL_HIGH = 2;
  static const int LEVEL_MAXIMUM = 3;
  
  static int getRequiredLevelForAction(String action) {
    // Low security actions (no authentication needed)
    const lowSecurityActions = [
      'get_time', 'get_date', 'get_battery', 'volume_up', 'volume_down',
      'flashlight_on', 'flashlight_off', 'brightness_up', 'brightness_down',
      'get_weather', 'get_news', 'tell_joke', 'get_quote',
    ];
    
    // Medium security actions (voice verification recommended)
    const mediumSecurityActions = [
      'open_app', 'close_app', 'play_music', 'pause_music', 'next_song',
      'take_screenshot', 'wifi_on', 'wifi_off', 'bluetooth_on', 'bluetooth_off',
      'send_message', 'make_call', 'search_web', 'set_alarm',
    ];
    
    // High security actions (face verification required)
    const highSecurityActions = [
      'access_contacts', 'access_gallery', 'read_messages', 'view_call_log',
      'delete_file', 'move_file', 'clear_app_data', 'uninstall_app',
      'access_settings', 'view_passwords', 'share_location',
    ];
    
    // Maximum security actions (multi-factor authentication required)
    const maximumSecurityActions = [
      'open_vault', 'delete_all_data', 'factory_reset', 'access_private_photos',
      'view_banking_info', 'make_payment', 'emergency_lockdown', 'access_secure_notes',
      'change_security_settings', 'disable_security', 'root_access',
    ];
    
    if (lowSecurityActions.contains(action)) return LEVEL_LOW;
    if (mediumSecurityActions.contains(action)) return LEVEL_MEDIUM;
    if (highSecurityActions.contains(action)) return LEVEL_HIGH;
    if (maximumSecurityActions.contains(action)) return LEVEL_MAXIMUM;
    
    return LEVEL_MEDIUM;
  }
  
  static String getSecurityLevelName(int level) {
    switch (level) {
      case LEVEL_LOW: return 'Low';
      case LEVEL_MEDIUM: return 'Medium';
      case LEVEL_HIGH: return 'High';
      case LEVEL_MAXIMUM: return 'Maximum';
      default: return 'Unknown';
    }
  }
  
  static String getSecurityLevelDescription(int level) {
    switch (level) {
      case LEVEL_LOW:
        return 'Basic commands, no authentication required';
      case LEVEL_MEDIUM:
        return 'Standard commands, voice verification recommended';
      case LEVEL_HIGH:
        return 'Sensitive commands, face verification required';
      case LEVEL_MAXIMUM:
        return 'Critical commands, multi-factor authentication required';
      default:
        return 'Unknown security level';
    }
  }
  
  static IconData getSecurityLevelIcon(int level) {
    switch (level) {
      case LEVEL_LOW: return Icons.lock_open;
      case LEVEL_MEDIUM: return Icons.lock_outline;
      case LEVEL_HIGH: return Icons.lock;
      case LEVEL_MAXIMUM: return Icons.security;
      default: return Icons.help_outline;
    }
  }
  
  static Color getSecurityLevelColor(int level) {
    switch (level) {
      case LEVEL_LOW: return Colors.green;
      case LEVEL_MEDIUM: return Colors.orange;
      case LEVEL_HIGH: return Colors.red;
      case LEVEL_MAXIMUM: return Colors.purple;
      default: return Colors.grey;
    }
  }
}