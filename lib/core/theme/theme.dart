import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:travelmate/core/theme/color_scheme.dart';
import 'package:travelmate/core/theme/palettes.dart';

class AppTheme {
  AppTheme({
    required this.primaryColor,
    required this.locale,
    required this.accentPalette,
  });

  final Color primaryColor;
  final Locale locale;
  final AccentPalette accentPalette;

  ThemeData light() => _createTheme(Brightness.light);

  ThemeData dark() => _createTheme(Brightness.dark);

  ThemeData _createTheme(Brightness brightness) {
    final accentPrimary =
        Color.lerp(primaryColor, accentPalette.blendColor, 0.35) ?? primaryColor;
    final colorScheme = brightness == Brightness.light
        ? AppColorSchemes.light(accentPrimary)
        : AppColorSchemes.dark(accentPrimary);
    final textTheme = _typography(brightness);

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      fontFamily: null,
    );

    final surfaceTintOpacity = brightness == Brightness.light ? 0.12 : 0.2;
    final glassColor = Color.alphaBlend(
      accentPalette.blendColor.withOpacity(
        brightness == Brightness.light ? 0.08 : 0.14,
      ),
      colorScheme.surface.withOpacity(brightness == Brightness.light ? 0.85 : 0.35),
    );

    return base.copyWith(
      scaffoldBackgroundColor: Color.alphaBlend(
        accentPalette.blendColor.withOpacity(
          brightness == Brightness.light ? 0.04 : 0.12,
        ),
        colorScheme.surface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: glassColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: colorScheme.primary.withOpacity(surfaceTintOpacity),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: glassColor,
        elevation: 3,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        surfaceTintColor: colorScheme.primary.withOpacity(surfaceTintOpacity),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: glassColor,
        surfaceTintColor: colorScheme.primary.withOpacity(surfaceTintOpacity),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: colorScheme.primaryContainer.withOpacity(0.5),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onPrimaryContainer,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: glassColor,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
      ),
      iconTheme: base.iconTheme.copyWith(color: colorScheme.onSurface),
      dividerColor: colorScheme.outline.withOpacity(0.3),
      splashFactory: InkSparkle.splashFactory,
      extensions: <ThemeExtension<dynamic>>[
        AccentGradientTheme(colors: accentPalette.colors),
      ],
    );
  }

  TextTheme _typography(Brightness brightness) {
    final isArabic = locale.languageCode == 'ar';
    final baseColor =
        brightness == Brightness.light ? Colors.black87 : Colors.white;

    final displayFont = isArabic
        ? GoogleFonts.cairo
        : GoogleFonts.plusJakartaSans;
    final bodyFont = isArabic
        ? GoogleFonts.notoSansArabic
        : GoogleFonts.inter;

    return TextTheme(
      displayLarge: displayFont(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleLarge: bodyFont(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      bodyLarge: bodyFont(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      bodyMedium: bodyFont(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseColor.withOpacity(0.9),
      ),
      bodySmall: bodyFont(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: baseColor.withOpacity(0.7),
      ),
      labelLarge: bodyFont(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
    );
  }
}

class AccentGradientTheme extends ThemeExtension<AccentGradientTheme> {
  const AccentGradientTheme({required this.colors});

  final List<Color> colors;

  @override
  AccentGradientTheme copyWith({List<Color>? colors}) {
    return AccentGradientTheme(colors: colors ?? this.colors);
  }

  @override
  ThemeExtension<AccentGradientTheme> lerp(
    ThemeExtension<AccentGradientTheme>? other,
    double t,
  ) {
    if (other is! AccentGradientTheme) {
      return this;
    }
    final length = colors.length;
    final targetLength = other.colors.length;
    final maxLength = length > targetLength ? length : targetLength;
    final blended = <Color>[];
    for (var i = 0; i < maxLength; i++) {
      final from = colors[i % length];
      final to = other.colors[i % targetLength];
      blended.add(Color.lerp(from, to, t) ?? from);
    }
    return AccentGradientTheme(colors: blended);
  }
}

class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(
              theme.brightness == Brightness.light ? 0.85 : 0.35,
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
