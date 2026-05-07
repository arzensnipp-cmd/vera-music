import 'dart:async';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../../domain/entities/track.dart';

class YoutubeService {
  final YoutubeExplode _youtube;

  YoutubeService() : _youtube = YoutubeExplode();

  Future<List<Track>> searchTracks(String query) async {
    try {
      final searchList = await _youtube.search.search(query);
      final results = searchList.take(10).toList();

      return results.map((video) {
        return Track(
          id: video.id.value,
          title: cleanTitle(video.title),
          author: video.author,
          duration: video.duration,
          thumbnailUrl: video.thumbnails.mediumResUrl,
          videoUrl: 'https://www.youtube.com/watch?v=${video.id.value}',
        );
      }).toList();
    } catch (e) {
      throw Exception('YouTube araması başarısız: $e');
    }
  }

  Future<List<Track>> getTrendingMusic(String localeCode) async {
    try {
      final query = _trendingQueryForLocale(localeCode);
      final searchList = await _youtube.search.search(query);
      final results = searchList.take(20).toList();

      return results.map((video) {
        return Track(
          id: video.id.value,
          title: cleanTitle(video.title),
          author: video.author,
          duration: video.duration,
          thumbnailUrl: video.thumbnails.mediumResUrl,
          videoUrl: 'https://www.youtube.com/watch?v=${video.id.value}',
        );
      }).toList();
    } catch (e) {
      throw Exception('Trending müzik alınamadı: $e');
    }
  }

  String _trendingQueryForLocale(String localeCode) {
    switch (localeCode.toLowerCase()) {
      case 'tr':
        return 'trend müzik';
      case 'de':
        return 'Trendmusik';
      case 'fr':
        return 'musique tendance';
      case 'es':
        return 'música de tendencia';
      case 'ar':
        return 'الموسيقى الرائجة';
      default:
        return 'trending music';
    }
  }

  Future<String?> getBestAudioStreamUrl(String videoId) async {
    try {
      // Kısa bir gecikme ekle (YouTube sunucusunun hazır olması için)
      await Future.delayed(const Duration(milliseconds: 500));

      // 10 saniye timeout ile manifest'i al
      final manifest = await _youtube.videos.streamsClient
          .getManifest(VideoId(videoId))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Bağlantı zaman aşımına uğradı'),
          );

      final audioStream = manifest.audioOnly.withHighestBitrate();
      if (audioStream != null) {
        return audioStream.url.toString();
      }
      return null;
    } on TimeoutException {
      throw Exception('Bağlantı zaman aşımına uğradı');
    } catch (e) {
      throw Exception('Bağlantı Başarısız: $e');
    }
  }

  String cleanTitle(String rawTitle) {
    var title = rawTitle.replaceAll(RegExp(r'\s*\[[^\]]+\]'), '');
    title = title.replaceAll(RegExp(r'\s*\([^\)]+\)'), '');
    title = title.replaceAll(
      RegExp(r'Official Music Video|Official Video|Lyrics|Lyric Video|HD|HQ|Music Video',
          caseSensitive: false),
      '',
    );
    title = title.replaceAll(RegExp(r'\s*[-–—]\s*'), ' - ');
    return title.trim().replaceAll(RegExp(r'\s{2,}'), ' ');
  }

  void close() {
    _youtube.close();
  }
}
