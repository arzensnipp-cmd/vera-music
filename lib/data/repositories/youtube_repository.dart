import '../../domain/entities/track.dart';
import '../../core/services/youtube_service.dart';

class YoutubeRepository {
  final YoutubeService service;

  YoutubeRepository(this.service);

  Future<List<Track>> search(String query) async {
    return service.searchTracks(query);
  }

  Future<String?> getAudioUrl(String videoId) async {
    return service.getBestAudioStreamUrl(videoId);
  }
}
