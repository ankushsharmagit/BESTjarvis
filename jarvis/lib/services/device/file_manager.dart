// lib/services/device/file_manager.dart
// Complete File Management Service

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:archive/archive.dart';
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';
import '../../utils/helpers.dart';

class FileManagerService {
  static final FileManagerService _instance = FileManagerService._internal();
  factory FileManagerService() => _instance;
  FileManagerService._internal();
  
  Directory? _externalStorage;
  Directory? _internalStorage;
  Directory? _downloadsDir;
  Directory? _documentsDir;
  Directory? _picturesDir;
  Directory? _musicDir;
  Directory? _videosDir;
  
  Future<void> initialize() async {
    try {
      if (await Permission.storage.request().isGranted) {
        _externalStorage = await getExternalStorageDirectory();
        _internalStorage = await getApplicationDocumentsDirectory();
        _downloadsDir = Directory('/storage/emulated/0/Download');
        _documentsDir = Directory('/storage/emulated/0/Documents');
        _picturesDir = Directory('/storage/emulated/0/Pictures');
        _musicDir = Directory('/storage/emulated/0/Music');
        _videosDir = Directory('/storage/emulated/0/Movies');
      }
      Logger().info('File manager initialized', tag: 'FILE');
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'File Manager Init');
    }
  }
  
  Future<List<FileSystemEntity>> listDirectory(String path) async {
    try {
      final directory = Directory(path);
      if (await directory.exists()) {
        return await directory.list().toList();
      }
      return [];
    } catch (e) {
      Logger().error('List directory error', tag: 'FILE', error: e);
      return [];
    }
  }
  
  Future<List<FileSystemEntity>> listRootDirectories() async {
    final dirs = <FileSystemEntity>[];
    if (_externalStorage != null) dirs.add(_externalStorage!);
    if (_downloadsDir != null && await _downloadsDir!.exists()) dirs.add(_downloadsDir!);
    if (_documentsDir != null && await _documentsDir!.exists()) dirs.add(_documentsDir!);
    if (_picturesDir != null && await _picturesDir!.exists()) dirs.add(_picturesDir!);
    if (_musicDir != null && await _musicDir!.exists()) dirs.add(_musicDir!);
    if (_videosDir != null && await _videosDir!.exists()) dirs.add(_videosDir!);
    return dirs;
  }
  
  Future<List<FileSystemEntity>> searchFiles(String query, {String? directory}) async {
    try {
      final searchDir = directory != null 
          ? Directory(directory) 
          : _externalStorage;
      
      if (searchDir == null || !await searchDir.exists()) {
        return [];
      }
      
      final results = <FileSystemEntity>[];
      await _searchRecursively(searchDir, query.toLowerCase(), results);
      return results;
      
    } catch (e) {
      Logger().error('Search files error', tag: 'FILE', error: e);
      return [];
    }
  }
  
  Future<void> _searchRecursively(Directory dir, String query, List<FileSystemEntity> results) async {
    try {
      final entities = await dir.list().toList();
      
      for (var entity in entities) {
        if (results.length >= 100) break;
        
        if (entity is File) {
          if (entity.path.toLowerCase().contains(query)) {
            results.add(entity);
          }
        } else if (entity is Directory) {
          await _searchRecursively(entity, query, results);
        }
      }
    } catch (e) {
      // Skip permission denied directories
    }
  }
  
  Future<List<FileSystemEntity>> searchByExtension(String extension, {String? directory}) async {
    try {
      final searchDir = directory != null ? Directory(directory) : _externalStorage;
      if (searchDir == null || !await searchDir.exists()) return [];
      
      final results = <FileSystemEntity>[];
      await _searchByExtensionRecursively(searchDir, extension.toLowerCase(), results);
      return results;
      
    } catch (e) {
      return [];
    }
  }
  
  Future<void> _searchByExtensionRecursively(Directory dir, String extension, List<FileSystemEntity> results) async {
    try {
      final entities = await dir.list().toList();
      
      for (var entity in entities) {
        if (results.length >= 100) break;
        
        if (entity is File) {
          if (entity.path.toLowerCase().endsWith(extension)) {
            results.add(entity);
          }
        } else if (entity is Directory) {
          await _searchByExtensionRecursively(entity, extension, results);
        }
      }
    } catch (e) {}
  }
  
  Future<bool> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        Logger().info('Deleted file: $path', tag: 'FILE');
        return true;
      }
      return false;
    } catch (e) {
      Logger().error('Delete file error', tag: 'FILE', error: e);
      return false;
    }
  }
  
  Future<bool> deleteDirectory(String path) async {
    try {
      final dir = Directory(path);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        Logger().info('Deleted directory: $path', tag: 'FILE');
        return true;
      }
      return false;
    } catch (e) {
      Logger().error('Delete directory error', tag: 'FILE', error: e);
      return false;
    }
  }
  
  Future<bool> moveFile(String sourcePath, String destinationPath) async {
    try {
      final source = File(sourcePath);
      if (await source.exists()) {
        await source.rename(destinationPath);
        Logger().info('Moved file: $sourcePath -> $destinationPath', tag: 'FILE');
        return true;
      }
      return false;
    } catch (e) {
      Logger().error('Move file error', tag: 'FILE', error: e);
      return false;
    }
  }
  
  Future<bool> copyFile(String sourcePath, String destinationPath) async {
    try {
      final source = File(sourcePath);
      if (await source.exists()) {
        await source.copy(destinationPath);
        Logger().info('Copied file: $sourcePath -> $destinationPath', tag: 'FILE');
        return true;
      }
      return false;
    } catch (e) {
      Logger().error('Copy file error', tag: 'FILE', error: e);
      return false;
    }
  }
  
  Future<bool> createDirectory(String path) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
        Logger().info('Created directory: $path', tag: 'FILE');
        return true;
      }
      return false;
    } catch (e) {
      Logger().error('Create directory error', tag: 'FILE', error: e);
      return false;
    }
  }
  
  Future<Map<String, dynamic>> getFileInfo(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final stat = await file.stat();
        return {
          'name': path.split('/').last,
          'path': path,
          'size': stat.size,
          'sizeFormatted': Helpers.formatFileSize(stat.size),
          'modified': stat.modified,
          'accessed': stat.accessed,
          'type': path.split('.').last,
          'isDirectory': false,
          'extension': path.contains('.') ? path.split('.').last.toLowerCase() : '',
        };
      }
      return {'error': 'File not found'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }
  
  Future<Map<String, dynamic>> getDirectoryInfo(String path) async {
    try {
      final dir = Directory(path);
      if (await dir.exists()) {
        int totalSize = 0;
        int fileCount = 0;
        int dirCount = 0;
        int imageCount = 0;
        int videoCount = 0;
        int audioCount = 0;
        int documentCount = 0;
        
        await for (var entity in dir.list()) {
          if (entity is File) {
            fileCount++;
            final size = await entity.length();
            totalSize += size;
            
            final ext = entity.path.split('.').last.toLowerCase();
            if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext)) imageCount++;
            else if (['mp4', 'avi', 'mov', 'mkv', 'wmv'].contains(ext)) videoCount++;
            else if (['mp3', 'wav', 'aac', 'flac', 'ogg'].contains(ext)) audioCount++;
            else if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'].contains(ext)) documentCount++;
            
          } else if (entity is Directory) {
            dirCount++;
          }
        }
        
        return {
          'name': path.split('/').last,
          'path': path,
          'totalSize': totalSize,
          'sizeFormatted': Helpers.formatFileSize(totalSize),
          'fileCount': fileCount,
          'directoryCount': dirCount,
          'imageCount': imageCount,
          'videoCount': videoCount,
          'audioCount': audioCount,
          'documentCount': documentCount,
          'modified': await dir.stat().then((s) => s.modified),
        };
      }
      return {'error': 'Directory not found'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }
  
  Future<List<Map<String, dynamic>>> findDuplicateFiles(String directory) async {
    try {
      final filesByHash = <String, List<File>>{};
      
      final dir = Directory(directory);
      if (!await dir.exists()) return [];
      
      await for (var entity in dir.list(recursive: true)) {
        if (entity is File && await entity.length() > 0) {
          final hash = await _getFileHash(entity);
          if (!filesByHash.containsKey(hash)) {
            filesByHash[hash] = [];
          }
          filesByHash[hash]!.add(entity);
        }
      }
      
      final duplicates = <Map<String, dynamic>>[];
      for (var entry in filesByHash.entries) {
        if (entry.value.length > 1) {
          int totalSize = 0;
          for (var file in entry.value) {
            totalSize += await file.length();
          }
          duplicates.add({
            'hash': entry.key,
            'files': entry.value.map((f) => f.path).toList(),
            'count': entry.value.length,
            'totalSize': totalSize,
            'totalSizeFormatted': Helpers.formatFileSize(totalSize),
          });
        }
      }
      
      return duplicates;
      
    } catch (e) {
      Logger().error('Find duplicates error', tag: 'FILE', error: e);
      return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> findLargeFiles(String directory, int minSizeMB) async {
    try {
      final largeFiles = <Map<String, dynamic>>[];
      final dir = Directory(directory);
      
      if (!await dir.exists()) return [];
      
      await for (var entity in dir.list(recursive: true)) {
        if (entity is File) {
          final size = await entity.length();
          if (size >= minSizeMB * 1024 * 1024) {
            largeFiles.add({
              'path': entity.path,
              'name': entity.path.split('/').last,
              'size': size,
              'sizeFormatted': Helpers.formatFileSize(size),
              'modified': await entity.lastModified(),
            });
          }
        }
      }
      
      largeFiles.sort((a, b) => b['size'].compareTo(a['size']));
      return largeFiles;
      
    } catch (e) {
      Logger().error('Find large files error', tag: 'FILE', error: e);
      return [];
    }
  }
  
  Future<String> zipFiles(List<String> files, String outputPath) async {
    try {
      final encoder = ZipFileEncoder();
      final zipFile = File(outputPath);
      encoder.create(zipFile.path);
      
      for (var filePath in files) {
        final file = File(filePath);
        if (await file.exists()) {
          encoder.addFile(file);
        }
      }
      
      encoder.close();
      Logger().info('Zipped ${files.length} files to $outputPath', tag: 'FILE');
      return outputPath;
      
    } catch (e) {
      Logger().error('Zip files error', tag: 'FILE', error: e);
      return '';
    }
  }
  
  Future<List<File>> unzipFile(String zipPath, String outputDirectory) async {
    try {
      final bytes = File(zipPath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      final extractedFiles = <File>[];
      for (var file in archive) {
        if (!file.isFile) continue;
        
        final filename = file.name;
        final outputFile = File('$outputDirectory/$filename');
        
        if (!await outputFile.exists()) {
          await outputFile.create(recursive: true);
        }
        
        await outputFile.writeAsBytes(file.content as List<int>);
        extractedFiles.add(outputFile);
      }
      
      Logger().info('Unzipped ${extractedFiles.length} files', tag: 'FILE');
      return extractedFiles;
      
    } catch (e) {
      Logger().error('Unzip error', tag: 'FILE', error: e);
      return [];
    }
  }
  
  Future<String> _getFileHash(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return bytes.hashCode.toString();
    } catch (e) {
      return '';
    }
  }
  
  Future<Map<String, dynamic>> getStorageAnalysis() async {
    try {
      final dirs = [
        {'path': _externalStorage?.path, 'name': 'External Storage'},
        {'path': _internalStorage?.path, 'name': 'Internal Storage'},
        {'path': _downloadsDir?.path, 'name': 'Downloads'},
        {'path': _picturesDir?.path, 'name': 'Pictures'},
        {'path': _videosDir?.path, 'name': 'Videos'},
        {'path': _musicDir?.path, 'name': 'Music'},
      ];
      
      final analysis = <String, dynamic>{};
      
      for (var dir in dirs) {
        if (dir['path'] != null && await Directory(dir['path']!).exists()) {
          final info = await getDirectoryInfo(dir['path']!);
          analysis[dir['name']!] = info;
        }
      }
      
      return analysis;
      
    } catch (e) {
      Logger().error('Storage analysis error', tag: 'FILE', error: e);
      return {};
    }
  }
  
  Future<void> emptyTrash() async {
    try {
      final trashDir = Directory('/storage/emulated/0/.trash');
      if (await trashDir.exists()) {
        await trashDir.delete(recursive: true);
        Logger().info('Trash emptied', tag: 'FILE');
      }
    } catch (e) {
      Logger().error('Empty trash error', tag: 'FILE', error: e);
    }
  }
  
  String getFileTypeIcon(String path) {
    final extension = path.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'jpg': case 'jpeg': case 'png': case 'gif': case 'bmp': case 'webp':
        return '📷';
      case 'mp4': case 'avi': case 'mov': case 'mkv': case 'wmv': case 'flv':
        return '🎬';
      case 'mp3': case 'wav': case 'aac': case 'flac': case 'ogg': case 'm4a':
        return '🎵';
      case 'pdf':
        return '📄';
      case 'doc': case 'docx':
        return '📝';
      case 'xls': case 'xlsx':
        return '📊';
      case 'ppt': case 'pptx':
        return '📽️';
      case 'zip': case 'rar': case '7z': case 'tar': case 'gz':
        return '🗜️';
      case 'apk':
        return '📦';
      case 'txt':
        return '📃';
      case 'html': case 'htm':
        return '🌐';
      case 'json': case 'xml':
        return '📋';
      default:
        return '📁';
    }
  }
  
  String getMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    const mimeTypes = {
      'jpg': 'image/jpeg', 'jpeg': 'image/jpeg', 'png': 'image/png',
      'gif': 'image/gif', 'webp': 'image/webp', 'mp4': 'video/mp4',
      'mp3': 'audio/mpeg', 'pdf': 'application/pdf', 'txt': 'text/plain',
      'html': 'text/html', 'json': 'application/json', 'xml': 'application/xml',
    };
    return mimeTypes[extension] ?? 'application/octet-stream';
  }
}