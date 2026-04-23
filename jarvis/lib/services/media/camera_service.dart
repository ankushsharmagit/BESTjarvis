// lib/services/media/camera_service.dart
// Camera Service with QR Scanning and Image Analysis

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();
  
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  QRViewController? _qrController;
  
  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      Logger().info('Camera service initialized', tag: 'CAMERA');
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'Camera Init');
    }
  }
  
  Future<CameraController> getCamera({CameraLensDirection direction = CameraLensDirection.rear}) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }
    
    final camera = _cameras!.firstWhere(
      (c) => c.lensDirection == direction,
      orElse: () => _cameras!.first,
    );
    
    _cameraController = CameraController(camera, ResolutionPreset.high);
    await _cameraController!.initialize();
    
    return _cameraController!;
  }
  
  Future<XFile> takePhoto() async {
    try {
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        await getCamera();
      }
      
      final image = await _cameraController!.takePicture();
      Logger().info('Photo taken: ${image.path}', tag: 'CAMERA');
      return image;
      
    } catch (e) {
      Logger().error('Take photo error', tag: 'CAMERA', error: e);
      rethrow;
    }
  }
  
  Future<File> pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        return File(image.path);
      }
      throw Exception('No image selected');
    } catch (e) {
      Logger().error('Pick image error', tag: 'CAMERA', error: e);
      rethrow;
    }
  }
  
  Future<File> pickVideoFromGallery() async {
    try {
      final picker = ImagePicker();
      final video = await picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        return File(video.path);
      }
      throw Exception('No video selected');
    } catch (e) {
      Logger().error('Pick video error', tag: 'CAMERA', error: e);
      rethrow;
    }
  }
  
  Future<File> recordVideo() async {
    try {
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        await getCamera();
      }
      
      await _cameraController!.startVideoRecording();
      await Future.delayed(const Duration(seconds: 10)); // Record for 10 seconds
      final video = await _cameraController!.stopVideoRecording();
      
      Logger().info('Video recorded: ${video.path}', tag: 'CAMERA');
      return File(video.path);
      
    } catch (e) {
      Logger().error('Record video error', tag: 'CAMERA', error: e);
      rethrow;
    }
  }
  
  Future<String> scanQRCode() async {
    // This would be implemented with QRView widget
    Logger().info('QR Code scanning started', tag: 'CAMERA');
    return ''; // Placeholder
  }
  
  Future<String> scanBarcode() async {
    Logger().info('Barcode scanning started', tag: 'CAMERA');
    return '';
  }
  
  Future<String> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final textDetector = GoogleMlKit.vision.textRecognizer();
      final recognizedText = await textDetector.processImage(inputImage);
      await textDetector.close();
      
      String extractedText = '';
      for (var block in recognizedText.blocks) {
        for (var line in block.lines) {
          extractedText += line.text + '\n';
        }
      }
      
      Logger().info('Text extracted from image: ${extractedText.length} chars', tag: 'CAMERA');
      return extractedText;
      
    } catch (e) {
      Logger().error('Text extraction error', tag: 'CAMERA', error: e);
      return '';
    }
  }
  
  Future<List<String>> detectObjectsInImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final objectDetector = GoogleMlKit.vision.objectDetector();
      final objects = await objectDetector.processImage(inputImage);
      await objectDetector.close();
      
      final detectedObjects = objects.map((obj) => obj.labels.first.text).toList();
      Logger().info('Objects detected: $detectedObjects', tag: 'CAMERA');
      return detectedObjects;
      
    } catch (e) {
      Logger().error('Object detection error', tag: 'CAMERA', error: e);
      return [];
    }
  }
  
  Future<List<String>> detectLabelsInImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final imageLabeler = GoogleMlKit.vision.imageLabeler();
      final labels = await imageLabeler.processImage(inputImage);
      await imageLabeler.close();
      
      final detectedLabels = labels.map((label) => label.label).toList();
      Logger().info('Labels detected: $detectedLabels', tag: 'CAMERA');
      return detectedLabels;
      
    } catch (e) {
      Logger().error('Label detection error', tag: 'CAMERA', error: e);
      return [];
    }
  }
  
  Future<bool> detectFace(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final faceDetector = GoogleMlKit.vision.faceDetector();
      final faces = await faceDetector.processImage(inputImage);
      await faceDetector.close();
      
      return faces.isNotEmpty;
      
    } catch (e) {
      Logger().error('Face detection error', tag: 'CAMERA', error: e);
      return false;
    }
  }
  
  Future<void> switchCamera() async {
    try {
      final currentLens = _cameraController?.description.lensDirection;
      final newLens = currentLens == CameraLensDirection.front 
          ? CameraLensDirection.rear 
          : CameraLensDirection.front;
      
      await getCamera(direction: newLens);
      Logger().info('Switched camera to $newLens', tag: 'CAMERA');
      
    } catch (e) {
      Logger().error('Switch camera error', tag: 'CAMERA', error: e);
    }
  }
  
  Future<void> toggleFlash() async {
    try {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        final isFlashOn = _cameraController!.value.flashMode == FlashMode.torch;
        await _cameraController!.setFlashMode(isFlashOn ? FlashMode.off : FlashMode.torch);
        Logger().info('Flash toggled', tag: 'CAMERA');
      }
    } catch (e) {
      Logger().error('Toggle flash error', tag: 'CAMERA', error: e);
    }
  }
  
  Future<void> setZoom(double zoom) async {
    try {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        await _cameraController!.setZoomLevel(zoom);
      }
    } catch (e) {
      Logger().error('Set zoom error', tag: 'CAMERA', error: e);
    }
  }
  
  Future<void> dispose() async {
    await _cameraController?.dispose();
    await _qrController?.dispose();
  }
}