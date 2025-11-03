import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  PrefsService._(this._prefs);

  final SharedPreferences _prefs;

  static const _themeModeKey = 'theme_mode';
  static const _primaryColorKey = 'primary_color';
  static const _localeKey = 'locale_code';
  static const _hasOnboardedKey = 'has_onboarded';
  static const _guestModeKey = 'auth_guest';

  static Future<PrefsService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return PrefsService._(prefs);
  }

  ThemeMode? loadThemeMode() {
    final value = _prefs.getString(_themeModeKey);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
    }
    return null;
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeModeKey, mode.name);
  }

  Color? loadPrimaryColor() {
    final value = _prefs.getInt(_primaryColorKey);
    if (value == null) {
      return null;
    }
    return Color(value);
  }

  Future<void> savePrimaryColor(Color color) async {
    await _prefs.setInt(_primaryColorKey, color.value);
  }

  Locale? loadLocale() {
    final code = _prefs.getString(_localeKey);
    if (code == null) {
      return null;
    }
    return Locale(code);
  }

  Future<void> saveLocale(Locale locale) async {
    await _prefs.setString(_localeKey, locale.languageCode);
  }

  bool loadHasOnboarded() {
    return _prefs.getBool(_hasOnboardedKey) ?? false;
  }

  Future<void> saveHasOnboarded(bool value) async {
    await _prefs.setBool(_hasOnboardedKey, value);
  }

  bool loadGuestMode() {
    return _prefs.getBool(_guestModeKey) ??
        _prefs.getBool('guest_mode') ??
        false;
  }

  Future<void> saveGuestMode(bool value) async {
    await _prefs.setBool(_guestModeKey, value);
    if (_guestModeKey != 'guest_mode') {
      await _prefs.remove('guest_mode');
    }
  }
}
