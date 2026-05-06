import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  final SharedPreferences _preferences;
  Locale _locale;
  bool _isInitialized = false;

  Locale get locale => _locale;
  bool get isInitialized => _isInitialized;

  LocaleProvider(this._preferences, this._locale);

  Future<void> initialize() async {
    if (_isInitialized) return;

    final savedLanguage = _preferences.getString('language_code');
    if (savedLanguage != null && savedLanguage.isNotEmpty) {
      _locale = Locale(savedLanguage);
    } else {
      await _preferences.setString('language_code', _locale.languageCode);
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale != locale) {
      _locale = locale;
      await _preferences.setString('language_code', locale.languageCode);
      notifyListeners();
    }
  }

  void setLocaleFromString(String languageCode) {
    setLocale(Locale(languageCode));
  }
}