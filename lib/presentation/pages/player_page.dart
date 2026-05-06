import 'dart:async';
import 'dart:ui';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:math' as math;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PlayerPage extends StatefulWidget {
  final AudioHandler audioHandler;
  const PlayerPage({super.key, required this.audioHandler});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with TickerProviderStateMixin {
  late PanelController _panelController;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _panelController = PanelController();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SlidingUpPanel(
      controller: _panelController,
      minHeight: 110,
      maxHeight: MediaQuery.of(context).size.height * 0.92,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      panelBuilder: (scrollCtrl) => _buildPlayerContent(scrollCtrl, l10n),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000000), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<MediaItem?>(
                stream: widget.audioHandler.mediaItem,
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data?.title ?? l10n.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                l10n.slideToOpen,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerContent(ScrollController controller, AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
        child: Container(
          color: const Color(0xFF000000).withOpacity(0.94),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              StreamBuilder<MediaItem?>(
                stream: widget.audioHandler.mediaItem,
                builder: (_, snapshot) {
                  final mediaItem = snapshot.data;
                  return StreamBuilder<PlaybackState>(
                    stream: widget.audioHandler.playbackState,
                    builder: (_, playbackSnapshot) {
                      final isPlaying = playbackSnapshot.data?.playing ?? false;
                      if (isPlaying && !_rotationController.isAnimating) {
                        _rotationController.repeat();
                      } else if (!isPlaying && _rotationController.isAnimating) {
                        _rotationController.stop();
                      }
                      return AnimatedBuilder(
                        animation: _rotationController,
                        builder: (_, child) {
                          return Transform.rotate(
                            angle: _rotationController.value * 2 * math.pi,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(38),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7C55FF), Color(0xFFBEA6FF)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7C55FF).withOpacity(0.3),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: mediaItem?.artUri != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(38),
                                  child: Image.network(
                                    mediaItem!.artUri.toString(),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.music_note,
                                      size: 100,
                                      color: Colors.white30,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.music_note,
                                  size: 100,
                                  color: Colors.white30,
                                ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
              StreamBuilder<MediaItem?>(
                stream: widget.audioHandler.mediaItem,
                builder: (_, snapshot) {
                  final mediaItem = snapshot.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.nowPlaying,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mediaItem?.title ?? l10n.appName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mediaItem?.artist ?? '---',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white60,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              StreamBuilder<PlaybackState>(
                stream: widget.audioHandler.playbackState,
                builder: (_, snapshot) {
                  final position = snapshot.data?.updatePosition ?? Duration.zero;
                  final duration = snapshot.data?.bufferedPosition ?? const Duration(seconds: 225); // Fallback
                  final maxDuration = duration.inSeconds > 0 ? duration.inSeconds : 225;
                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                          activeTrackColor: const Color(0xFFBEA6FF),
                          inactiveTrackColor: Colors.white10,
                          thumbColor: const Color(0xFFBEA6FF),
                          overlayColor: const Color(0xFFBEA6FF).withOpacity(0.2),
                        ),
                        child: Slider(
                          value: position.inSeconds.toDouble().clamp(0, maxDuration.toDouble()),
                          max: maxDuration.toDouble(),
                          onChanged: (value) {
                            widget.audioHandler.seek(Duration(seconds: value.toInt()));
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              StreamBuilder<PlaybackState>(
                stream: widget.audioHandler.playbackState,
                builder: (_, snapshot) {
                  final isPlaying = snapshot.data?.playing ?? false;
                  final repeatMode = snapshot.data?.repeatMode ?? AudioServiceRepeatMode.none;
                  final shuffleMode = snapshot.data?.shuffleMode ?? AudioServiceShuffleMode.none;
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              final newMode = shuffleMode == AudioServiceShuffleMode.all
                                  ? AudioServiceShuffleMode.none
                                  : AudioServiceShuffleMode.all;
                              widget.audioHandler.setShuffleMode(newMode);
                            },
                            icon: Icon(
                              Icons.shuffle,
                              size: 24,
                              color: shuffleMode == AudioServiceShuffleMode.all
                                  ? const Color(0xFFBEA6FF)
                                  : Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 32),
                          IconButton(
                            onPressed: () => widget.audioHandler.skipToPrevious(),
                            icon: const Icon(Icons.skip_previous_sharp, size: 32, color: Colors.white70),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFBEA6FF),
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(color: Color(0xFFBEA6FF), blurRadius: 30, spreadRadius: 5),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () {
                                if (isPlaying) {
                                  widget.audioHandler.pause();
                                } else {
                                  widget.audioHandler.play();
                                }
                              },
                              icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.black,
                                size: 36,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            onPressed: () => widget.audioHandler.skipToNext(),
                            icon: const Icon(Icons.skip_next_sharp, size: 32, color: Colors.white70),
                          ),
                          const SizedBox(width: 32),
                          IconButton(
                            onPressed: () {
                              final newMode = repeatMode == AudioServiceRepeatMode.none
                                  ? AudioServiceRepeatMode.all
                                  : repeatMode == AudioServiceRepeatMode.all
                                      ? AudioServiceRepeatMode.one
                                      : AudioServiceRepeatMode.none;
                              widget.audioHandler.setRepeatMode(newMode);
                            },
                            icon: Icon(
                              repeatMode == AudioServiceRepeatMode.one
                                  ? Icons.repeat_one
                                  : Icons.repeat,
                              size: 24,
                              color: repeatMode != AudioServiceRepeatMode.none
                                  ? const Color(0xFFBEA6FF)
                                  : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
