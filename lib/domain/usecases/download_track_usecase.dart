import '../../data/repositories/download_repository.dart';
import '../../domain/entities/track.dart';

class DownloadTrackUseCase {
  final DownloadRepository repository;

  DownloadTrackUseCase(this.repository);

  Future<String> execute(Track track, String audioUrl) async {
    return repository.downloadTrack(track, audioUrl);
  }
}
