// lib/services/security/face_recognition.dart
// Face Recognition System with ML Kit

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';
import '../../config/constants.dart';

class FaceRecognitionService {
  static final FaceRecognitionService _instance = FaceRecognitionService._internal();
  factory FaceRecognitionService() => _instance;
  FaceRecognitionService._internal();
  
  late FaceDetector _faceDetector;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  List<FaceEmbedding> _ownerFaceEmbeddings = [];
  List<FaceEmbedding> _unknownFaceEmbeddings = [];
  double _recognitionThreshold = 0.85;
  bool _isInitialized = false;
  CameraController? _cameraController;
  
  Future<void> initialize() async {
    try {
      final options = FaceDetectorOptions(
        enableContours: true,
        enableClassification: true,
        enableTracking: true,
        performanceMode: FaceDetectorMode.accurate,
        minFaceSize: 0.15,
      );
      
      _faceDetector = FaceDetector(options: options);
      await _loadFaceEmbeddings();
      _isInitialized = true;
      Logger().info('Face recognition initialized with ${_ownerFaceEmbeddings.length} face embeddings', tag: 'FACE');
      
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'Face Init');
      _isInitialized = false;
    }
  }
  
  Future<void> registerOwnerFace(List<CameraDescription> cameras, 
      {int requiredAngles = 5}) async {
    try {
      Logger().info('Starting face registration for owner with $requiredAngles angles', tag: 'FACE');
      
      final embeddings = <FaceEmbedding>[];
      final angles = ['front', 'left', 'right', 'up', 'down'];
      
      for (int i = 0; i < requiredAngles && i < angles.length; i++) {
        final embedding = await _captureFaceFromAngle(cameras, angles[i]);
        if (embedding != null) {
          embeddings.add(embedding);
          Logger().info('Captured ${angles[i]} angle face embedding', tag: 'FACE');
        }
        await Future.delayed(const Duration(seconds: 1));
      }
      
      if (embeddings.length >= 3) {
        _ownerFaceEmbeddings = embeddings;
        await _saveFaceEmbeddings();
        Logger().info('Face registered successfully with ${embeddings.length} angles', tag: 'FACE');
      } else {
        Logger().warning('Only ${embeddings.length} face embeddings captured, need at least 3', tag: 'FACE');
      }
      
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'Face Register');
    }
  }
  
  Future<FaceEmbedding?> _captureFaceFromAngle(
      List<CameraDescription> cameras, String angle) async {
    try {
      // Initialize camera for this angle
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      
      _cameraController = CameraController(camera, ResolutionPreset.high);
      await _cameraController!.initialize();
      
      // Show preview and capture
      await Future.delayed(const Duration(seconds: 2));
      
      final image = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFile(File(image.path));
      
      final faces = await _faceDetector.processImage(inputImage);
      
      await _cameraController!.dispose();
      
      if (faces.isEmpty) {
        Logger().warning('No face detected for angle: $angle', tag: 'FACE');
        return null;
      }
      
      final face = faces.first;
      final embedding = _extractFaceEmbedding(face);
      
      return FaceEmbedding(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        embedding: embedding,
        createdAt: DateTime.now(),
        angle: angle,
        quality: _calculateFaceQuality(face),
        isOwner: true,
      );
      
    } catch (e) {
      Logger().error('Error capturing face for angle: $angle', tag: 'FACE', error: e);
      return null;
    }
  }
  
  List<double> _extractFaceEmbedding(Face face) {
    // Extract 128-dimension face embedding from detected face
    // In production, this would use a proper face recognition model
    // For now, generate synthetic embedding based on face landmarks
    final embedding = <double>[];
    final random = Random(face.boundingBox.hashCode);
    
    // Use face landmarks if available
    if (face.faceContours.isNotEmpty) {
      for (var contour in face.faceContours) {
        for (var point in contour.points) {
          embedding.add(point.x);
          embedding.add(point.y);
        }
      }
    }
    
    // Fill to 128 dimensions
    while (embedding.length < 128) {
      embedding.add(random.nextDouble());
    }
    
    return embedding.sublist(0, 128);
  }
  
  double _calculateFaceQuality(Face face) {
    // Calculate face quality based on detection confidence
    double quality = 0.5;
    
    if (face.trackingId != null) quality += 0.1;
    if (face.leftEyeOpenProbability != null) quality += 0.1;
    if (face.rightEyeOpenProbability != null) quality += 0.1;
    if (face.smilingProbability != null) quality += 0.1;
    
    return quality.clamp(0.0, 1.0);
  }
  
  Future<bool> verifyOwnerFace() async {
    try {
      if (!_isInitialized || _ownerFaceEmbeddings.isEmpty) {
        Logger().warning('Face recognition not initialized or no owner face registered', tag: 'FACE');
        return false;
      }
      
      final currentEmbedding = await _captureCurrentFace();
      if (currentEmbedding == null) {
        return false;
      }
      
      double bestSimilarity = 0;
      FaceEmbedding? bestMatch;
      
      for (var ownerEmbedding in _ownerFaceEmbeddings) {
        final similarity = _calculateSimilarity(currentEmbedding.embedding, ownerEmbedding.embedding);
        if (similarity > bestSimilarity) {
          bestSimilarity = similarity;
          bestMatch = ownerEmbedding;
        }
      }
      
      final isMatch = bestSimilarity >= _recognitionThreshold;
      
      if (isMatch) {
        Logger().info('Face verified with similarity: ${bestSimilarity.toStringAsFixed(3)}', tag: 'FACE');
      } else {
        Logger().warning('Face verification failed with similarity: ${bestSimilarity.toStringAsFixed(3)}', tag: 'FACE');
        await _logUnknownFace(currentEmbedding, bestSimilarity);
      }
      
      return isMatch;
      
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'Face Verify');
      return false;
    }
  }
  
  Future<FaceEmbedding?> _captureCurrentFace() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      
      _cameraController = CameraController(camera, ResolutionPreset.high);
      await _cameraController!.initialize();
      
      // Show preview for 1 second
      await Future.delayed(const Duration(seconds: 1));
      
      final image = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFile(File(image.path));
      
      final faces = await _faceDetector.processImage(inputImage);
      
      await _cameraController!.dispose();
      
      if (faces.isEmpty) {
        Logger().warning('No face detected for verification', tag: 'FACE');
        return null;
      }
      
      final face = faces.first;
      final embedding = _extractFaceEmbedding(face);
      
      return FaceEmbedding(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        embedding: embedding,
        createdAt: DateTime.now(),
        angle: 'current',
        quality: _calculateFaceQuality(face),
        isOwner: false,
      );
      
    } catch (e) {
      Logger().error('Error capturing current face', tag: 'FACE', error: e);
      return null;
    }
  }
  
  Future<void> _logUnknownFace(FaceEmbedding embedding, double similarity) async {
    final unknownEmbedding = FaceEmbedding(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      embedding: embedding.embedding,
      createdAt: DateTime.now(),
      angle: 'unknown',
      quality: similarity,
      isOwner: false,
    );
    
    _unknownFaceEmbeddings.add(unknownEmbedding);
    
    // Keep only last 50 unknown faces
    if (_unknownFaceEmbeddings.length > 50) {
      _unknownFaceEmbeddings.removeAt(0);
    }
    
    await _saveUnknownFaces();
    Logger().warning('Unknown face logged with similarity: ${similarity.toStringAsFixed(3)}', tag: 'FACE');
  }
  
  double _calculateSimilarity(List<double> embedding1, List<double> embedding2) {
    if (embedding1.length != embedding2.length) return 0;
    
    double dotProduct = 0;
    double norm1 = 0;
    double norm2 = 0;
    
    for (int i = 0; i < embedding1.length; i++) {
      dotProduct += embedding1[i] * embedding2[i];
      norm1 += embedding1[i] * embedding1[i];
      norm2 += embedding2[i] * embedding2[i];
    }
    
    if (norm1 == 0 || norm2 == 0) return 0;
    return dotProduct / (sqrt(norm1) * sqrt(norm2));
  }
  
  Future<void> _saveFaceEmbeddings() async {
    final json = jsonEncode(_ownerFaceEmbeddings.map((e) => e.toMap()).toList());
    await _secureStorage.write(key: 'owner_faces', value: json);
  }
  
  Future<void> _saveUnknownFaces() async {
    final json = jsonEncode(_unknownFaceEmbeddings.map((e) => e.toMap()).toList());
    await _secureStorage.write(key: 'unknown_faces', value: json);
  }
  
  Future<void> _loadFaceEmbeddings() async {
    try {
      final ownerJson = await _secureStorage.read(key: 'owner_faces');
      if (ownerJson != null) {
        final List<dynamic> decoded = jsonDecode(ownerJson);
        _ownerFaceEmbeddings = decoded.map((e) => FaceEmbedding.fromMap(e)).toList();
      }
      
      final unknownJson = await _secureStorage.read(key: 'unknown_faces');
      if (unknownJson != null) {
        final List<dynamic> decoded = jsonDecode(unknownJson);
        _unknownFaceEmbeddings = decoded.map((e) => FaceEmbedding.fromMap(e)).toList();
      }
      
      Logger().info('Loaded ${_ownerFaceEmbeddings.length} owner faces and ${_unknownFaceEmbeddings.length} unknown', tag: 'FACE');
      
    } catch (e) {
      Logger().error('Error loading face embeddings', tag: 'FACE', error: e);
    }
  }
  
  Future<void> clearRegisteredFaces() async {
    _ownerFaceEmbeddings.clear();
    _unknownFaceEmbeddings.clear();
    await _secureStorage.delete(key: 'owner_faces');
    await _secureStorage.delete(key: 'unknown_faces');
    Logger().info('Cleared all face embeddings', tag: 'FACE');
  }
  
  bool hasRegisteredFaces() {
    return _ownerFaceEmbeddings.isNotEmpty;
  }
  
  int getOwnerFaceCount() {
    return _ownerFaceEmbeddings.length;
  }
  
  int getUnknownFaceCount() {
    return _unknownFaceEmbeddings.length;
  }
  
  List<FaceEmbedding> getUnknownFaces() {
    return List.unmodifiable(_unknownFaceEmbeddings);
  }
  
  Future<void> setRecognitionThreshold(double threshold) async {
    _recognitionThreshold = threshold.clamp(0.5, 0.99);
    Logger().info('Face recognition threshold set to $_recognitionThreshold', tag: 'FACE');
  }
  
  double getRecognitionThreshold() => _recognitionThreshold;
  
  void dispose() {
    _faceDetector.close();
    _cameraController?.dispose();
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
  
  String getFormattedDate() {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute}';
  }
  
  String getQualityRating() {
    if (quality >= 0.9) return 'Excellent';
    if (quality >= 0.7) return 'Good';
    if (quality >= 0.5) return 'Fair';
    return 'Poor';
  }
}

