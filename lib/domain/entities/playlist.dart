class Playlist {
  final String id;
  final String name;
  final List<String> trackIds; // Track IDs

  Playlist({
    required this.id,
    required this.name,
    required this.trackIds,
  });
}