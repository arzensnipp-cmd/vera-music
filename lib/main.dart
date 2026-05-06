import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'core/services/audio_handler_service.dart';
import 'presentation/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final audioHandler = await AudioService.init(
    builder: () => VeraAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'vera_music_channel',
      androidNotificationChannelName: 'Vera Music Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
    ),
  );

  runApp(VeraMusicApp(audioHandler: audioHandler));
}
