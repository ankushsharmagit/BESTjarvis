// lib/screens/home_screen.dart
// Main Home Screen - Iron Man HUD Interface

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/colors.dart';
import '../config/routes.dart';
import '../services/core/command_processor.dart';
import '../services/voice/speech_to_text_service.dart';
import '../services/voice/text_to_speech_service.dart';
import '../services/voice/wake_word_service.dart';
import '../models/chat_message.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/status_card_widget.dart';
import '../widgets/wave_animation_widget.dart';
import '../widgets/particle_background.dart';
import '../utils/logger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CommandProcessor _commandProcessor = CommandProcessor();
  final SpeechToTextService _sttService = SpeechToTextService();
  final TextToSpeechService _ttsService = TextToSpeechService();
  final WakeWordService _wakeWordService = WakeWordService();
  
  List<ChatMessage> _messages = [];
  bool _isListening = false;
  bool _isProcessing = false;
  String _currentUserSpeech = '';
  bool _wakeWordEnabled = true;
  String _batteryLevel = '85%';
  String _time = '';
  String _greeting = '';
  ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _initialize();
  }
  
  Future<void> _initialize() async {
    await _sttService.initialize();
    await _ttsService.initialize();
    await _commandProcessor.initialize();
    
    final prefs = await SharedPreferences.getInstance();
    _wakeWordEnabled = prefs.getBool('wake_word_enabled') ?? true;
    
    if (_wakeWordEnabled) {
      await _wakeWordService.initialize();
      _wakeWordService.onWakeWordDetected.listen((detected) {
        if (detected) {
          setState(() {
            _isListening = true;
          });
          _ttsService.speak("Yes Sir?");
        }
      });
      _wakeWordService.onCommand.listen((command) async {
        await _processCommand(command);
      });
    }
    
    _updateTime();
    _updateGreeting();
    Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
    _addWelcomeMessage();
  }
  
  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    });
  }
  
  void _updateGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) _greeting = 'Good Morning';
    else if (hour < 17) _greeting = 'Good Afternoon';
    else _greeting = 'Good Evening';
    setState(() {});
  }
  
  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      id: 'welcome',
      content: '$_greeting Mukul Sir! 👋\n\nI am JARVIS, your personal AI assistant. $_greetingMessage\n\nHow can I help you today?',
      type: MessageType.success,
      timestamp: DateTime.now(),
      isFromUser: false,
    );
    _messages.add(welcomeMessage);
    _scrollToBottom();
  }
  
  String get _greetingMessage {
    if (_greeting == 'Good Morning') return 'Hope you had a great sleep! ☀️';
    if (_greeting == 'Good Afternoon') return 'How is your day going? 🌤️';
    return 'Time to wind down? 🌙';
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  Future<void> _startListening() async {
    if (_isListening) {
      await _sttService.stopListening();
      setState(() {
        _isListening = false;
      });
      return;
    }
    
    setState(() {
      _isListening = true;
      _currentUserSpeech = '';
    });
    
    await _sttService.startListening();
    _sttService.recognitionStream.listen((text) {
      setState(() {
        _currentUserSpeech = text;
      });
    });
    
    // Auto-stop after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (_isListening) {
        _stopListeningAndProcess();
      }
    });
  }
  
  Future<void> _stopListeningAndProcess() async {
    await _sttService.stopListening();
    setState(() {
      _isListening = false;
    });
    
    if (_currentUserSpeech.isNotEmpty) {
      await _processCommand(_currentUserSpeech);
    }
  }
  
  Future<void> _processCommand(String command) async {
    setState(() {
      _isProcessing = true;
    });
    
    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: command,
      type: MessageType.command,
      timestamp: DateTime.now(),
      isFromUser: true,
    );
    _messages.add(userMessage);
    _scrollToBottom();
    
    // Add thinking indicator
    final thinkingId = DateTime.now().millisecondsSinceEpoch.toString();
    final thinkingMessage = ChatMessage(
      id: thinkingId,
      content: '...',
      type: MessageType.thinking,
      timestamp: DateTime.now(),
      isFromUser: false,
      isTyping: true,
    );
    _messages.add(thinkingMessage);
    _scrollToBottom();
    
    // Process command
    final response = await _commandProcessor.processCommand(command);
    
    // Remove thinking message
    _messages.removeWhere((m) => m.id == thinkingId);
    
    // Add response
    final responseMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: response,
      type: MessageType.response,
      timestamp: DateTime.now(),
      isFromUser: false,
    );
    _messages.add(responseMessage);
    _scrollToBottom();
    
    // Speak response
    await _ttsService.speak(response);
    
    setState(() {
      _isProcessing = false;
      _currentUserSpeech = '';
    });
  }
  
  Future<void> _quickAction(String action) async {
    await _processCommand(action);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Particle Background
          const ParticleBackground(),
          
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Status Bar
                _buildStatusBar(),
                
                // Arc Reactor
                GestureDetector(
                  onTap: _startListening,
                  child: Container(
                    width: 160,
                    height: 160,
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _isListening ? Colors.red : JarvisColors.accentCyan,
                          _isListening ? Colors.red.shade800 : JarvisColors.accentBlue,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? Colors.red : JarvisColors.accentCyan).withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.flash_on, size: 50, color: Colors.white),
                    ),
                  ),
                ),
                
                // Status Dashboard
                _buildStatusDashboard(),
                
                // Chat History
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildChatBubble(message);
                    },
                  ),
                ),
                
                // Current Speech Display
                if (_currentUserSpeech.isNotEmpty)
                  GlassmorphicCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      _currentUserSpeech,
                      style: const TextStyle(color: JarvisColors.accentCyan),
                    ),
                  ),
                
                // Quick Actions
                _buildQuickActions(),
                
                // Mic Button
                GestureDetector(
                  onTap: _isProcessing ? null : _startListening,
                  child: Container(
                    width: 65,
                    height: 65,
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          _isListening ? Colors.red : JarvisColors.accentCyan,
                          _isListening ? Colors.red.shade700 : JarvisColors.accentBlue,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? Colors.red : JarvisColors.accentCyan).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                // Wave Animation
                if (_isListening || _isProcessing)
                  const WaveAnimationWidget(isActive: true),
                
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: JarvisColors.success,
                  boxShadow: [
                    BoxShadow(
                      color: JarvisColors.success.withOpacity(0.5),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'ONLINE',
                style: TextStyle(fontSize: 10, color: JarvisColors.success),
              ),
            ],
          ),
          const Text(
            'J.A.R.V.I.S',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: JarvisColors.accentCyan,
              letterSpacing: 2,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.dashboard, size: 22),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.dashboard),
                color: JarvisColors.accentCyan,
              ),
              IconButton(
                icon: const Icon(Icons.settings, size: 22),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
                color: JarvisColors.accentCyan,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusDashboard() {
    return HorizontalStatusScroll(
      items: [
        StatusCardData(icon: Icons.battery_charging_full, title: 'Battery', value: _batteryLevel),
        StatusCardData(icon: Icons.wifi, title: 'WiFi', value: '📶'),
        StatusCardData(icon: Icons.access_time, title: 'Time', value: _time),
        StatusCardData(icon: Icons.memory, title: 'RAM', value: '3.2GB'),
        StatusCardData(icon: Icons.thermostat, title: 'Temp', value: '28°C'),
      ],
    );
  }
  
  Widget _buildChatBubble(ChatMessage message) {
    final isUser = message.isFromUser;
    return Container(
      margin: EdgeInsets.only(
        left: isUser ? MediaQuery.of(context).size.width * 0.2 : 8,
        right: isUser ? 8 : MediaQuery.of(context).size.width * 0.2,
        top: 8,
        bottom: 8,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? JarvisColors.chatUserBubble : JarvisColors.chatJarvisBubble,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.content,
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
      ),
    );
  }
  
  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          QuickActionButton(icon: Icons.phone, label: 'Call', onTap: () => _quickAction('call')),
          QuickActionButton(icon: Icons.message, label: 'Message', onTap: () => _quickAction('message')),
          QuickActionButton(icon: Icons.flashlight_on, label: 'Flash', onTap: () => _quickAction('flashlight on')),
          QuickActionButton(icon: Icons.camera_alt, label: 'Camera', onTap: () => _quickAction('open camera')),
          QuickActionButton(icon: Icons.music_note, label: 'Music', onTap: () => _quickAction('play music')),
          QuickActionButton(icon: Icons.cleaning_services, label: 'Clean', onTap: () => _quickAction('phone saaf karo')),
          QuickActionButton(icon: Icons.lock, label: 'Vault', onTap: () => _quickAction('vault kholo')),
          QuickActionButton(icon: Icons.help, label: 'Help', onTap: () => _quickAction('help')),
        ],
      ),
    );
  }
}