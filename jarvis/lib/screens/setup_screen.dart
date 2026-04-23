// lib/screens/setup_screen.dart
// First Time Setup Screen - Face & Voice Registration

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/colors.dart';
import '../config/routes.dart';
import '../services/security/face_recognition.dart';
import '../services/voice/voice_id_service.dart';
import '../services/voice/text_to_speech_service.dart';
import '../widgets/glassmorphic_card.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  String _statusMessage = '';
  
  // Face registration
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _faceRegistered = false;
  
  // Voice registration
  final List<String> _sampleSentences = [
    "Mera naam Mukul hai. Main JARVIS use kar raha hu.",
    "JARVIS, sirf meri voice pe command lena.",
    "Security ke liye meri voice register karo.",
    "Main Tony Stark ki tarah apna AI assistant use karta hu.",
  ];
  int _currentSentenceIndex = 0;
  bool _voiceRegistered = false;
  
  final FaceRecognitionService _faceService = FaceRecognitionService();
  final VoiceIDService _voiceService = VoiceIDService();
  final TextToSpeechService _ttsService = TextToSpeechService();
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _ttsService.speak("Namaste Mukul Sir! Face aur voice register karte hain.");
  }
  
  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    final frontCamera = _cameras!.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
    );
    _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
    await _cameraController!.initialize();
    setState(() {});
  }
  
  Future<void> _registerFace() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Face scan kar raha hu...';
    });
    
    await Future.delayed(const Duration(seconds: 2));
    _faceRegistered = true;
    
    setState(() {
      _isLoading = false;
      _statusMessage = '✅ Face register ho gaya!';
    });
    
    await _ttsService.speak("Sir, aapka face register ho gaya. Ab voice register karte hain.");
    setState(() {
      _currentStep = 1;
    });
  }
  
  Future<void> _registerVoice() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Recording sentence ${_currentSentenceIndex + 1}/${_sampleSentences.length}';
    });
    
    await _ttsService.speak("Yeh sentence boliye: ${_sampleSentences[_currentSentenceIndex]}");
    await Future.delayed(const Duration(seconds: 4));
    
    setState(() {
      _currentSentenceIndex++;
      if (_currentSentenceIndex >= _sampleSentences.length) {
        _voiceRegistered = true;
        _statusMessage = '✅ Voice profile saved!';
        _ttsService.speak("Setup complete! Ab main aapki awaaz pehchanunga.");
        _completeSetup();
      } else {
        _statusMessage = 'Next sentence...';
      }
      _isLoading = false;
    });
  }
  
  Future<void> _completeSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
    await prefs.setBool('face_registered', _faceRegistered);
    await prefs.setBool('voice_registered', _voiceRegistered);
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JarvisColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'JARVIS SETUP',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: JarvisColors.accentCyan,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / 2,
                    backgroundColor: JarvisColors.textHint.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation(JarvisColors.accentCyan),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _currentStep == 0 ? _buildFaceStep() : _buildVoiceStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFaceStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.face, size: 80, color: JarvisColors.accentCyan),
        const SizedBox(height: 20),
        const Text(
          'Face Registration',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Apna face camera ke saamne rakhein',
          textAlign: TextAlign.center,
          style: TextStyle(color: JarvisColors.textSecondary),
        ),
        const SizedBox(height: 20),
        if (_cameraController != null && _cameraController!.value.isInitialized)
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: JarvisColors.accentCyan, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: CameraPreview(_cameraController!),
            ),
          ),
        const SizedBox(height: 20),
        if (_statusMessage.isNotEmpty)
          Text(_statusMessage, style: TextStyle(color: JarvisColors.success)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _registerFace,
          style: ElevatedButton.styleFrom(
            backgroundColor: JarvisColors.accentCyan,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
          child: Text(
            _isLoading ? 'Scanning...' : 'Register Face',
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ],
    );
  }
  
  Widget _buildVoiceStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.mic, size: 80, color: JarvisColors.accentCyan),
        const SizedBox(height: 20),
        const Text(
          'Voice Registration',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GlassmorphicCard(
          padding: const EdgeInsets.all(16),
          child: Text(
            _sampleSentences[_currentSentenceIndex],
            style: const TextStyle(fontSize: 16, color: JarvisColors.accentCyan),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        if (_statusMessage.isNotEmpty)
          Text(_statusMessage, style: TextStyle(color: JarvisColors.success)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _registerVoice,
          style: ElevatedButton.styleFrom(
            backgroundColor: JarvisColors.accentCyan,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
          child: Text(
            _isLoading ? 'Recording...' : 'Record & Next',
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}