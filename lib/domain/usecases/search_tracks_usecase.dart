import '../../data/repositories/youtube_repository.dart';
import '../entities/track.dart';

class SearchTracksUseCase {
  final YoutubeRepository repository;

  SearchTracksUseCase(this.repository);

  Future<List<Track>> execute(String query) async {
    return repository.search(query);
  }
}
