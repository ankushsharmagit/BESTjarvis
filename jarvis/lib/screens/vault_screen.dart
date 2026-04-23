// lib/screens/vault_screen.dart
// Encrypted Private Vault Screen

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../config/colors.dart';
import '../services/security/vault_service.dart';
import '../widgets/glassmorphic_card.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({Key? key}) : super(key: key);

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final VaultService _vaultService = VaultService();
  List<FileSystemEntity> _files = [];
  bool _isUnlocked = false;
  String _pin = '';
  bool _isLoading = false;
  
  final TextEditingController _pinController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _checkLockStatus();
  }
  
  Future<void> _checkLockStatus() async {
    setState(() {
      _isUnlocked = _vaultService.isUnlocked();
    });
    if (_isUnlocked) {
      await _loadFiles();
    }
  }
  
  Future<void> _unlockVault() async {
    if (_pinController.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });
    
    final success = await _vaultService.unlockVault(_pinController.text);
    
    setState(() {
      _isLoading = false;
      if (success) {
        _isUnlocked = true;
        _loadFiles();
        _pinController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid PIN!')),
        );
      }
    });
  }
  
  Future<void> _loadFiles() async {
    final files = await _vaultService.listVaultContents();
    setState(() {
      _files = files;
    });
  }
  
  Future<void> _addFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _isLoading = true;
      });
      
      final file = File(result.files.single.path!);
      await _vaultService.encryptFile(file);
      await _loadFiles();
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File added to vault!')),
      );
    }
  }
  
  Future<void> _decryptAndOpen(FileSystemEntity entity) async {
    if (entity is! File) return;
    
    setState(() {
      _isLoading = true;
    });
    
    final decryptedFile = await _vaultService.decryptFile(entity.path);
    
    setState(() {
      _isLoading = false;
    });
    
    if (decryptedFile != null) {
      // Open file with appropriate app
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File decrypted: ${decryptedFile.path.split('/').last}')),
      );
    }
  }
  
  Future<void> _deleteFile(FileSystemEntity entity) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: const Text('Are you sure you want to delete this file?'),
        backgroundColor: JarvisColors.bgCard,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _vaultService.deleteFromVault(entity.path);
              await _loadFiles();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('File deleted from vault')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  void _lockVault() {
    _vaultService.lockVault();
    setState(() {
      _isUnlocked = false;
      _files.clear();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JarvisColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Private Vault'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: JarvisColors.accentCyan),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isUnlocked)
            IconButton(
              icon: const Icon(Icons.lock_outline, color: JarvisColors.accentCyan),
              onPressed: _lockVault,
            ),
        ],
      ),
      body: _isUnlocked ? _buildUnlockedContent() : _buildLockedContent(),
    );
  }
  
  Widget _buildLockedContent() {
    return Center(
      child: GlassmorphicCard(
        width: 300,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock, size: 64, color: JarvisColors.accentCyan),
            const SizedBox(height: 20),
            const Text(
              'Vault Locked',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Enter PIN to access private files',
              style: TextStyle(color: JarvisColors.textSecondary),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter 6-digit PIN',
                hintStyle: const TextStyle(color: JarvisColors.textHint),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: JarvisColors.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: JarvisColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: JarvisColors.accentCyan),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _unlockVault,
              style: ElevatedButton.styleFrom(
                backgroundColor: JarvisColors.accentCyan,
                minimumSize: const Size(double.infinity, 45),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('Unlock Vault', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUnlockedContent() {
    return Column(
      children: [
        // Stats Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: GlassmorphicCard(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Text(
                        _files.length.toString(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const Text('Files', style: TextStyle(color: JarvisColors.textSecondary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassmorphicCard(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      const Text('🔒', style: TextStyle(fontSize: 24)),
                      const Text('Encrypted', style: TextStyle(color: JarvisColors.textSecondary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassmorphicCard(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      const Text('AES-256', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Text('Security', style: TextStyle(color: JarvisColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // File List
        Expanded(
          child: _files.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 64, color: JarvisColors.textHint),
                      const SizedBox(height: 16),
                      Text(
                        'No files in vault',
                        style: TextStyle(color: JarvisColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _addFile,
                        child: const Text('Add Files'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    final file = _files[index];
                    final fileName = file.path.split('/').last;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: JarvisColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: JarvisColors.borderColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock, color: JarvisColors.accentCyan),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fileName.replaceAll('.enc', ''),
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  'Encrypted • ${file.path.split('/').last.split('.').last}',
                                  style: TextStyle(fontSize: 11, color: JarvisColors.textHint),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.visibility, color: JarvisColors.accentCyan),
                            onPressed: () => _decryptAndOpen(file),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteFile(file),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        
        // Add Button
        if (_files.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _addFile,
              icon: const Icon(Icons.add),
              label: const Text('Add File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: JarvisColors.accentCyan,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
          ),
      ],
    );
  }
}