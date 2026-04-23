// lib/screens/security_log_screen.dart
// Intruder Logs and Security Events

import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../models/intruder_log.dart';
import '../widgets/glassmorphic_card.dart';

class SecurityLogScreen extends StatefulWidget {
  const SecurityLogScreen({Key? key}) : super(key: key);

  @override
  State<SecurityLogScreen> createState() => _SecurityLogScreenState();
}

class _SecurityLogScreenState extends State<SecurityLogScreen> {
  List<IntruderLog> _logs = [];
  String _filter = 'all';
  
  @override
  void initState() {
    super.initState();
    _loadLogs();
  }
  
  void _loadLogs() {
    // Load from database
    _logs = [
      IntruderLog(
        id: '1',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        actionType: 'UNKNOWN_FACE',
        photoPath: null,
        attemptedAccess: 'Phone unlock attempt',
        attemptDuration: 5,
        wasSuccessful: false,
      ),
      IntruderLog(
        id: '2',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        actionType: 'WRONG_PIN',
        attemptedAccess: 'Wrong PIN entered 3 times',
        attemptDuration: 10,
        wasSuccessful: false,
      ),
    ];
  }
  
  List<IntruderLog> get _filteredLogs {
    if (_filter == 'all') return _logs;
    return _logs.where((log) => log.actionType == _filter).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JarvisColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Security Log'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: JarvisColors.accentCyan),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: JarvisColors.accentCyan),
            onPressed: _clearLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All', 'all'),
                _buildFilterChip('Face', 'UNKNOWN_FACE'),
                _buildFilterChip('PIN', 'WRONG_PIN'),
                _buildFilterChip('Voice', 'UNKNOWN_VOICE'),
                _buildFilterChip('Biometric', 'FAILED_BIOMETRIC'),
              ],
            ),
          ),
          
          // Stats Summary
          GlassmorphicCard(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.warning, 'Total Attempts', _logs.length.toString()),
                _buildStatItem(Icons.person_off, 'Unique Intruders', '2'),
                _buildStatItem(Icons.timer, 'Last Attempt', _logs.isNotEmpty ? _logs.last.getFormattedTimestamp() : 'Never'),
              ],
            ),
          ),
          
          // Log List
          Expanded(
            child: _filteredLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.security, size: 64, color: JarvisColors.textHint),
                        const SizedBox(height: 16),
                        Text(
                          'No security events found',
                          style: TextStyle(color: JarvisColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = _filteredLogs[index];
                      return _buildLogCard(log);
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: _filter == value,
        onSelected: (selected) {
          setState(() {
            _filter = selected ? value : 'all';
          });
        },
        backgroundColor: JarvisColors.bgCard,
        selectedColor: JarvisColors.accentCyan.withOpacity(0.3),
        checkmarkColor: JarvisColors.accentCyan,
      ),
    );
  }
  
  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 24, color: JarvisColors.accentCyan),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: JarvisColors.textSecondary),
        ),
      ],
    );
  }
  
  Widget _buildLogCard(IntruderLog log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: JarvisColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: log.getSeverityColor(),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: log.getSeverityColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                log.getActionIcon(),
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.getActionDescription(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  log.getFormattedTimestamp(),
                  style: TextStyle(fontSize: 12, color: JarvisColors.textSecondary),
                ),
                if (log.attemptedAccess != null)
                  Text(
                    'Attempted: ${log.attemptedAccess}',
                    style: TextStyle(fontSize: 11, color: JarvisColors.textHint),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: log.getSeverityColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              log.getSeverityLevel(),
              style: TextStyle(fontSize: 10, color: log.getSeverityColor()),
            ),
          ),
        ],
      ),
    );
  }
  
  void _clearLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Security Logs'),
        content: const Text('Are you sure you want to delete all security logs?'),
        backgroundColor: JarvisColors.bgCard,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _logs.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}