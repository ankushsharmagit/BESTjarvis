// lib/services/media/gallery_service.dart
// Gallery Service with Photo Management

import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';
import '../../utils/logger.dart';
import '../../utils/helpers.dart';

class GalleryService {
  static final GalleryService _instance = GalleryService._internal();
  factory GalleryService() => _instance;
  GalleryService._internal();
  
  List<AssetEntity> _allImages = [];
  List<AssetEntity> _allVideos = [];
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    try {
      final hasPermission = await PhotoManager.requestPermissionExtend();
      if (hasPermission.isAuth) {
        await _loadAssets();
        _isInitialized = true;
        Logger().info('Gallery service initialized with ${_allImages.length} images and ${_allVideos.length} videos', tag: 'GALLERY');
      }
    } catch (e) {
      Logger().error('Gallery init error', tag: 'GALLERY', error: e);
    }
  }
  
  Future<void> _loadAssets() async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      filterOption: FilterOptionGroup(
        imageOption: FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
        videoOption: FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
      ),
    );
    
    _allImages = [];
    _allVideos = [];
    
    for (var album in albums) {
      final assets = await album.getAssetListPaged(page: 0, size: 1000);
      for (var asset in assets) {
        if (asset.type == AssetType.image) {
          _allImages.add(asset);
        } else if (asset.type == AssetType.video) {
          _allVideos.add(asset);
        }
      }
    }
    
    // Sort by date (newest first)
    _allImages.sort((a, b) => b.createDateTime!.compareTo(a.createDateTime!));
    _allVideos.sort((a, b) => b.createDateTime!.compareTo(a.createDateTime!));
  }
  
  Future<List<Map<String, dynamic>>> getAllImages() async {
    final images = <Map<String, dynamic>>[];
    
    for (var asset in _allImages) {
      final file = await asset.file;
      if (file != null) {
        images.add({
          'id': asset.id,
          'path': file.path,
          'name': file.path.split('/').last,
          'size': await file.length(),
          'sizeFormatted': Helpers.formatFileSize(await file.length()),
          'created': asset.createDateTime,
          'width': asset.width,
          'height': asset.height,
          'type': 'image',
        });
      }
    }
    
    return images;
  }
  
  Future<List<Map<String, dynamic>>> getAllVideos() async {
    final videos = <Map<String, dynamic>>[];
    
    for (var asset in _allVideos) {
      final file = await asset.file;
      if (file != null) {
        videos.add({
          'id': asset.id,
          'path': file.path,
          'name': file.path.split('/').last,
          'size': await file.length(),
          'sizeFormatted': Helpers.formatFileSize(await file.length()),
          'created': asset.createDateTime,
          'width': asset.width,
          'height': asset.height,
          'duration': asset.duration,
          'type': 'video',
        });
      }
    }
    
    return videos;
  }
  
  Future<List<Map<String, dynamic>>> getImagesByDate(DateTime date) async {
    final images = await getAllImages();
    return images.where((img) => 
      img['created'] != null && 
      img['created'].year == date.year &&
      img['created'].month == date.month &&
      img['created'].day == date.day
    ).toList();
  }
  
  Future<List<Map<String, dynamic>>> getRecentImages({int days = 7}) async {
    final images = await getAllImages();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return images.where((img) => 
      img['created'] != null && img['created'].isAfter(cutoffDate)
    ).toList();
  }
  
  Future<List<Map<String, dynamic>>> getSelfies() async {
    final images = await getAllImages();
    // Filter by front camera orientation or face detection
    return images.where((img) => 
      img['path'].toLowerCase().contains('selfie') ||
      img['path'].toLowerCase().contains('front')
    ).toList();
  }
  
  Future<List<Map<String, dynamic>>> getScreenshots() async {
    final images = await getAllImages();
    return images.where((img) => 
      img['path'].toLowerCase().contains('screenshot') ||
      img['path'].toLowerCase().contains('screen_shot')
    ).toList();
  }
  
  Future<List<Map<String, dynamic>>> getImagesByLocation(double lat, double lng, double radiusKm) async {
    // This would require location data in photos
    return [];
  }
  
  Future<List<Map<String, dynamic>>> searchImages(String query) async {
    final images = await getAllImages();
    final lowerQuery = query.toLowerCase();
    return images.where((img) => 
      img['name'].toLowerCase().contains(lowerQuery) ||
      img['path'].toLowerCase().contains(lowerQuery)
    ).toList();
  }
  
  Future<bool> deleteImage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        await _loadAssets(); // Refresh list
        Logger().info('Deleted image: $path', tag: 'GALLERY');
        return true;
      }
      return false;
    } catch (e) {
      Logger().error('Delete image error', tag: 'GALLERY', error: e);
      return false;
    }
  }
  
  Future<bool> moveImage(String sourcePath, String destinationPath) async {
    try {
      final source = File(sourcePath);
      if (await source.exists()) {
        await source.rename(destinationPath);
        await _loadAssets();
        Logger().info('Moved image: $sourcePath -> $destinationPath', tag: 'GALLERY');
        return true;
      }
      return false;
    } catch (e) {
      Logger().error('Move image error', tag: 'GALLERY', error: e);
      return false;
    }
  }
  
  Future<File?> compressImage(String path, {int quality = 85}) async {
    try {
      final file = File(path);
      final bytes = await file.readAsBytes();
      final compressedBytes = await ImageCompressor.compressImage(
        bytes,
        quality: quality,
      );
      
      final outputPath = '${await getTemporaryDirectory()}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final compressedFile = File(outputPath);
      await compressedFile.writeAsBytes(compressedBytes);
      
      Logger().info('Compressed image: $path', tag: 'GALLERY');
      return compressedFile;
      
    } catch (e) {
      Logger().error('Compress image error', tag: 'GALLERY', error: e);
      return null;
    }
  }
  
  Future<Map<String, dynamic>> getGalleryStats() async {
    final images = await getAllImages();
    final videos = await getAllVideos();
    
    int totalImageSize = 0;
    for (var img in images) {
      totalImageSize += img['size'] ?? 0;
    }
    
    int totalVideoSize = 0;
    for (var vid in videos) {
      totalVideoSize += vid['size'] ?? 0;
    }
    
    return {
      'totalImages': images.length,
      'totalVideos': videos.length,
      'totalImageSize': totalImageSize,
      'totalImageSizeFormatted': Helpers.formatFileSize(totalImageSize),
      'totalVideoSize': totalVideoSize,
      'totalVideoSizeFormatted': Helpers.formatFileSize(totalVideoSize),
      'totalSize': totalImageSize + totalVideoSize,
      'totalSizeFormatted': Helpers.formatFileSize(totalImageSize + totalVideoSize),
    };
  }
  
  Future<void> refresh() async {
    await _loadAssets();
  }
}