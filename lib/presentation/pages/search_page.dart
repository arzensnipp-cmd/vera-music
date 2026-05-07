import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/services/youtube_service.dart';
import '../../data/repositories/download_repository.dart';
import '../../domain/entities/track.dart';

class SearchPage extends StatefulWidget {
  final AudioHandler audioHandler;
  const SearchPage({super.key, required this.audioHandler});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final YoutubeService _youtubeService = YoutubeService();
  final DownloadRepository _downloadRepository = DownloadRepository();
  final TextEditingController _controller = TextEditingController();
  List<Track> _tracks = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _youtubeService.close();
    super.dispose();
  }

  Future<void> _search(String query) async {
    final l10n = AppLocalizations.of(context)!;
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterSearchTerm)),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final items = await _youtubeService.searchTracks(query);
      setState(() {
        _tracks = items;
        _isLoading = false;
      });
      // İlk track'i otomatik oynat
      if (items.isNotEmpty) {
        await _playTrack(items.first);
      }
    } catch (e) {
      setState(() {
        _tracks = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.searchFailed}: $e')),
        );
      }
    }
  }

  Future<void> _downloadTrack(Track track) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final audioUrl = await _youtubeService.getBestAudioStreamUrl(track.id);
      if (audioUrl != null) {
        final path = await _downloadRepository.downloadTrack(track, audioUrl);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.downloadCompleted}: $path')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.downloadFailed}: $e')),
        );
      }
    }
  }

  void _showAddToPlaylistDialog(Track track) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addToPlaylist),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.createPlaylist),
              onTap: () {
                Navigator.of(context).pop();
                _showCreatePlaylistDialog(track);
              },
            ),
            // For simplicity, assume a default playlist
            ListTile(
              title: const Text('My Playlist'),
              onTap: () {
                // Add to playlist logic
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${track.title} ${l10n.addToPlaylist.toLowerCase()}')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePlaylistDialog(Track track) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.createPlaylist),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: l10n.createPlaylist),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                // Create playlist and add track
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${controller.text} ${l10n.createPlaylist.toLowerCase()}')),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _playTrack(Track track) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text('Oynatma başlatılıyor: ${track.title}')),
    );

    try {
      final audioUrl = await _youtubeService.getBestAudioStreamUrl(track.id);
      if (audioUrl == null || audioUrl.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Link hatası: URL bulunamadı')),
        );
        return;
      }

      final mediaItem = MediaItem(
        id: track.id,
        title: track.title,
        artist: track.author,
        duration: track.duration,
        artUri: Uri.parse(track.thumbnailUrl),
        extras: {'audioUrl': audioUrl},
      );
      await widget.audioHandler.addQueueItem(mediaItem);
      await widget.audioHandler.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('HATA: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: _search,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF000000),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFFBEA6FF)),
                      SizedBox(height: 16),
                      Text("Searching...", style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              )
            else if (_tracks.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    l10n.noSearch,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white60),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _tracks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final track = _tracks[index];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () => _playTrack(track),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF000000),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: ListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                            contentPadding: const EdgeInsets.all(12),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                track.thumbnailUrl,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(colors: [Color(0xFF7C55FF), Color(0xFFBEA6FF)]),
                                  ),
                                  child: const Icon(Icons.music_note, color: Colors.white30),
                                ),
                              ),
                            ),
                            title: Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              track.author,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white60),
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'add_to_playlist') {
                                  _showAddToPlaylistDialog(track);
                                } else if (value == 'download') {
                                  _downloadTrack(track);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'add_to_playlist',
                                  child: Text(l10n.addToPlaylist),
                                ),
                                PopupMenuItem(
                                  value: 'download',
                                  child: Text(l10n.download),
                                ),
                              ],
                              icon: const Icon(Icons.more_vert, color: Colors.white70),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
