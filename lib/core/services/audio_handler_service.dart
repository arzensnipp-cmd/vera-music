import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class VeraAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player;
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

  VeraAudioHandler() : _player = AudioPlayer() {
    _player.playerStateStream.listen(_broadcastPlaybackState);
    _player.playbackEventStream.listen(_broadcastPlaybackState);
    _player.currentIndexStream.listen((index) {
      if (index != null && queue.value.length > index) {
        mediaItem.add(queue.value[index]);
      }
    });
  }

  @override
  Future<void> addQueueItem(MediaItem item) async {
    await addQueueItems([item]);
  }

  @override
  Future<void> addQueueItems(List<MediaItem> items) async {
    try {
      queue.add(items);
      final audioSources = items.map((item) {
        final audioUrl = item.extras?['audioUrl'] ?? item.id;
        if (audioUrl == null || audioUrl.isEmpty) {
          throw Exception('Bağlantı Başarısız: Audio URL bulunamadı');
        }
        return AudioSource.uri(Uri.parse(audioUrl));
      }).toList();
      await _playlist.clear();
      await _playlist.addAll(audioSources);
      await _player.setAudioSource(_playlist);
    } catch (e) {
      print('Şarkı yüklenirken hata: $e');
      if (items.length > 1) {
        final remainingItems = items.sublist(1);
        if (remainingItems.isNotEmpty) {
          await addQueueItems(remainingItems);
        }
      }
      throw Exception('Bağlantı Başarısız');
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> setLoopMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        await _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        await _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.all:
        await _player.setLoopMode(LoopMode.all);
        break;
      case AudioServiceRepeatMode.group:
        // Not implemented
        break;
    }
  }

  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    await _player.setShuffleModeEnabled(shuffleMode == AudioServiceShuffleMode.all);
  }
  void _broadcastPlaybackState(dynamic _) {
    final loopMode = _player.loopMode;
    final shuffleMode = _player.shuffleModeEnabled;
    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: _transformProcessingState(_player.processingState),
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _player.currentIndex ?? 0,
      repeatMode: loopMode == LoopMode.one
          ? AudioServiceRepeatMode.one
          : loopMode == LoopMode.all
              ? AudioServiceRepeatMode.all
              : AudioServiceRepeatMode.none,
      shuffleMode: shuffleMode ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
    ));
  }

  AudioProcessingState _transformProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        return AudioProcessingState.idle;
    }
  }
}