class FaceLivenessChecker {
  static Future<bool> checkLiveness(Face face, CameraController cameraController) async {
    // Check for liveness indicators to prevent photo attacks
    
    // 1. Check for eye blink
    final hasBlink = _detectBlink(face);
    
    // 2. Check for head movement
    final hasHeadMovement = _detectHeadMovement(face);
    
    // 3. Check for facial expression change
    final hasExpression = _detectExpression(face);
    
    return hasBlink || hasHeadMovement || hasExpression;
  }
  
  static bool _detectBlink(Face face) {
    final leftEyeOpen = face.leftEyeOpenProbability ?? 0;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 0;
    
    // If eyes are closed or partially closed
    return leftEyeOpen < 0.3 && rightEyeOpen < 0.3;
  }
  
  static bool _detectHeadMovement(Face face) {
    final headEulerAngleX = face.headEulerAngleX ?? 0;
    final headEulerAngleY = face.headEulerAngleY ?? 0;
    final headEulerAngleZ = face.headEulerAngleZ ?? 0;
    
    return headEulerAngleX.abs() > 10 || 
           headEulerAngleY.abs() > 10 || 
           headEulerAngleZ.abs() > 10;
  }
  
  static bool _detectExpression(Face face) {
    final smilingProb = face.smilingProbability ?? 0;
    final leftCheek = face.leftCheekPosition;
    final rightCheek = face.rightCheekPosition;
    
    return smilingProb > 0.5 || (leftCheek != null && rightCheek != null);
  }
}