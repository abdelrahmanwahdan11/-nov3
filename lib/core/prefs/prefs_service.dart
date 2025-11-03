import 'dart:convert';

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
  static const _coachMarksKey = 'has_seen_coach_marks';
  static const _planDestinationKey = 'plan_destination';
  static const _planWeekdaysKey = 'plan_weekdays';
  static const _planBudgetMinKey = 'plan_budget_min';
  static const _planBudgetMaxKey = 'plan_budget_max';
  static const _planStylesKey = 'plan_styles';
  static const _journalEntriesKey = 'journal_entries';
  static const _searchFiltersKey = 'search_filters';
  static const _searchHistoryKey = 'search_history';
  static const _compareSelectedCarsKey = 'compare_selected_cars';
  static const _compareFiltersKey = 'compare_filters';
  static const _savedPlaceIdsKey = 'saved_place_ids';
  static const _accentPaletteKey = 'accent_palette';

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

  bool loadHasSeenCoachMarks() {
    return _prefs.getBool(_coachMarksKey) ?? false;
  }

  Future<void> saveHasSeenCoachMarks(bool value) async {
    await _prefs.setBool(_coachMarksKey, value);
  }

  String? loadPlanDestination() {
    return _prefs.getString(_planDestinationKey);
  }

  Future<void> savePlanDestination(String? value) async {
    if (value == null || value.isEmpty) {
      await _prefs.remove(_planDestinationKey);
      return;
    }
    await _prefs.setString(_planDestinationKey, value);
  }

  List<int> loadPlanWeekdays() {
    final stored = _prefs.getStringList(_planWeekdaysKey);
    if (stored == null) {
      return <int>[];
    }
    return stored
        .map((value) => int.tryParse(value))
        .whereType<int>()
        .toList();
  }

  Future<void> savePlanWeekdays(List<int> values) async {
    if (values.isEmpty) {
      await _prefs.remove(_planWeekdaysKey);
      return;
    }
    await _prefs.setStringList(
      _planWeekdaysKey,
      values.map((value) => value.toString()).toList(),
    );
  }

  RangeValues loadPlanBudgetRange() {
    final start = _prefs.getDouble(_planBudgetMinKey);
    final end = _prefs.getDouble(_planBudgetMaxKey);
    if (start != null && end != null) {
      return RangeValues(start, end);
    }
    return const RangeValues(600, 2200);
  }

  Future<void> savePlanBudgetRange(RangeValues values) async {
    await _prefs.setDouble(_planBudgetMinKey, values.start);
    await _prefs.setDouble(_planBudgetMaxKey, values.end);
  }

  List<String> loadPlanStyles() {
    return _prefs.getStringList(_planStylesKey) ?? <String>[];
  }

  Future<void> savePlanStyles(List<String> values) async {
    if (values.isEmpty) {
      await _prefs.remove(_planStylesKey);
      return;
    }
    await _prefs.setStringList(_planStylesKey, values);
  }

  List<Map<String, dynamic>> loadJournalEntries() {
    final jsonString = _prefs.getString(_journalEntriesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return <Map<String, dynamic>>[];
    }
    try {
      final decoded = json.decode(jsonString);
      if (decoded is! List) {
        return <Map<String, dynamic>>[];
      }
      return decoded.map<Map<String, dynamic>>((dynamic item) {
        if (item is Map<String, dynamic>) {
          return item;
        }
        if (item is Map) {
          return item.map(
            (key, value) => MapEntry(key.toString(), value),
          );
        }
        return <String, dynamic>{};
      }).toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> saveJournalEntries(List<Map<String, dynamic>> values) async {
    await _prefs.setString(_journalEntriesKey, json.encode(values));
  }

  Map<String, dynamic>? loadSearchFilters() {
    final jsonString = _prefs.getString(_searchFiltersKey);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }
    try {
      final decoded = json.decode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> saveSearchFilters(Map<String, dynamic> map) async {
    await _prefs.setString(_searchFiltersKey, json.encode(map));
  }

  List<String> loadSearchHistory() {
    return _prefs.getStringList(_searchHistoryKey) ?? <String>[];
  }

  Future<void> saveSearchHistory(List<String> values) async {
    await _prefs.setStringList(
      _searchHistoryKey,
      values.take(10).toList(),
    );
  }

  Future<void> clearSearchHistory() async {
    await _prefs.remove(_searchHistoryKey);
  }

  List<String> loadCompareSelectedCars() {
    return _prefs.getStringList(_compareSelectedCarsKey) ?? <String>[];
  }

  Future<void> saveCompareSelectedCars(List<String> ids) async {
    await _prefs.setStringList(_compareSelectedCarsKey, ids);
  }

  Map<String, dynamic>? loadCompareFilters() {
    final jsonString = _prefs.getString(_compareFiltersKey);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }
    try {
      final decoded = json.decode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> saveCompareFilters(Map<String, dynamic> map) async {
    await _prefs.setString(_compareFiltersKey, json.encode(map));
  }

  Set<String> loadSavedPlaceIds() {
    final stored = _prefs.getStringList(_savedPlaceIdsKey);
    if (stored == null) {
      return <String>{};
    }
    return stored.whereType<String>().toSet();
  }

  Future<void> saveSavedPlaceIds(Iterable<String> ids) async {
    final unique = ids.toSet().toList()..sort();
    await _prefs.setStringList(_savedPlaceIdsKey, unique);
  }

  String? loadAccentPaletteId() {
    return _prefs.getString(_accentPaletteKey);
  }

  Future<void> saveAccentPaletteId(String id) async {
    await _prefs.setString(_accentPaletteKey, id);
  }
}
