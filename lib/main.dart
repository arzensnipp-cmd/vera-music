import 'dart:developer' as dev;
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/services/audio_handler_service.dart';
import 'presentation/app.dart';

class _DummyAudioHandler extends BaseAudioHandler {
  @override
  Future<void> play() async {
    dev.log('DummyAudioHandler: play() called - audio service not available', name: 'VeraMusic');
  }

  @override
  Future<void> pause() async {
    dev.log('DummyAudioHandler: pause() called - audio service not available', name: 'VeraMusic');
  }

  @override
  Future<void> stop() async {
    dev.log('DummyAudioHandler: stop() called - audio service not available', name: 'VeraMusic');
  }

  @override
  Future<void> addQueueItems(List<MediaItem> items) async {
    dev.log('DummyAudioHandler: addQueueItems() called - audio service not available', name: 'VeraMusic');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  dev.log('Requesting permissions...', name: 'VeraMusic');
  try {
    await [
      Permission.storage,
      Permission.notification,
    ].request();
    dev.log('Permissions requested', name: 'VeraMusic');
  } catch (e) {
    dev.log('Failed to request permissions: $e', name: 'VeraMusic');
  }

  AudioHandler? audioHandler;

  try {
    dev.log('Initializing AudioService...', name: 'VeraMusic');
    audioHandler = await AudioService.init(
      builder: () => VeraAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'vera_music_channel',
        androidNotificationChannelName: 'Vera Music Playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        androidNotificationIcon: 'mipmap/ic_launcher',
      ),
    ).timeout(const Duration(seconds: 10), onTimeout: () {
      dev.log('AudioService initialization timed out', name: 'VeraMusic');
      throw TimeoutException('AudioService init timeout');
    });
    dev.log('AudioService initialized successfully', name: 'VeraMusic');
  } catch (e, stackTrace) {
    dev.log('Failed to initialize AudioService: $e', name: 'VeraMusic', error: e, stackTrace: stackTrace);
    // Create a dummy audio handler to prevent app crash
    audioHandler = _DummyAudioHandler();
  }

  runApp(VeraMusicApp(audioHandler: audioHandler));
}
