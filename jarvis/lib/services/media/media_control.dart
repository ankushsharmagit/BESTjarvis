// lib/services/media/media_control.dart
// Complete Media Control Service

import 'package:audioplayers/audioplayers.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';

class MediaControlService {
  static final MediaControlService _instance = MediaControlService._internal();
  factory MediaControlService() => _instance;
  MediaControlService._internal();
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  final YoutubeExplode _yt = YoutubeExplode();
  
  bool _isPlaying = false;
  String? _currentTrack;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  List<String> _playlist = [];
  int _currentIndex = 0;
  
  Stream<Duration> get positionStream => _audioPlayer.onPositionChanged;
  Stream<PlayerState> get playerStateStream => _audioPlayer.onPlayerStateChanged;
  Stream<Duration> get durationStream => _audioPlayer.onDurationChanged;
  
  Future<void> initialize() async {
    await _audioPlayer.setSource(AssetSource('sounds/boot_up.mp3'));
    Logger().info('Media control service initialized', tag: 'MEDIA');
  }
  
  Future<void> play() async {
    try {
      await _audioPlayer.resume();
      _isPlaying = true;
      Logger().info('Media playback started', tag: 'MEDIA');
    } catch (e) {
      Logger().error('Play error', tag: 'MEDIA', error: e);
    }
  }
  
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      _isPlaying = false;
      Logger().info('Media playback paused', tag: 'MEDIA');
    } catch (e) {
      Logger().error('Pause error', tag: 'MEDIA', error: e);
    }
  }
  
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentPosition = Duration.zero;
      Logger().info('Media playback stopped', tag: 'MEDIA');
    } catch (e) {
      Logger().error('Stop error', tag: 'MEDIA', error: e);
    }
  }
  
  Future<void> next() async {
    try {
      if (_playlist.isNotEmpty && _currentIndex + 1 < _playlist.length) {
        _currentIndex++;
        await playTrack(_playlist[_currentIndex]);
      } else if (_playlist.isNotEmpty) {
        // Loop to beginning
        _currentIndex = 0;
        await playTrack(_playlist[_currentIndex]);
      }
      Logger().info('Next track', tag: 'MEDIA');
    } catch (e) {
      Logger().error('Next error', tag: 'MEDIA', error: e);
    }
  }
  
  Future<void> previous() async {
    try {
      if (_playlist.isNotEmpty && _currentIndex > 0) {
        _currentIndex--;
        await playTrack(_playlist[_currentIndex]);
      }
      Logger().info('Previous track', tag: 'MEDIA');
    } catch (e) {
      Logger().error('Previous error', tag: 'MEDIA', error: e);
    }
  }
  
  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      _currentPosition = position;
      Logger().info('Seeked to ${position.inSeconds}s', tag: 'MEDIA');
    } catch (e) {
      Logger().error('Seek error', tag: 'MEDIA', error: e);
    }
  }
  
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
      Logger().info('Volume set to ${(volume * 100).toStringAsFixed(0)}%', tag: 'MEDIA');
    } catch (e) {
      Logger().error('Set volume error', tag: 'MEDIA', error: e);
    }
  }
  
  Future<void> playTrack(String url) async {
    try {
      await _audioPlayer.setSourceUrl(url);
      await _audioPlayer.resume();
      _isPlaying = true;
      _currentTrack = url;
      Logger().info('Playing track: $url', tag: 'MEDIA');
    } catch (e) {
      Logger().error('Play track error', tag: 'MEDIA', error: e);
    }
  }
  
  Future<void> playLocal(String path) async {
    try {
      await _audioPlayer.setSourceDeviceFile(path);
      await _audioPlayer.resume();
      _isPlaying = true;
      _currentTrack = path;
      Logger().info('Playing local file: $path', tag: 'MEDIA');
    } catch (e) {
      Logger().error('Play local error', tag: 'MEDIA', error: e);
    }
  }
  
  Future<void> playAsset(String assetPath) async {
    try {
      await _audioPlayer.setSourceAsset(assetPath);
      await _audioPlayer.resume();
      _isPlaying = true;
      _currentTrack = assetPath;
      Logger().info('Playing asset: $assetPath', tag: 'MEDIA');
    } catch (e) {
      Logger().error('Play asset error', tag: 'MEDIA', error: e);
    }
  }
  
  Future<void> playYouTube(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audioStream = manifest.audioOnly.withHighestBitrate();
      final url = audioStream.url.toString();
      await playTrack(url);
      Logger().info('Playing YouTube video: $videoId', tag: 'MEDIA');
    } catch (e) {
      Logger().error('YouTube play error', tag: 'MEDIA', error: e);
    }
  }
  
  Future<YouTubeVideoInfo> getYouTubeInfo(String videoId) async {
    try {
      final video = await _yt.videos.get(videoId);
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      
      return YouTubeVideoInfo(
        title: video.title,
        author: video.author,
        duration: video.duration,
        thumbnail: video.thumbnails.highResUrl,
        viewCount: video.engagement.viewCount,
        likeCount: video.engagement.likeCount,
      );
    } catch (e) {
      throw Exception('Failed to get video info: $e');
    }
  }
  
  Future<List<YouTubeSearchResult>> searchYouTube(String query) async {
    try {
      final results = <YouTubeSearchResult>[];
      await for (var video in _yt.search.search(query)) {
        results.add(YouTubeSearchResult(
          title: video.title,
          author: video.author,
          duration: video.duration,
          id: video.id.value,
          thumbnail: video.thumbnails.highResUrl,
        ));
      }
      return results.take(10).toList();
    } catch (e) {
      Logger().error('YouTube search error', tag: 'MEDIA', error: e);
      return [];
    }
  }
  
  void addToPlaylist(String track) {
    _playlist.add(track);
    Logger().info('Added to playlist: $track', tag: 'MEDIA');
  }
  
  void removeFromPlaylist(int index) {
    if (index < _playlist.length) {
      _playlist.removeAt(index);
      Logger().info('Removed from playlist at index $index', tag: 'MEDIA');
    }
  }
  
  void clearPlaylist() {
    _playlist.clear();
    _currentIndex = 0;
    Logger().info('Playlist cleared', tag: 'MEDIA');
  }
  
  List<String> getPlaylist() {
    return List.unmodifiable(_playlist);
  }
  
  bool isPlaying() => _isPlaying;
  
  Duration getCurrentPosition() => _currentPosition;
  
  Duration getTotalDuration() => _totalDuration;
  
  String getFormattedPosition() {
    return '${_currentPosition.inMinutes}:${(_currentPosition.inSeconds % 60).toString().padLeft(2, '0')}';
  }
  
  String getFormattedDuration() {
    return '${_totalDuration.inMinutes}:${(_totalDuration.inSeconds % 60).toString().padLeft(2, '0')}';
  }
  
  double getProgressPercent() {
    if (_totalDuration.inMilliseconds == 0) return 0;
    return _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
  }
  
  Future<void> dispose() async {
    await _audioPlayer.dispose();
    _yt.close();
  }
}

