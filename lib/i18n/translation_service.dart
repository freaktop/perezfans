import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslationService extends ChangeNotifier {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  static const String _localeKey = 'app_locale';
  static const String defaultLocale = 'en';

  String _currentLocale = defaultLocale;
  Map<String, String> _translations = {};

  String get currentLocale => _currentLocale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLocale = prefs.getString(_localeKey) ?? defaultLocale;
    await _loadTranslations(_currentLocale);
    notifyListeners();
  }

  Future<void> setLocale(String locale) async {
    _currentLocale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale);
    await _loadTranslations(locale);
    notifyListeners();
  }

  Future<void> _loadTranslations(String locale) async {
    try {
      final jsonString =
          await rootBundle.loadString('lib/i18n/$locale.json');
      final map = json.decode(jsonString) as Map<String, dynamic>;
      _translations = map.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      _translations = {};
    }
  }

  String translate(String key, {String? fallback}) {
    return _translations[key] ?? fallback ?? key;
  }
}

String tr(String key, {String? fallback}) =>
    TranslationService().translate(key, fallback: fallback);
