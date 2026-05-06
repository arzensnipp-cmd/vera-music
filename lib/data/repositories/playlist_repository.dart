import '../../domain/entities/playlist.dart';

class PlaylistRepository {
  final List<Playlist> _playlists = [];

  List<Playlist> getPlaylists() => _playlists;

  void addPlaylist(Playlist playlist) {
    _playlists.add(playlist);
  }

  void addTrackToPlaylist(String playlistId, String trackId) {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    if (!playlist.trackIds.contains(trackId)) {
      playlist.trackIds.add(trackId);
    }
  }

  void removeTrackFromPlaylist(String playlistId, String trackId) {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    playlist.trackIds.remove(trackId);
  }
}