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

  Future<List<Track>> getTrendingMusic() async {
    try {
      final searchList = await _youtube.search.search('trending music');
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

  Future<String?> getBestAudioStreamUrl(String videoId) async {
    try {
      final manifest = await _youtube.videos.streamsClient.getManifest(VideoId(videoId));
      final audioStream = manifest.audioOnly.withHighestBitrate();
      if (audioStream != null) {
        return audioStream.url.toString();
      }
      return null;
    } catch (e) {
      throw Exception('Ses akışı alınamadı: $e');
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