class YouTubeVideoInfo {
  final String title;
  final String author;
  final Duration? duration;
  final String? thumbnail;
  final int? viewCount;
  final int? likeCount;
  
  YouTubeVideoInfo({
    required this.title,
    required this.author,
    this.duration,
    this.thumbnail,
    this.viewCount,
    this.likeCount,
  });
  
  String getFormattedDuration() {
    if (duration == null) return 'Unknown';
    return '${duration!.inMinutes}:${(duration!.inSeconds % 60).toString().padLeft(2, '0')}';
  }
  
  String getFormattedViews() {
    if (viewCount == null) return 'Unknown';
    if (viewCount! >= 1000000) {
      return '${(viewCount! / 1000000).toStringAsFixed(1)}M views';
    }
    if (viewCount! >= 1000) {
      return '${(viewCount! / 1000).toStringAsFixed(1)}K views';
    }
    return '$viewCount views';
  }
}

class YouTubeSearchResult {
  final String title;
  final String author;
  final Duration? duration;
  final String id;
  final String? thumbnail;
  
  YouTubeSearchResult({
    required this.title,
    required this.author,
    this.duration,
    required this.id,
    this.thumbnail,
  });
  
  String getFormattedDuration() {
    if (duration == null) return 'Live';
    return '${duration!.inMinutes}:${(duration!.inSeconds % 60).toString().padLeft(2, '0')}';
  }
  
  String getUrl() {
    return 'https://youtube.com/watch?v=$id';
  }
}