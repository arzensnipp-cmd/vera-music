import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../data/repositories/download_repository.dart';
import '../../domain/entities/track.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late Future<List<Track>> _localTracksFuture;

  @override
  void initState() {
    super.initState();
    _localTracksFuture = DownloadRepository().getLocalTracks();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.myLibrary,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.offlineDescription,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<List<Track>>(
                future: _localTracksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFBEA6FF)));
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        '${l10n.error}: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final tracks = snapshot.data ?? [];

                  if (tracks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.music_note, size: 64, color: Colors.white24),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz müzik indirilmedi.',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white60),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Arana sekmesinden müzik indirmeye başla',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: tracks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF121212),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white10),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(colors: [Color(0xFFBEA6FF), Color(0xFF7C55FF)]),
                              ),
                              child: const Icon(Icons.music_note, color: Colors.white30, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    track.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Offline',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white60),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.play_circle_fill, color: Color(0xFFBEA6FF), size: 28),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      );
                    },
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
