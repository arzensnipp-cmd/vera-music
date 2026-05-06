import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../core/providers/locale_provider.dart';
import 'pages/home_page.dart';
import 'pages/library_page.dart';
import 'pages/player_page.dart';
import 'pages/search_page.dart';
import 'pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VeraMusicApp extends StatelessWidget {
  final ValueListenable<AudioHandler> audioHandlerNotifier;
  final Locale initialLocale;
  final SharedPreferences preferences;

  const VeraMusicApp({
    super.key,
    required this.audioHandlerNotifier,
    required this.initialLocale,
    required this.preferences,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AudioHandler>(
      valueListenable: audioHandlerNotifier,
      builder: (context, audioHandler, child) {
        return MultiProvider(
          providers: [
            Provider<AudioHandler>.value(value: audioHandler),
            ChangeNotifierProvider(create: (_) => LocaleProvider(preferences, initialLocale)),
          ],
          child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return FutureBuilder(
            future: localeProvider.initialize(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: Scaffold(
                    backgroundColor: Color(0xFF000000),
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Vera Music',
                themeMode: ThemeMode.dark,
                theme: ThemeData.dark().copyWith(
                  scaffoldBackgroundColor: const Color(0xFF000000),
                  colorScheme: ColorScheme.dark(
                    primary: const Color(0xFFBEA6FF),
                    secondary: const Color(0xFF7C55FF),
                    surface: const Color(0xFF000000),
                  ),
                  textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
                ),
                locale: localeProvider.locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'), // English
                  Locale('tr'), // Turkish
                  Locale('de'), // German
                  Locale('fr'), // French
                  Locale('es'), // Spanish
                  Locale('ar'), // Arabic
                ],
                localeResolutionCallback: (locale, supportedLocales) {
                  for (var supportedLocale in supportedLocales) {
                    if (supportedLocale.languageCode == locale?.languageCode) {
                      return supportedLocale;
                    }
                  }
                  return supportedLocales.first; // Default to English
                },
                home: const MainShell(),
              );
            },
          );
        },
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int selectedIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    final audioHandler = context.read<AudioHandler>();
    pages = <Widget>[
      const HomePage(),
      SearchPage(audioHandler: audioHandler),
      const LibraryPage(),
      PlayerPage(audioHandler: audioHandler),
      const SettingsPage(),
    ];
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onItemTapped,
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_filled), label: l10n.home),
          NavigationDestination(icon: const Icon(Icons.search), label: l10n.search),
          NavigationDestination(icon: const Icon(Icons.library_music), label: l10n.library),
          NavigationDestination(icon: const Icon(Icons.play_circle_fill), label: l10n.player),
          NavigationDestination(icon: const Icon(Icons.settings), label: l10n.settings),
        ],
      ),
    );
  }
}
