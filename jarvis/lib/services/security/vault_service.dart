// lib/services/security/vault_service.dart
// Encrypted Private Vault Service with Fake Calculator Entry

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';
import '../../config/constants.dart';

class VaultService {
  static final VaultService _instance = VaultService._internal();
  factory VaultService() => _instance;
  VaultService._internal();
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late Directory _vaultDirectory;
  late Directory _fakeVaultDirectory;
  late encrypt.Key _encryptionKey;
  late encrypt.IV _iv;
  
  bool _isUnlocked = false;
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;
  int _totalFiles = 0;
  int _totalSize = 0;
  
  Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _vaultDirectory = Directory('${appDir.path}/${AppConstants.vaultDirectory}');
      _fakeVaultDirectory = Directory('${appDir.path}/${AppConstants.vaultDirectory}_fake');
      
      if (!await _vaultDirectory.exists()) {
        await _vaultDirectory.create(recursive: true);
      }
      if (!await _fakeVaultDirectory.exists()) {
        await _fakeVaultDirectory.create(recursive: true);
      }
      
      await _loadOrCreateKey();
      await _updateStats();
      
      Logger().info('Vault service initialized', tag: 'VAULT');
      
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'Vault Init');
    }
  }
  
  Future<void> _loadOrCreateKey() async {
    try {
      final storedKey = await _secureStorage.read(key: 'vault_key');
      final storedIV = await _secureStorage.read(key: 'vault_iv');
      
      if (storedKey != null && storedIV != null) {
        _encryptionKey = encrypt.Key.fromBase64(storedKey);
        _iv = encrypt.IV.fromBase64(storedIV);
      } else {
        // Generate new key and IV
        _encryptionKey = encrypt.Key.fromSecureRandom(32);
        _iv = encrypt.IV.fromSecureRandom(16);
        
        await _secureStorage.write(key: 'vault_key', value: _encryptionKey.base64);
        await _secureStorage.write(key: 'vault_iv', value: _iv.base64);
      }
    } catch (e) {
      Logger().error('Error loading key', tag: 'VAULT', error: e);
      rethrow;
    }
  }
  
  Future<bool> unlockVault(String pin, {bool requireBiometric = true}) async {
    // Check lockout
    if (_lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!)) {
      final remaining = _lockoutUntil!.difference(DateTime.now());
      Logger().warning('Vault locked for ${remaining.inMinutes} minutes', tag: 'VAULT');
      return false;
    }
    
    // Verify PIN
    final storedPin = await _secureStorage.read(key: 'vault_pin');
    if (storedPin == pin) {
      _isUnlocked = true;
      _failedAttempts = 0;
      await _updateStats();
      Logger().info('Vault unlocked successfully', tag: 'VAULT');
      return true;
    }
    
    // Failed attempt
    _failedAttempts++;
    if (_failedAttempts >= AppConstants.vaultMaxAttempts) {
      _lockoutUntil = DateTime.now().add(
        Duration(minutes: AppConstants.vaultLockoutDuration)
      );
      Logger().warning('Vault locked due to too many failed attempts', tag: 'VAULT');
    }
    
    return false;
  }
  
  void lockVault() {
    _isUnlocked = false;
    Logger().info('Vault locked', tag: 'VAULT');
  }
  
  bool isUnlocked() {
    return _isUnlocked;
  }
  
  Future<bool> setVaultPin(String pin) async {
    try {
      await _secureStorage.write(key: 'vault_pin', value: pin);
      Logger().info('Vault PIN set successfully', tag: 'VAULT');
      return true;
    } catch (e) {
      Logger().error('Error setting PIN', tag: 'VAULT', error: e);
      return false;
    }
  }
  
  Future<bool> changeVaultPin(String oldPin, String newPin) async {
    final storedPin = await _secureStorage.read(key: 'vault_pin');
    if (storedPin == oldPin) {
      return await setVaultPin(newPin);
    }
    return false;
  }
  
  Future<String> encryptFile(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final encrypted = _encryptBytes(bytes);
      
      final fileName = file.path.split('/').last;
      final encryptedFileName = '${fileName}_${DateTime.now().millisecondsSinceEpoch}.enc';
      final encryptedFile = File('${_vaultDirectory.path}/$encryptedFileName');
      
      await encryptedFile.writeAsBytes(encrypted);
      
      // Delete original if it's in a different location
      if (file.path != encryptedFile.path) {
        await file.delete();
      }
      
      await _updateStats();
      Logger().info('File encrypted: ${file.path}', tag: 'VAULT');
      return encryptedFile.path;
      
    } catch (e) {
      Logger().error('Error encrypting file', tag: 'VAULT', error: e);
      return '';
    }
  }
  
  Future<File?> decryptFile(String encryptedPath, {String? outputPath}) async {
    try {
      if (!_isUnlocked) {
        Logger().warning('Vault locked, cannot decrypt', tag: 'VAULT');
        return null;
      }
      
      final encryptedFile = File(encryptedPath);
      final encryptedBytes = await encryptedFile.readAsBytes();
      final decryptedBytes = _decryptBytes(encryptedBytes);
      
      final originalName = encryptedPath.split('/').last.replaceAll('.enc', '');
      final output = outputPath ?? 
          '${_vaultDirectory.parent.path}/$originalName';
      
      final decryptedFile = File(output);
      await decryptedFile.writeAsBytes(decryptedBytes);
      
      Logger().info('File decrypted: $encryptedPath', tag: 'VAULT');
      return decryptedFile;
      
    } catch (e) {
      Logger().error('Error decrypting file', tag: 'VAULT', error: e);
      return null;
    }
  }
  
  Uint8List _encryptBytes(Uint8List bytes) {
    final encrypter = encrypt.Encrypter(
      encrypt.AES(_encryptionKey, mode: encrypt.AESMode.cbc)
    );
    final encrypted = encrypter.encryptBytes(bytes, iv: _iv);
    return encrypted.bytes;
  }
  
  Uint8List _decryptBytes(Uint8List encryptedBytes) {
    final encrypter = encrypt.Encrypter(
      encrypt.AES(_encryptionKey, mode: encrypt.AESMode.cbc)
    );
    final encrypted = encrypt.Encrypted(encryptedBytes);
    return encrypter.decryptBytes(encrypted, iv: _iv);
  }
  
  Future<List<FileSystemEntity>> listVaultContents() async {
    if (!_isUnlocked) return [];
    
    try {
      return await _vaultDirectory.list().toList();
    } catch (e) {
      Logger().error('Error listing vault', tag: 'VAULT', error: e);
      return [];
    }
  }
  
  Future<bool> deleteFromVault(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        await _updateStats();
        Logger().info('Deleted from vault: $path', tag: 'VAULT');
        return true;
      }
      return false;
    } catch (e) {
      Logger().error('Error deleting from vault', tag: 'VAULT', error: e);
      return false;
    }
  }
  
  Future<void> _updateStats() async {
    _totalFiles = 0;
    _totalSize = 0;
    
    if (await _vaultDirectory.exists()) {
      await for (var entity in _vaultDirectory.list()) {
        if (entity is File) {
          _totalFiles++;
          _totalSize += await entity.length();
        }
      }
    }
  }
  
  Future<Map<String, dynamic>> getVaultStats() async {
    await _updateStats();
    
    return {
      'fileCount': _totalFiles,
      'totalSize': _totalSize,
      'totalSizeFormatted': _formatSize(_totalSize),
      'isUnlocked': _isUnlocked,
      'directory': _vaultDirectory.path,
      'failedAttempts': _failedAttempts,
      'isLockedOut': _lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!),
      'lockoutRemaining': _lockoutUntil != null 
          ? _lockoutUntil!.difference(DateTime.now()).inMinutes 
          : 0,
    };
  }
  
  String _formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }
  
  Future<void> createFakeVault() async {
    // Create fake empty vault for intruders
    if (!await _fakeVaultDirectory.exists()) {
      await _fakeVaultDirectory.create();
    }
    
    // Create some fake files to make it look legit
    final fakeFile = File('${_fakeVaultDirectory.path}/empty.txt');
    await fakeFile.writeAsString('This vault appears to be empty. No sensitive data found.');
    
    // Add a few more fake files
    final fakeFile2 = File('${_fakeVaultDirectory.path}/notes.txt');
    await fakeFile2.writeAsString('Shopping list:\n- Milk\n- Bread\n- Eggs');
    
    Logger().info('Fake vault created for intruder deception', tag: 'VAULT');
  }
  
  Future<void> showFakeVault() async {
    // This would navigate to a fake vault UI
    Logger().info('Showing fake vault to intruder', tag: 'VAULT');
  }
  
  Future<void> clearVault() async {
    try {
      if (await _vaultDirectory.exists()) {
        await _vaultDirectory.delete(recursive: true);
        await _vaultDirectory.create();
      }
      _totalFiles = 0;
      _totalSize = 0;
      Logger().info('Vault cleared completely', tag: 'VAULT');
    } catch (e) {
      Logger().error('Error clearing vault', tag: 'VAULT', error: e);
    }
  }
  
  Future<void> backupVault(String backupPath) async {
    try {
      final backupDir = Directory(backupPath);
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      
      // Copy all vault files to backup location
      await for (var entity in _vaultDirectory.list()) {
        if (entity is File) {
          final destFile = File('${backupDir.path}/${entity.path.split('/').last}');
          await entity.copy(destFile.path);
        }
      }
      
      Logger().info('Vault backed up to: $backupPath', tag: 'VAULT');
    } catch (e) {
      Logger().error('Error backing up vault', tag: 'VAULT', error: e);
    }
  }
  
  Future<bool> restoreVault(String backupPath) async {
    try {
      final backupDir = Directory(backupPath);
      if (!await backupDir.exists()) return false;
      
      // Clear current vault
      await clearVault();
      
      // Restore from backup
      await for (var entity in backupDir.list()) {
        if (entity is File) {
          final destFile = File('${_vaultDirectory.path}/${entity.path.split('/').last}');
          await entity.copy(destFile.path);
        }
      }
      
      await _updateStats();
      Logger().info('Vault restored from: $backupPath', tag: 'VAULT');
      return true;
      
    } catch (e) {
      Logger().error('Error restoring vault', tag: 'VAULT', error: e);
      return false;
    }
  }
}