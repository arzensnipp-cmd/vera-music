import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../core/providers/locale_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkMode = true;
  String quality = 'High';
  String selectedLanguage = 'en'; // Default to English

  final Map<String, String> languages = {
    'en': 'English',
    'tr': 'Türkçe',
    'de': 'Deutsch',
    'fr': 'Français',
    'es': 'Español',
    'ar': 'العربية',
  };

  @override
  void initState() {
    super.initState();
    // Get current locale
    final localeProvider = context.read<LocaleProvider>();
    selectedLanguage = localeProvider.locale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settings, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            SwitchListTile(
              value: darkMode,
              onChanged: (value) => setState(() => darkMode = value),
              title: Text(l10n.darkMode),
              subtitle: const Text('Uygulama temasını yönetir'),
              activeColor: const Color(0xFFBEA6FF),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: Text(l10n.downloadQuality),
              subtitle: Text(quality == 'High' ? l10n.high : quality == 'Medium' ? l10n.medium : l10n.low),
              trailing: DropdownButton<String>(
                value: quality,
                items: [
                  DropdownMenuItem(value: 'High', child: Text(l10n.high)),
                  DropdownMenuItem(value: 'Medium', child: Text(l10n.medium)),
                  DropdownMenuItem(value: 'Low', child: Text(l10n.low)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => quality = value);
                },
                dropdownColor: const Color(0xFF121212),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: Text(l10n.language),
              subtitle: Text(languages[selectedLanguage] ?? 'English'),
              trailing: DropdownButton<String>(
                value: selectedLanguage,
                items: languages.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedLanguage = value);
                    localeProvider.setLocaleFromString(value);
                  }
                },
                dropdownColor: const Color(0xFF121212),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 4),
            ListTile(
              title: const Text('Önbelleği temizle'),
              subtitle: const Text('Geçici dosyaları ve indirilen önbelleği siler'),
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.delete_outline, color: Color(0xFFBEA6FF)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
