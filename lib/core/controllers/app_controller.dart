import 'package:flutter/material.dart';

import 'package:travelmate/core/prefs/prefs_service.dart';

typedef LocaleChangedCallback = void Function(Locale locale);

class AppController extends ChangeNotifier {
  AppController({
    required PrefsService prefsService,
    Locale? fallbackLocale,
  })  : _prefsService = prefsService,
        _locale = fallbackLocale ?? const Locale('ar');

  final PrefsService _prefsService;

  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = Colors.teal;
  Locale _locale;

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  Locale get locale => _locale;

  Future<void> load() async {
    _themeMode = _prefsService.loadThemeMode() ?? ThemeMode.system;
    _primaryColor = _prefsService.loadPrimaryColor() ?? Colors.teal;
    _locale = _prefsService.loadLocale() ?? _locale;
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) {
      return;
    }
    _themeMode = mode;
    await _prefsService.saveThemeMode(mode);
    notifyListeners();
  }

  Future<void> updatePrimaryColor(Color color) async {
    if (_primaryColor.value == color.value) {
      return;
    }
    _primaryColor = color;
    await _prefsService.savePrimaryColor(color);
    notifyListeners();
  }

  Future<void> updateLocale(Locale locale) async {
    if (_locale == locale) {
      return;
    }
    _locale = locale;
    await _prefsService.saveLocale(locale);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    final targetCode = _locale.languageCode == 'ar' ? 'en' : 'ar';
    await updateLocale(Locale(targetCode));
  }
}

class AppControllerScope extends InheritedNotifier<AppController> {
  const AppControllerScope({
    super.key,
    required AppController controller,
    required Widget child,
  }) : super(notifier = controller, child: child);

  static AppController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppControllerScope>();
    assert(scope != null, 'AppControllerScope not found in context');
    return scope!.notifier!;
  }
}
