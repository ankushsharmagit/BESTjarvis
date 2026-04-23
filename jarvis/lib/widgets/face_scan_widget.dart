// lib/widgets/face_scan_widget.dart
// Face Scanning Animation Widget for Camera

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../config/colors.dart';

class FaceScanWidget extends StatefulWidget {
  final Function(bool) onFaceDetected;
  final Function(List<Face>) onFacesDetected;
  final VoidCallback? onScanComplete;
  final String title;
  final bool showGuide;
  
  const FaceScanWidget({
    Key? key,
    required this.onFaceDetected,
    required this.onFacesDetected,
    this.onScanComplete,
    this.title = 'Face Verification',
    this.showGuide = true,
  }) : super(key: key);

  @override
  State<FaceScanWidget> createState() => _FaceScanWidgetState();
}

class _FaceScanWidgetState extends State<FaceScanWidget>
    with SingleTickerProviderStateMixin {
  
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isDetecting = false;
  bool _isScanning = false;
  int _scanProgress = 0;
  Timer? _scanTimer;
  
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;
  late AnimationController _pulseController;
  
  List<Face> _detectedFaces = [];
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeDetector();
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
    _scanLineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _scanLineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }
  
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    
    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    
    await _cameraController!.initialize();
    await _cameraController!.startImageStream(_processCameraImage);
    
    if (mounted) setState(() {});
  }
  
  void _initializeDetector() {
    final options = FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
    );
    _faceDetector = FaceDetector(options: options);
  }
  
  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDetecting || _faceDetector == null) return;
    
    _isDetecting = true;
    
    try {
      final faces = await _faceDetector!.processImage(
        InputImage.fromBytes(
          bytes: image.planes[0].bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: InputImageRotation.rotation90deg,
            format: InputImageFormat.nv21,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        ),
      );
      
      _detectedFaces = faces;
      widget.onFacesDetected(faces);
      widget.onFaceDetected(faces.isNotEmpty);
      
      if (faces.isNotEmpty && !_isScanning) {
        _startScanning();
      }
      
    } catch (e) {
      // Handle error silently
    }
    
    _isDetecting = false;
  }
  
  void _startScanning() {
    _isScanning = true;
    _scanProgress = 0;
    
    _scanTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _scanProgress += 5;
        if (_scanProgress >= 100) {
          timer.cancel();
          _isScanning = false;
          widget.onScanComplete?.call();
        }
      });
    });
  }
  
  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector?.close();
    _scanTimer?.cancel();
    _scanLineController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_cameraController != null && _cameraController!.value.isInitialized)
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            ),
          
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  radius: 1.5,
                  center: Alignment.center,
                ),
              ),
            ),
          ),
          
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _detectedFaces.isNotEmpty 
                      ? JarvisColors.success 
                      : JarvisColors.accentCyan,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_detectedFaces.isNotEmpty 
                        ? JarvisColors.success 
                        : JarvisColors.accentCyan).withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _scanLineAnimation,
                    builder: (context, child) {
                      return Positioned(
                        left: 0,
                        right: 0,
                        top: _scanLineAnimation.value * 280,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.transparent, JarvisColors.accentCyan, Colors.transparent],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: JarvisColors.accentCyan.withOpacity(0.8),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Corner markers
                  Positioned(top: 0, left: 0, child: _buildCorner(TopLeft)),
                  Positioned(top: 0, right: 0, child: _buildCorner(TopRight)),
                  Positioned(bottom: 0, left: 0, child: _buildCorner(BottomLeft)),
                  Positioned(bottom: 0, right: 0, child: _buildCorner(BottomRight)),
                ],
              ),
            ),
          ),
          
          if (_isScanning)
            Positioned(
              bottom: 100,
              left: 50,
              right: 50,
              child: LinearProgressIndicator(
                value: _scanProgress / 100,
                backgroundColor: JarvisColors.textHint.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation(JarvisColors.success),
              ),
            ),
          
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: JarvisColors.bgCard.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _detectedFaces.isNotEmpty 
                          ? JarvisColors.success 
                          : JarvisColors.warning,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: JarvisColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _detectedFaces.isNotEmpty 
                            ? '✅ Face Detected! Scanning...' 
                            : '🎯 Place your face in the frame',
                        style: TextStyle(
                          fontSize: 14,
                          color: _detectedFaces.isNotEmpty 
                              ? JarvisColors.success 
                              : JarvisColors.textSecondary,
                        ),
                      ),
                      if (widget.showGuide && !_detectedFaces.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Look straight at the camera',
                            style: TextStyle(fontSize: 12, color: JarvisColors.textHint),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCorner(CornerPosition position) {
    bool isTop = position == TopLeft || position == TopRight;
    bool isLeft = position == TopLeft || position == BottomLeft;
    
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? BorderSide(color: JarvisColors.accentCyan, width: 3) : BorderSide.none,
          bottom: !isTop ? BorderSide(color: JarvisColors.accentCyan, width: 3) : BorderSide.none,
          left: isLeft ? BorderSide(color: JarvisColors.accentCyan, width: 3) : BorderSide.none,
          right: !isLeft ? BorderSide(color: JarvisColors.accentCyan, width: 3) : BorderSide.none,
        ),
      ),
    );
  }
}

enum CornerPosition { TopLeft, TopRight, BottomLeft, BottomRight }