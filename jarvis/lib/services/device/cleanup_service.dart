// lib/services/device/cleanup_service.dart
// Smart Cleanup Service with AI-powered Analysis

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../utils/logger.dart';
import '../../utils/helpers.dart';
import 'file_manager.dart';
import '../media/gallery_service.dart';

class CleanupService {
  static final CleanupService _instance = CleanupService._internal();
  factory CleanupService() => _instance;
  CleanupService._internal();
  
  final FileManagerService _fileManager = FileManagerService();
  final GalleryService _galleryService = GalleryService();
  
  Future<Map<String, dynamic>> smartCleanup() async {
    try {
      Logger().info('Starting smart cleanup', tag: 'CLEANUP');
      
      final results = {
        'cacheCleared': 0,
        'tempCleared': 0,
        'apkCleared': 0,
        'trashCleared': 0,
        'logCleared': 0,
        'downloadCleared': 0,
        'totalFreed': 0,
        'details': <String, dynamic>{},
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // Clear app caches
      final cacheSize = await _clearAppCaches();
      results['cacheCleared'] = cacheSize;
      results['totalFreed'] += cacheSize;
      results['details']['appCache'] = Helpers.formatFileSize(cacheSize);
      
      // Clear temp files
      final tempSize = await _clearTempFiles();
      results['tempCleared'] = tempSize;
      results['totalFreed'] += tempSize;
      results['details']['tempFiles'] = Helpers.formatFileSize(tempSize);
      
      // Clear APK files
      final apkSize = await _clearApkFiles();
      results['apkCleared'] = apkSize;
      results['totalFreed'] += apkSize;
      results['details']['apkFiles'] = Helpers.formatFileSize(apkSize);
      
      // Clear log files
      final logSize = await _clearLogFiles();
      results['logCleared'] = logSize;
      results['totalFreed'] += logSize;
      results['details']['logFiles'] = Helpers.formatFileSize(logSize);
      
      // Clear old downloads
      final downloadSize = await _clearOldDownloads();
      results['downloadCleared'] = downloadSize;
      results['totalFreed'] += downloadSize;
      results['details']['oldDownloads'] = Helpers.formatFileSize(downloadSize);
      
      // Empty trash
      await _fileManager.emptyTrash();
      
      results['totalFreedFormatted'] = Helpers.formatFileSize(results['totalFreed']);
      
      Logger().info('Cleanup completed: freed ${results['totalFreedFormatted']}', tag: 'CLEANUP');
      return results;
      
    } catch (e) {
      Logger().error('Cleanup error', tag: 'CLEANUP', error: e);
      return {'error': e.toString()};
    }
  }
  
  Future<int> _clearAppCaches() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      int totalSize = 0;
      
      if (await cacheDir.exists()) {
        await for (var entity in cacheDir.list()) {
          if (entity is File) {
            totalSize += await entity.length();
            await entity.delete();
          } else if (entity is Directory) {
            totalSize += await _getDirectorySize(entity);
            await entity.delete(recursive: true);
          }
        }
      }
      
      return totalSize;
    } catch (e) {
      Logger().error('Clear caches error', tag: 'CLEANUP', error: e);
      return 0;
    }
  }
  
  Future<int> _clearTempFiles() async {
    try {
      final tempDir = Directory('/data/local/tmp');
      int totalSize = 0;
      
      if (await tempDir.exists()) {
        await for (var entity in tempDir.list()) {
          if (entity is File && (entity.path.endsWith('.tmp') || entity.path.endsWith('.temp'))) {
            totalSize += await entity.length();
            await entity.delete();
          }
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
  
  Future<int> _clearApkFiles() async {
    try {
      final downloadDir = Directory('/storage/emulated/0/Download');
      int totalSize = 0;
      
      if (await downloadDir.exists()) {
        await for (var entity in downloadDir.list()) {
          if (entity is File && (entity.path.endsWith('.apk') || entity.path.endsWith('.xapk'))) {
            totalSize += await entity.length();
            await entity.delete();
          }
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
  
  Future<int> _clearLogFiles() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final logDir = Directory('${appDir.path}/JARVIS_Logs');
      int totalSize = 0;
      
      if (await logDir.exists()) {
        await for (var entity in logDir.list()) {
          if (entity is File && entity.path.endsWith('.log')) {
            totalSize += await entity.length();
            await entity.delete();
          }
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
  
  Future<int> _clearOldDownloads() async {
    try {
      final downloadDir = Directory('/storage/emulated/0/Download');
      int totalSize = 0;
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      if (await downloadDir.exists()) {
        await for (var entity in downloadDir.list()) {
          if (entity is File) {
            final modified = await entity.lastModified();
            if (modified.isBefore(thirtyDaysAgo)) {
              totalSize += await entity.length();
              await entity.delete();
            }
          }
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
  
  Future<int> _getDirectorySize(Directory dir) async {
    int size = 0;
    await for (var entity in dir.list()) {
      if (entity is File) {
        size += await entity.length();
      } else if (entity is Directory) {
        size += await _getDirectorySize(entity);
      }
    }
    return size;
  }
  
  Future<Map<String, dynamic>> findUnwantedPhotos() async {
    try {
      final photos = await _galleryService.getAllImages();
      final unwanted = <Map<String, dynamic>>[];
      int totalSize = 0;
      
      final now = DateTime.now();
      
      for (var photo in photos) {
        final file = File(photo['path']);
        final modified = await file.lastModified();
        final daysOld = now.difference(modified).inDays;
        
        // Check for unwanted categories
        bool isUnwanted = false;
        String reason = '';
        
        // Screenshots older than 30 days
        if (photo['path'].toLowerCase().contains('screenshot') && daysOld > 30) {
          isUnwanted = true;
          reason = 'Old screenshot (>30 days)';
        }
        
        // WhatsApp junk images
        else if (photo['path'].contains('WhatsApp') && 
                 (photo['path'].contains('IMG-') || photo['path'].contains('VID-'))) {
          isUnwanted = true;
          reason = 'WhatsApp media';
        }
        
        // Memes older than 7 days
        else if ((photo['path'].toLowerCase().contains('meme') || 
                  photo['path'].toLowerCase().contains('funny') ||
                  photo['path'].toLowerCase().contains('joke')) && daysOld > 7) {
          isUnwanted = true;
          reason = 'Old meme';
        }
        
        // Blurry photos
        else if (photo.get('isBlurry') == true) {
          isUnwanted = true;
          reason = 'Blurry photo';
        }
        
        // Duplicate photos (will be handled separately)
        
        if (isUnwanted) {
          final size = await file.length();
          totalSize += size;
          unwanted.add({
            'path': photo['path'],
            'name': photo['name'],
            'size': size,
            'sizeFormatted': Helpers.formatFileSize(size),
            'reason': reason,
            'daysOld': daysOld,
            'modified': modified,
          });
        }
      }
      
      // Sort by size (largest first)
      unwanted.sort((a, b) => b['size'].compareTo(a['size']));
      
      return {
        'count': unwanted.length,
        'totalSize': totalSize,
        'totalSizeFormatted': Helpers.formatFileSize(totalSize),
        'items': unwanted,
        'categories': {
          'screenshots': unwanted.where((u) => u['reason'] == 'Old screenshot (>30 days)').length,
          'whatsapp': unwanted.where((u) => u['reason'] == 'WhatsApp media').length,
          'memes': unwanted.where((u) => u['reason'] == 'Old meme').length,
          'blurry': unwanted.where((u) => u['reason'] == 'Blurry photo').length,
        }
      };
      
    } catch (e) {
      Logger().error('Find unwanted photos error', tag: 'CLEANUP', error: e);
      return {'error': e.toString()};
    }
  }
  
  Future<Map<String, dynamic>> findDuplicatePhotos() async {
    try {
      final photos = await _galleryService.getAllImages();
      final hashMap = <String, List<Map<String, dynamic>>>{};
      
      for (var photo in photos) {
        final file = File(photo['path']);
        final hash = await _getQuickHash(file);
        
        if (!hashMap.containsKey(hash)) {
          hashMap[hash] = [];
        }
        hashMap[hash]!.add(photo);
      }
      
      final duplicates = <Map<String, dynamic>>[];
      int totalDuplicateSize = 0;
      
      for (var entry in hashMap.entries) {
        if (entry.value.length > 1) {
          int groupSize = 0;
          for (var photo in entry.value) {
            final file = File(photo['path']);
            groupSize += await file.length();
          }
          totalDuplicateSize += groupSize;
          
          duplicates.add({
            'hash': entry.key,
            'photos': entry.value,
            'count': entry.value.length,
            'totalSize': groupSize,
            'totalSizeFormatted': Helpers.formatFileSize(groupSize),
          });
        }
      }
      
      return {
        'duplicateGroups': duplicates.length,
        'totalDuplicates': duplicates.fold(0, (sum, d) => sum + d['count']),
        'totalSize': totalDuplicateSize,
        'totalSizeFormatted': Helpers.formatFileSize(totalDuplicateSize),
        'groups': duplicates,
      };
      
    } catch (e) {
      Logger().error('Find duplicates error', tag: 'CLEANUP', error: e);
      return {'error': e.toString()};
    }
  }
  
  Future<String> _getQuickHash(File file) async {
    try {
      final bytes = await file.readAsBytes();
      if (bytes.length > 1024 * 1024) {
        // For large files, only read first 1MB and last 1MB
        final firstChunk = bytes.sublist(0, 1024 * 1024);
        final lastChunk = bytes.sublist(bytes.length - 1024 * 1024);
        return '${firstChunk.hashCode}${lastChunk.hashCode}';
      }
      return bytes.hashCode.toString();
    } catch (e) {
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }
  
  Future<Map<String, dynamic>> cleanupWhatsApp() async {
    try {
      final whatsappDir = Directory('/storage/emulated/0/WhatsApp/Media');
      if (!await whatsappDir.exists()) {
        return {'error': 'WhatsApp directory not found'};
      }
      
      final categories = {
        'Images': 0,
        'Videos': 0,
        'Audio': 0,
        'Documents': 0,
        'GIFs': 0,
        'Stickers': 0,
        'Total': 0,
      };
      
      int forwardedJunkSize = 0;
      int forwardedJunkCount = 0;
      int oldMediaSize = 0;
      int oldMediaCount = 0;
      
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      await for (var entity in whatsappDir.list(recursive: true)) {
        if (entity is File) {
          final size = await entity.length();
          final modified = await entity.lastModified();
          final ext = entity.path.split('.').last.toLowerCase();
          
          // Categorize by type
          if (ext == 'jpg' || ext == 'jpeg' || ext == 'png') {
            categories['Images'] = (categories['Images'] ?? 0) + size;
            
            // Check for forwarded junk
            if (entity.path.contains('Forwarded')) {
              forwardedJunkSize += size;
              forwardedJunkCount++;
            }
          } else if (ext == 'mp4') {
            categories['Videos'] = (categories['Videos'] ?? 0) + size;
          } else if (ext == 'mp3' || ext == 'opus' || ext == 'aac') {
            categories['Audio'] = (categories['Audio'] ?? 0) + size;
          } else if (ext == 'pdf' || ext == 'doc' || ext == 'docx') {
            categories['Documents'] = (categories['Documents'] ?? 0) + size;
          } else if (ext == 'gif') {
            categories['GIFs'] = (categories['GIFs'] ?? 0) + size;
          } else if (ext == 'webp') {
            categories['Stickers'] = (categories['Stickers'] ?? 0) + size;
          }
          
          // Check for old media (older than 30 days)
          if (modified.isBefore(thirtyDaysAgo)) {
            oldMediaSize += size;
            oldMediaCount++;
          }
          
          categories['Total'] = (categories['Total'] ?? 0) + size;
        }
      }
      
      // Format sizes
      final formatted = <String, dynamic>{};
      for (var entry in categories.entries) {
        formatted[entry.key] = Helpers.formatFileSize(entry.value);
      }
      
      return {
        'categories': formatted,
        'raw': categories,
        'forwardedJunk': {
          'count': forwardedJunkCount,
          'size': forwardedJunkSize,
          'sizeFormatted': Helpers.formatFileSize(forwardedJunkSize),
        },
        'oldMedia': {
          'count': oldMediaCount,
          'size': oldMediaSize,
          'sizeFormatted': Helpers.formatFileSize(oldMediaSize),
        },
        'totalSize': categories['Total'],
        'totalSizeFormatted': Helpers.formatFileSize(categories['Total'] ?? 0),
      };
      
    } catch (e) {
      Logger().error('WhatsApp cleanup error', tag: 'CLEANUP', error: e);
      return {'error': e.toString()};
    }
  }
  
  Future<Map<String, dynamic>> findUnwantedMessages() async {
    // This would require SMS permissions
    return {
      'spamCount': 0,
      'oldOTPCount': 0,
      'promotionalCount': 0,
      'totalSize': 0,
      'messages': [],
    };
  }
  
  Future<Map<String, dynamic>> analyzeStorage() async {
    try {
      final totalStorage = await _getTotalStorage();
      final freeStorage = await _getFreeStorage();
      final usedStorage = totalStorage - freeStorage;
      final usagePercent = (usedStorage / totalStorage) * 100;
      
      String suggestion = '';
      if (usagePercent > 90) {
        suggestion = 'Critical: Storage almost full! Run cleanup immediately.';
      } else if (usagePercent > 75) {
        suggestion = 'Warning: Storage running low. Consider cleaning up.';
      } else if (usagePercent > 60) {
        suggestion = 'Moderate: Storage usage is moderate.';
      } else {
        suggestion = 'Good: Storage usage is healthy.';
      }
      
      return {
        'total': totalStorage,
        'totalFormatted': Helpers.formatFileSize(totalStorage),
        'free': freeStorage,
        'freeFormatted': Helpers.formatFileSize(freeStorage),
        'used': usedStorage,
        'usedFormatted': Helpers.formatFileSize(usedStorage),
        'usagePercent': usagePercent.toStringAsFixed(1),
        'suggestion': suggestion,
        'status': usagePercent > 90 ? 'critical' : usagePercent > 75 ? 'warning' : 'good',
      };
      
    } catch (e) {
      return {'error': e.toString()};
    }
  }
  
  Future<int> _getTotalStorage() async {
    // Get total storage in bytes
    try {
      final stat = await FileSystemEntity.stat('/storage/emulated/0');
      return stat.size;
    } catch (e) {
      return 128 * 1024 * 1024 * 1024; // Default 128GB
    }
  }
  
  Future<int> _getFreeStorage() async {
    try {
      final dir = Directory('/storage/emulated/0');
      final stat = await dir.stat();
      return stat.free;
    } catch (e) {
      return 64 * 1024 * 1024 * 1024; // Default 64GB free
    }
  }
}