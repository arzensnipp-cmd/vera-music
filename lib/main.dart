import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final prefs = await SharedPreferences.getInstance();
  final initialLanguage = _resolveInitialLanguage(prefs);
  await prefs.setString('preferred_language', initialLanguage);

  final audioHandlerNotifier = ValueNotifier<AudioHandler>(_DummyAudioHandler());

  runApp(VeraMusicApp(
    audioHandlerNotifier: audioHandlerNotifier,
    initialLocale: Locale(initialLanguage),
    preferences: prefs,
  ));

  _initializeAudioService(audioHandlerNotifier);
}

String _resolveInitialLanguage(SharedPreferences prefs) {
  final savedLanguage = prefs.getString('preferred_language');
  if (savedLanguage != null && savedLanguage.isNotEmpty) {
    return savedLanguage == 'tr' ? 'tr' : 'en';
  }

  final platformLocale = Platform.localeName.split(RegExp('[-_]')).first.toLowerCase();
  return platformLocale == 'tr' ? 'tr' : 'en';
}

Future<void> _initializeAudioService(ValueNotifier<AudioHandler> handlerNotifier) async {
  try {
    dev.log('Initializing AudioService...', name: 'VeraMusic');
    final audioHandler = await AudioService.init(
      builder: () => VeraAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'vera_music_channel',
        androidNotificationChannelName: 'Vera Music Playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: false,
        androidNotificationIcon: 'mipmap/ic_launcher',
      ),
    ).timeout(const Duration(seconds: 10), onTimeout: () {
      dev.log('AudioService initialization timed out', name: 'VeraMusic');
      throw TimeoutException('AudioService init timeout');
    });
    handlerNotifier.value = audioHandler;
    dev.log('AudioService initialized successfully', name: 'VeraMusic');
  } catch (e, stackTrace) {
    dev.log('Failed to initialize AudioService: $e', name: 'VeraMusic', error: e, stackTrace: stackTrace);
  }
}
