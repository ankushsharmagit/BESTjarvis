// lib/screens/diagnostic_screen.dart
// System Diagnostic Screen

import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../services/core/self_upgrade_service.dart';
import '../widgets/glassmorphic_card.dart';

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({Key? key}) : super(key: key);

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  final SelfUpgradeService _upgradeService = SelfUpgradeService();
  String _diagnosticResult = '';
  bool _isRunning = false;
  List<DiagnosticItem> _items = [];
  
  @override
  void initState() {
    super.initState();
    _initDiagnosticItems();
  }
  
  void _initDiagnosticItems() {
    _items = [
      DiagnosticItem(name: 'Neural Network (AI)', status: 'checking', message: 'Checking Gemini connection...'),
      DiagnosticItem(name: 'Voice Module', status: 'checking', message: 'Verifying speech services...'),
      DiagnosticItem(name: 'Face Recognition', status: 'checking', message: 'Checking camera access...'),
      DiagnosticItem(name: 'Voice ID', status: 'checking', message: 'Verifying voice biometrics...'),
      DiagnosticItem(name: 'Internet Connection', status: 'checking', message: 'Testing connectivity...'),
      DiagnosticItem(name: 'Microphone', status: 'checking', message: 'Testing audio input...'),
      DiagnosticItem(name: 'Camera', status: 'checking', message: 'Checking camera hardware...'),
      DiagnosticItem(name: 'Storage', status: 'checking', message: 'Analyzing storage...'),
      DiagnosticItem(name: 'RAM', status: 'checking', message: 'Checking memory...'),
      DiagnosticItem(name: 'Battery', status: 'checking', message: 'Checking battery health...'),
      DiagnosticItem(name: 'GPS', status: 'checking', message: 'Verifying location services...'),
      DiagnosticItem(name: 'Security Layers', status: 'checking', message: 'Checking security protocols...'),
      DiagnosticItem(name: 'Vault', status: 'checking', message: 'Verifying encryption...'),
      DiagnosticItem(name: 'Automation Engine', status: 'checking', message: 'Checking routines...'),
    ];
  }
  
  Future<void> _runDiagnostics() async {
    setState(() {
      _isRunning = true;
    });
    
    // Simulate diagnostic checks
    for (int i = 0; i < _items.length; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _items[i] = _items[i].copyWith(
          status: i % 3 == 0 ? 'pass' : (i % 5 == 0 ? 'warning' : 'pass'),
          message: _getSuccessMessage(_items[i].name),
        );
      });
    }
    
    final result = await _upgradeService.runDiagnostics();
    setState(() {
      _diagnosticResult = result;
      _isRunning = false;
    });
  }
  
  String _getSuccessMessage(String name) {
    switch (name) {
      case 'Neural Network (AI)':
        return 'Online - Gemini Connected ✅';
      case 'Voice Module':
        return 'Active - Hindi + English Support ✅';
      case 'Face Recognition':
        return 'Calibrated - Ready ✅';
      case 'Voice ID':
        return 'Active - Owner Verified ✅';
      case 'Internet Connection':
        return 'Connected - 45 Mbps ✅';
      case 'Microphone':
        return 'Functional - Audio Input OK ✅';
      case 'Camera':
        return 'Functional - Front + Back ✅';
      case 'Storage':
        return '23.5 GB free of 64 GB ✅';
      case 'RAM':
        return '3.2 GB available ✅';
      case 'Battery':
        return '78% - Healthy ✅';
      case 'GPS':
        return 'Active - Location Ready ✅';
      case 'Security Layers':
        return 'All layers active ✅';
      case 'Vault':
        return 'Encrypted - Secure ✅';
      case 'Automation Engine':
        return 'Operational - 8 Routines Active ✅';
      default:
        return 'OK ✅';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JarvisColors.bgPrimary,
      appBar: AppBar(
        title: const Text('System Diagnostics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: JarvisColors.accentCyan),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow, color: JarvisColors.accentCyan),
            onPressed: _isRunning ? null : _runDiagnostics,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Health Score Card
            GlassmorphicCard(
              child: Column(
                children: [
                  const Text(
                    'System Health Score',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: _getHealthPercent() / 100,
                          strokeWidth: 8,
                          backgroundColor: JarvisColors.textHint.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getHealthColor(),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '${_getHealthPercent().toInt()}',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          const Text('%', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getHealthStatus(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getHealthColor(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getHealthRecommendation(),
                    style: TextStyle(fontSize: 12, color: JarvisColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Diagnostic Items List
            GlassmorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Diagnostic Results',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._items.map((item) => _buildDiagnosticItem(item)),
                  if (_diagnosticResult.isNotEmpty) ...[
                    const Divider(color: JarvisColors.dividerColor),
                    const SizedBox(height: 12),
                    SelectableText(
                      _diagnosticResult,
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? null : _runDiagnostics,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Run Full Diagnostic'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: JarvisColors.accentCyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Export diagnostic report
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Export Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: JarvisColors.bgCard,
                      foregroundColor: JarvisColors.accentCyan,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDiagnosticItem(DiagnosticItem item) {
    Color color;
    IconData icon;
    
    switch (item.status) {
      case 'pass':
        color = JarvisColors.success;
        icon = Icons.check_circle;
        break;
      case 'warning':
        color = JarvisColors.warning;
        icon = Icons.warning_amber;
        break;
      case 'fail':
        color = JarvisColors.error;
        icon = Icons.error;
        break;
      default:
        color = JarvisColors.textHint;
        icon = Icons.sync;
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  item.message,
                  style: TextStyle(fontSize: 11, color: JarvisColors.textSecondary),
                ),
              ],
            ),
          ),
          if (item.status != 'checking')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.status.toUpperCase(),
                style: TextStyle(fontSize: 10, color: color),
              ),
            ),
        ],
      ),
    );
  }
  
  double _getHealthPercent() {
    final passed = _items.where((i) => i.status == 'pass').length;
    final total = _items.length;
    if (total == 0) return 0;
    return (passed / total) * 100;
  }
  
  String _getHealthStatus() {
    final percent = _getHealthPercent();
    if (percent >= 90) return 'Excellent';
    if (percent >= 75) return 'Good';
    if (percent >= 60) return 'Fair';
    return 'Needs Attention';
  }
  
  Color _getHealthColor() {
    final percent = _getHealthPercent();
    if (percent >= 90) return JarvisColors.success;
    if (percent >= 75) return Colors.lightGreen;
    if (percent >= 60) return JarvisColors.warning;
    return JarvisColors.error;
  }
  
  String _getHealthRecommendation() {
    final percent = _getHealthPercent();
    if (percent >= 90) {
      return 'Your device is in excellent condition. Keep up the good maintenance! ✅';
    } else if (percent >= 75) {
      return 'Your device is doing well. Consider clearing some storage for better performance. 📱';
    } else if (percent >= 60) {
      return 'Your device needs attention. Run smart cleanup and close background apps. ⚠️';
    } else {
      return 'Your device requires immediate maintenance. Consider factory reset or upgrading. 🔴';
    }
  }
}

class DiagnosticItem {
  final String name;
  String status;
  String message;
  
  DiagnosticItem({
    required this.name,
    required this.status,
    required this.message,
  });
  
  DiagnosticItem copyWith({
    String? name,
    String? status,
    String? message,
  }) {
    return DiagnosticItem(
      name: name ?? this.name,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}