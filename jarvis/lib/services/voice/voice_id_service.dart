// lib/services/voice/voice_id_service.dart
// Speaker Identification and Voice Biometrics Service

import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';
import 'speech_to_text_service.dart';

class VoiceIDService {
  static final VoiceIDService _instance = VoiceIDService._internal();
  factory VoiceIDService() => _instance;
  VoiceIDService._internal();
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final SpeechToTextService _sttService = SpeechToTextService();
  
  List<VoicePrint> _ownerVoicePrints = [];
  List<VoicePrint> _unknownVoicePrints = [];
  double _confidenceThreshold = 0.85;
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    try {
      await _loadVoicePrints();
      _isInitialized = true;
      Logger().info('Voice ID service initialized with ${_ownerVoicePrints.length} voice prints', tag: 'VOICE_ID');
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'Voice ID Init');
      _isInitialized = false;
    }
  }
  
  Future<void> registerOwnerVoice(List<String> sampleSentences) async {
    try {
      Logger().info('Registering owner voice with ${sampleSentences.length} samples', tag: 'VOICE_ID');
      
      for (var sentence in sampleSentences) {
        final voicePrint = await _captureVoicePrint(sentence, isOwner: true);
        if (voicePrint != null) {
          _ownerVoicePrints.add(voicePrint);
        }
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      if (_ownerVoicePrints.length >= 3) {
        await _saveVoicePrints();
        Logger().info('Owner voice registered successfully', tag: 'VOICE_ID');
      } else {
        Logger().warning('Only ${_ownerVoicePrints.length} voice prints captured, need at least 3', tag: 'VOICE_ID');
      }
      
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'Voice Register');
    }
  }
  
  Future<VoicePrint?> _captureVoicePrint(String sentence, {bool isOwner = true}) async {
    try {
      // In production, this would extract actual voice features
      // For now, generate synthetic voice print for demonstration
      final features = _generateSyntheticFeatures(sentence);
      
      return VoicePrint(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        features: features,
        createdAt: DateTime.now(),
        sampleText: sentence,
        quality: 0.9,
        isOwner: isOwner,
        voiceCharacteristics: _analyzeVoiceCharacteristics(sentence),
      );
      
    } catch (e) {
      Logger().error('Error capturing voice print', tag: 'VOICE_ID', error: e);
      return null;
    }
  }
  
  List<double> _generateSyntheticFeatures(String text) {
    // Generate synthetic 128-dimension voice feature vector
    final random = Random(text.hashCode);
    return List.generate(128, (i) => random.nextDouble());
  }
  
  String _analyzeVoiceCharacteristics(String text) {
    // Analyze pitch, tone, speaking rate from text
    final length = text.length;
    if (length < 20) return 'Short utterance, normal pace';
    if (length < 50) return 'Medium utterance, steady pace';
    return 'Long utterance, detailed speech';
  }
  
  Future<bool> verifySpeaker(String spokenText) async {
    try {
      if (!_isInitialized || _ownerVoicePrints.isEmpty) {
        Logger().warning('Voice ID not initialized or no owner voice registered', tag: 'VOICE_ID');
        return false;
      }
      
      // Capture voice print of the current speaker
      final currentVoicePrint = await _captureVoicePrint(spokenText, isOwner: false);
      if (currentVoicePrint == null) {
        return false;
      }
      
      // Compare with stored owner voice prints
      double bestSimilarity = 0;
      for (var ownerPrint in _ownerVoicePrints) {
        final similarity = _calculateSimilarity(currentVoicePrint.features, ownerPrint.features);
        if (similarity > bestSimilarity) {
          bestSimilarity = similarity;
        }
      }
      
      final isMatch = bestSimilarity >= _confidenceThreshold;
      
      if (isMatch) {
        Logger().info('Speaker verified with similarity: ${bestSimilarity.toStringAsFixed(3)}', tag: 'VOICE_ID');
      } else {
        Logger().warning('Speaker verification failed with similarity: ${bestSimilarity.toStringAsFixed(3)}', tag: 'VOICE_ID');
        // Log unknown speaker attempt
        await _logUnknownSpeaker(spokenText, bestSimilarity);
      }
      
      return isMatch;
      
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'Voice Verify');
      return false;
    }
  }
  
  Future<void> _logUnknownSpeaker(String spokenText, double similarity) async {
    final unknownPrint = VoicePrint(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      features: _generateSyntheticFeatures(spokenText),
      createdAt: DateTime.now(),
      sampleText: spokenText,
      quality: similarity,
      isOwner: false,
      voiceCharacteristics: 'Unknown speaker attempt',
    );
    
    _unknownVoicePrints.add(unknownPrint);
    
    // Keep only last 50 unknown prints
    if (_unknownVoicePrints.length > 50) {
      _unknownVoicePrints.removeAt(0);
    }
    
    await _saveUnknownPrints();
    Logger().warning('Unknown speaker logged: "$spokenText" (similarity: ${similarity.toStringAsFixed(3)})', tag: 'VOICE_ID');
  }
  
  double _calculateSimilarity(List<double> features1, List<double> features2) {
    if (features1.length != features2.length) return 0;
    
    double dotProduct = 0;
    double norm1 = 0;
    double norm2 = 0;
    
    for (int i = 0; i < features1.length; i++) {
      dotProduct += features1[i] * features2[i];
      norm1 += features1[i] * features1[i];
      norm2 += features2[i] * features2[i];
    }
    
    if (norm1 == 0 || norm2 == 0) return 0;
    return dotProduct / (sqrt(norm1) * sqrt(norm2));
  }
  
  Future<void> addVoiceSample(String sampleText) async {
    final voicePrint = await _captureVoicePrint(sampleText, isOwner: true);
    if (voicePrint != null) {
      _ownerVoicePrints.add(voicePrint);
      await _saveVoicePrints();
      Logger().info('Added voice sample: "$sampleText"', tag: 'VOICE_ID');
    }
  }
  
  Future<void> _saveVoicePrints() async {
    final json = jsonEncode(_ownerVoicePrints.map((v) => v.toMap()).toList());
    await _secureStorage.write(key: 'owner_voice_prints', value: json);
  }
  
  Future<void> _saveUnknownPrints() async {
    final json = jsonEncode(_unknownVoicePrints.map((v) => v.toMap()).toList());
    await _secureStorage.write(key: 'unknown_voice_prints', value: json);
  }
  
  Future<void> _loadVoicePrints() async {
    try {
      final ownerJson = await _secureStorage.read(key: 'owner_voice_prints');
      if (ownerJson != null) {
        final List<dynamic> decoded = jsonDecode(ownerJson);
        _ownerVoicePrints = decoded.map((e) => VoicePrint.fromMap(e)).toList();
      }
      
      final unknownJson = await _secureStorage.read(key: 'unknown_voice_prints');
      if (unknownJson != null) {
        final List<dynamic> decoded = jsonDecode(unknownJson);
        _unknownVoicePrints = decoded.map((e) => VoicePrint.fromMap(e)).toList();
      }
      
      Logger().info('Loaded ${_ownerVoicePrints.length} owner voice prints and ${_unknownVoicePrints.length} unknown', tag: 'VOICE_ID');
      
    } catch (e) {
      Logger().error('Error loading voice prints', tag: 'VOICE_ID', error: e);
    }
  }
  
  Future<void> clearVoicePrints() async {
    _ownerVoicePrints.clear();
    _unknownVoicePrints.clear();
    await _secureStorage.delete(key: 'owner_voice_prints');
    await _secureStorage.delete(key: 'unknown_voice_prints');
    Logger().info('Cleared all voice prints', tag: 'VOICE_ID');
  }
  
  bool hasOwnerVoice() {
    return _ownerVoicePrints.isNotEmpty;
  }
  
  int getOwnerVoiceCount() {
    return _ownerVoicePrints.length;
  }
  
  int getUnknownVoiceCount() {
    return _unknownVoicePrints.length;
  }
  
  List<VoicePrint> getUnknownAttempts() {
    return List.unmodifiable(_unknownVoicePrints);
  }
  
  Future<void> setConfidenceThreshold(double threshold) async {
    _confidenceThreshold = threshold.clamp(0.5, 0.99);
    Logger().info('Voice confidence threshold set to $_confidenceThreshold', tag: 'VOICE_ID');
  }
  
  double getConfidenceThreshold() => _confidenceThreshold;
  
  Map<String, dynamic> getVoiceStats() {
    return {
      'ownerVoiceCount': _ownerVoicePrints.length,
      'unknownVoiceCount': _unknownVoicePrints.length,
      'threshold': _confidenceThreshold,
      'isInitialized': _isInitialized,
      'averageQuality': _ownerVoicePrints.isNotEmpty 
          ? _ownerVoicePrints.map((v) => v.quality).reduce((a, b) => a + b) / _ownerVoicePrints.length
          : 0,
    };
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
  
  String getFormattedDate() {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute}';
  }
  
  String getShortSample() {
    if (sampleText.length > 50) {
      return sampleText.substring(0, 47) + '...';
    }
    return sampleText;
  }
  
  String getQualityRating() {
    if (quality >= 0.9) return 'Excellent';
    if (quality >= 0.7) return 'Good';
    if (quality >= 0.5) return 'Fair';
    return 'Poor';
  }
}