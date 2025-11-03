import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:travelmate/core/theme/color_scheme.dart';

class AppTheme {
  AppTheme({required this.primaryColor, required this.locale});

  final Color primaryColor;
  final Locale locale;

  ThemeData light() => _createTheme(Brightness.light);

  ThemeData dark() => _createTheme(Brightness.dark);

  ThemeData _createTheme(Brightness brightness) {
    final colorScheme = brightness == Brightness.light
        ? AppColorSchemes.light(primaryColor)
        : AppColorSchemes.dark(primaryColor);
    final textTheme = _typography(brightness);

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      fontFamily: null,
    );

    final surfaceTintOpacity = brightness == Brightness.light ? 0.12 : 0.2;
    final glassColor = colorScheme.surface.withOpacity(
      brightness == Brightness.light ? 0.85 : 0.35,
    );

    return base.copyWith(
      scaffoldBackgroundColor: colorScheme.surface,
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
