import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/services/youtube_service.dart';
import '../../domain/entities/track.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final YoutubeService _youtubeService = YoutubeService();
  List<Track> _trendingTracks = [];
  bool _isLoading = true;
  String? _error;

  Locale? _lastLocale;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeCode = Localizations.localeOf(context).languageCode;
    if (_lastLocale?.languageCode != localeCode) {
      _lastLocale = Locale(localeCode);
      _loadTrending(localeCode);
    }
  }

  Future<void> _loadTrending(String localeCode) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tracks = await _youtubeService.getTrendingMusic(localeCode);
      setState(() {
        _trendingTracks = tracks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Trending müzik yüklenemedi: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(l10n.appName,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    )),
            const SizedBox(height: 8),
            Text(l10n.premiumExperience,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                    )),
            const SizedBox(height: 28),
            _TrendingSection(
              tracks: _trendingTracks,
              isLoading: _isLoading,
              error: _error,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingSection extends StatelessWidget {
  final List<Track> tracks;
  final bool isLoading;
  final String? error;

  const _TrendingSection({
    required this.tracks,
    required this.isLoading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return Expanded(
        child: Center(
          child: Text(error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        itemCount: tracks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 18),
        itemBuilder: (context, index) {
          final track = tracks[index];
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF000000),
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    image: DecorationImage(
                      image: NetworkImage(track.thumbnailUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(track.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              )),
                      const SizedBox(height: 6),
                      Text(track.author, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.play_circle_fill, size: 34, color: Color(0xFFBEA6FF)),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
