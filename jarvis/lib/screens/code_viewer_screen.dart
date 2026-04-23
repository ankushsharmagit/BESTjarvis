// lib/screens/code_viewer_screen.dart
// Self-Upgrade Code Viewer

import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../services/core/self_upgrade_service.dart';
import '../widgets/glassmorphic_card.dart';

class CodeViewerScreen extends StatefulWidget {
  const CodeViewerScreen({Key? key}) : super(key: key);

  @override
  State<CodeViewerScreen> createState() => _CodeViewerScreenState();
}

class _CodeViewerScreenState extends State<CodeViewerScreen> {
  final SelfUpgradeService _upgradeService = SelfUpgradeService();
  String _selectedFile = 'lib/main.dart';
  String _codeContent = '';
  String _projectStructure = '';
  bool _isLoading = true;
  final List<String> _fileList = [
    'lib/main.dart',
    'lib/config/constants.dart',
    'lib/config/colors.dart',
    'lib/services/core/command_processor.dart',
    'lib/services/voice/wake_word_service.dart',
    'lib/screens/home_screen.dart',
    'lib/widgets/arc_reactor_widget.dart',
  ];
  
  @override
  void initState() {
    super.initState();
    _loadCode();
    _loadStructure();
  }
  
  Future<void> _loadCode() async {
    setState(() {
      _isLoading = true;
    });
    _codeContent = await _upgradeService.getFileContent(_selectedFile);
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _loadStructure() async {
    _projectStructure = await _upgradeService.getProjectStructure();
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JarvisColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Code Viewer'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: JarvisColors.accentCyan),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: JarvisColors.accentCyan),
            onPressed: _showInfo,
          ),
        ],
      ),
      body: Row(
        children: [
          // File Explorer
          Container(
            width: 200,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: JarvisColors.dividerColor)),
            ),
            child: ListView.builder(
              itemCount: _fileList.length,
              itemBuilder: (context, index) {
                final file = _fileList[index];
                return ListTile(
                  leading: const Icon(Icons.code, size: 18),
                  title: Text(
                    file.split('/').last,
                    style: TextStyle(
                      fontSize: 12,
                      color: _selectedFile == file ? JarvisColors.accentCyan : Colors.white,
                    ),
                  ),
                  selected: _selectedFile == file,
                  selectedTileColor: JarvisColors.accentCyan.withOpacity(0.1),
                  onTap: () {
                    setState(() {
                      _selectedFile = file;
                    });
                    _loadCode();
                  },
                );
              },
            ),
          ),
          
          // Code Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // File Header
                        GlassmorphicCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.insert_drive_file, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _selectedFile,
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 18),
                                onPressed: () {
                                  // Copy to clipboard
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Code Content
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SelectableText(
                            _codeContent,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          
          // Project Structure Panel
          Container(
            width: 250,
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: JarvisColors.dividerColor)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: JarvisColors.dividerColor)),
                  ),
                  child: const Text(
                    'Project Structure',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(
                      _projectStructure,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Code Viewer Info'),
        content: const Text(
          'This section allows you to view JARVIS source code.\n\n'
          'You can browse through different files and see the implementation.\n\n'
          'The code is organized by modules:\n'
          '• Config - App configuration\n'
          '• Services - Core functionality\n'
          '• Screens - UI screens\n'
          '• Widgets - Reusable components\n'
          '• Utils - Helper functions\n\n'
          'Want to add new features? Say "JARVIS, how to add new feature"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}