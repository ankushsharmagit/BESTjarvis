// lib/screens/about_screen.dart
// About JARVIS Screen

import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../config/constants.dart';
import '../widgets/glassmorphic_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JarvisColors.bgPrimary,
      appBar: AppBar(
        title: const Text('About JARVIS'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: JarvisColors.accentCyan),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // App Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  colors: [JarvisColors.accentCyan, JarvisColors.accentBlue],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: JarvisColors.accentCyan.withOpacity(0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'J',
                  style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // App Name
            const Text(
              'J.A.R.V.I.S',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                color: JarvisColors.accentCyan,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version ${AppConstants.appVersion}',
              style: TextStyle(fontSize: 14, color: JarvisColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: JarvisColors.accentCyan.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'ULTIMATE EDITION',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: JarvisColors.accentCyan),
              ),
            ),
            const SizedBox(height: 30),
            
            // Description
            GlassmorphicCard(
              child: Column(
                children: [
                  const Text(
                    AppConstants.fullName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Built exclusively for Mukul Sir, this is the most advanced AI assistant ever created for Android.',
                    style: TextStyle(fontSize: 14, color: JarvisColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Features Section
            GlassmorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✨ Key Features',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem('🤖', 'AI Intelligence', 'Powered by Google Gemini'),
                  _buildFeatureItem('🔐', 'Biometric Security', 'Face + Voice Recognition'),
                  _buildFeatureItem('📱', 'Complete Device Control', '500+ commands'),
                  _buildFeatureItem('🎤', 'Always-on Voice', 'Wake word detection'),
                  _buildFeatureItem('🛡️', 'Intruder Detection', 'Security monitoring'),
                  _buildFeatureItem('🔒', 'Private Vault', 'AES-256 encryption'),
                  _buildFeatureItem('⚡', 'Smart Automation', '8 pre-built routines'),
                  _buildFeatureItem('📡', 'Social Integration', 'WhatsApp, Telegram, Email'),
                  _buildFeatureItem('🧹', 'Smart Cleanup', 'AI-powered storage analysis'),
                  _buildFeatureItem('🎨', 'Iron Man UI', 'Holographic design'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Tech Specs
            GlassmorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚙️ Technical Specifications',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildSpecItem('Framework', 'Flutter 3.16+'),
                  _buildSpecItem('AI Engine', 'Google Gemini 1.5 Flash'),
                  _buildSpecItem('Voice', 'Speech-to-Text + TTS'),
                  _buildSpecItem('Security', 'ML Kit Face Detection'),
                  _buildSpecItem('Database', 'SQLite + Secure Storage'),
                  _buildSpecItem('Commands', '500+ voice commands'),
                  _buildSpecItem('Languages', 'English, Hindi, Hinglish'),
                  _buildSpecItem('Offline Mode', '300+ local responses'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Credits
            GlassmorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🙏 Credits',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildCreditItem('Owner', 'Mukul Sir'),
                  _buildCreditItem('AI Technology', 'Google Gemini API'),
                  _buildCreditItem('Voice Recognition', 'Google Speech-to-Text'),
                  _buildCreditItem('Face Detection', 'Google ML Kit'),
                  _buildCreditItem('UI Design', 'Iron Man Inspired'),
                  const SizedBox(height: 12),
                  const Divider(color: JarvisColors.dividerColor),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Made with ❤️ for Mukul Sir',
                      style: TextStyle(fontSize: 12, color: JarvisColors.accentCyan),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '© 2024 JARVIS AI Assistant',
                      style: TextStyle(fontSize: 10, color: JarvisColors.textHint),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 11, color: JarvisColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSpecItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: JarvisColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCreditItem(String role, String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              role,
              style: TextStyle(fontSize: 13, color: JarvisColors.textSecondary),
            ),
          ),
          Text(
            name,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}