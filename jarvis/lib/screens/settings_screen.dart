// lib/screens/settings_screen.dart
// Complete Settings Screen

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/colors.dart';
import '../services/security/face_recognition.dart';
import '../services/voice/voice_id_service.dart';
import '../widgets/glassmorphic_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _wakeWordEnabled = true;
  bool _faceAuthEnabled = true;
  bool _voiceAuthEnabled = true;
  bool _animationsEnabled = true;
  String _selectedLanguage = 'hinglish';
  double _voiceSpeed = 0.5;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _wakeWordEnabled = prefs.getBool('wake_word_enabled') ?? true;
      _faceAuthEnabled = prefs.getBool('face_auth_enabled') ?? true;
      _voiceAuthEnabled = prefs.getBool('voice_auth_enabled') ?? true;
      _animationsEnabled = prefs.getBool('animations_enabled') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'hinglish';
      _voiceSpeed = prefs.getDouble('voice_speed') ?? 0.5;
    });
  }
  
  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    else if (value is String) await prefs.setString(key, value);
    else if (value is double) await prefs.setDouble(key, value);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JarvisColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: JarvisColors.accentCyan),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSecuritySection(),
            const SizedBox(height: 16),
            _buildVoiceSection(),
            const SizedBox(height: 16),
            _buildAppearanceSection(),
            const SizedBox(height: 16),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSecuritySection() {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.security, color: JarvisColors.accentCyan),
              SizedBox(width: 8),
              Text('Security', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: JarvisColors.dividerColor),
          SwitchListTile(
            title: const Text('Wake Word Detection'),
            subtitle: const Text('Say "JARVIS" to activate'),
            value: _wakeWordEnabled,
            onChanged: (value) {
              setState(() => _wakeWordEnabled = value);
              _saveSetting('wake_word_enabled', value);
            },
            activeColor: JarvisColors.accentCyan,
          ),
          SwitchListTile(
            title: const Text('Face Authentication'),
            subtitle: const Text('Use face recognition for sensitive commands'),
            value: _faceAuthEnabled,
            onChanged: (value) {
              setState(() => _faceAuthEnabled = value);
              _saveSetting('face_auth_enabled', value);
            },
            activeColor: JarvisColors.accentCyan,
          ),
          SwitchListTile(
            title: const Text('Voice Authentication'),
            subtitle: const Text('Verify speaker identity for commands'),
            value: _voiceAuthEnabled,
            onChanged: (value) {
              setState(() => _voiceAuthEnabled = value);
              _saveSetting('voice_auth_enabled', value);
            },
            activeColor: JarvisColors.accentCyan,
          ),
        ],
      ),
    );
  }
  
  Widget _buildVoiceSection() {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.volume_up, color: JarvisColors.accentCyan),
              SizedBox(width: 8),
              Text('Voice Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: JarvisColors.dividerColor),
          ListTile(
            title: const Text('Language'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              items: const [
                DropdownMenuItem(value: 'hinglish', child: Text('Hinglish')),
                DropdownMenuItem(value: 'english', child: Text('English')),
                DropdownMenuItem(value: 'hindi', child: Text('Hindi')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedLanguage = value);
                  _saveSetting('language', value);
                }
              },
              dropdownColor: JarvisColors.bgCard,
            ),
          ),
          ListTile(
            title: const Text('Speech Speed'),
            subtitle: Slider(
              value: _voiceSpeed,
              min: 0.3,
              max: 1.0,
              activeColor: JarvisColors.accentCyan,
              onChanged: (value) {
                setState(() => _voiceSpeed = value);
                _saveSetting('voice_speed', value);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAppearanceSection() {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.palette, color: JarvisColors.accentCyan),
              SizedBox(width: 8),
              Text('Appearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: JarvisColors.dividerColor),
          SwitchListTile(
            title: const Text('Animations'),
            subtitle: const Text('Enable UI animations'),
            value: _animationsEnabled,
            onChanged: (value) {
              setState(() => _animationsEnabled = value);
              _saveSetting('animations_enabled', value);
            },
            activeColor: JarvisColors.accentCyan,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAboutSection() {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info, color: JarvisColors.accentCyan),
              SizedBox(width: 8),
              Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: JarvisColors.dividerColor),
          ListTile(
            leading: const Icon(Icons.android, color: JarvisColors.accentCyan),
            title: const Text('Version'),
            subtitle: const Text('JARVIS v4.0 ULTIMATE'),
          ),
          ListTile(
            leading: const Icon(Icons.code, color: JarvisColors.accentCyan),
            title: const Text('View Code'),
            onTap: () => Navigator.pushNamed(context, '/code-viewer'),
          ),
          ListTile(
            leading: const Icon(Icons.health_and_safety, color: JarvisColors.accentCyan),
            title: const Text('Diagnostics'),
            onTap: () => Navigator.pushNamed(context, '/diagnostic'),
          ),
        ],
      ),
    );
  }
}