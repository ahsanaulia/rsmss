import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('id')) {
    _loadSavedLocale();
  }

  final _storage = const FlutterSecureStorage();
  static const String _key = 'app_locale';

  Future<void> _loadSavedLocale() async {
    final saved = await _storage.read(key: _key);
    if (saved != null && saved.isNotEmpty) {
      state = Locale(saved);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _storage.write(key: _key, value: locale.languageCode);
  }
}