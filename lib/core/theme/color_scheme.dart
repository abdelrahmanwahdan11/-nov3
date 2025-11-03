import 'package:flutter/material.dart';

class AppColorSchemes {
  const AppColorSchemes._();

  static ColorScheme light(Color primary) {
    final seed = primary;
    return ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    ).copyWith(primary: primary);
  }

  static ColorScheme dark(Color primary) {
    final seed = primary;
    return ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    ).copyWith(primary: primary);
  }
}
