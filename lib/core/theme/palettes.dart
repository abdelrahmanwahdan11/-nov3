import 'package:flutter/material.dart';

class AccentPalette {
  const AccentPalette({
    required this.id,
    required this.titleKey,
    required this.colors,
    required this.blendColor,
  });

  final String id;
  final String titleKey;
  final List<Color> colors;
  final Color blendColor;

  Color get previewColor => colors.first;
}

class AccentPalettes {
  const AccentPalettes._();

  static const List<AccentPalette> palettes = <AccentPalette>[
    AccentPalette(
      id: 'aurora',
      titleKey: 'accentAurora',
      colors: <Color>[
        Color(0xFF2E3192),
        Color(0xFF1BFFFF),
        Color(0xFF9C1AFF),
      ],
      blendColor: Color(0xFF1E88E5),
    ),
    AccentPalette(
      id: 'sunset',
      titleKey: 'accentSunset',
      colors: <Color>[
        Color(0xFFFF512F),
        Color(0xFFF09819),
        Color(0xFFFF5F6D),
      ],
      blendColor: Color(0xFFFF7043),
    ),
    AccentPalette(
      id: 'sahara',
      titleKey: 'accentSahara',
      colors: <Color>[
        Color(0xFFCE9FFC),
        Color(0xFFFDEB71),
        Color(0xFFFFD452),
      ],
      blendColor: Color(0xFFFFCA28),
    ),
    AccentPalette(
      id: 'midnight',
      titleKey: 'accentMidnight',
      colors: <Color>[
        Color(0xFF141E30),
        Color(0xFF243B55),
        Color(0xFF4B79A1),
      ],
      blendColor: Color(0xFF3949AB),
    ),
  ];

  static AccentPalette resolve(String id) {
    return palettes.firstWhere(
      (palette) => palette.id == id,
      orElse: () => palettes.first,
    );
  }
}
