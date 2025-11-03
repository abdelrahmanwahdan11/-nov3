import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:travelmate/core/controllers/app_controller.dart';
import 'package:travelmate/core/localization/app_localizations.dart';
import 'package:travelmate/core/prefs/prefs_service.dart';
import 'package:travelmate/core/routes/app_router.dart';
import 'package:travelmate/core/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await PrefsService.getInstance();
  final controller = AppController(
    prefsService: prefs,
    fallbackLocale: const Locale('ar'),
  );
  await controller.load();

  runApp(
    AppControllerScope(
      controller: controller,
      child: TravelmateApp(controller: controller),
    ),
  );
}

class TravelmateApp extends StatelessWidget {
  const TravelmateApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final appTheme =
            AppTheme(primaryColor: controller.primaryColor, locale: controller.locale);
        return MaterialApp(
          title: 'Travelmate',
          debugShowCheckedModeBanner: false,
          theme: appTheme.light(),
          darkTheme: appTheme.dark(),
          themeMode: controller.themeMode,
          locale: controller.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale != null) {
              for (final supported in supportedLocales) {
                if (supported.languageCode == locale.languageCode) {
                  return supported;
                }
              }
            }
            return controller.locale;
          },
          navigatorKey: AppRouter.instance.navigatorKey,
          initialRoute: AppRouter.initialRoute,
          onGenerateRoute: AppRouter.instance.onGenerateRoute,
          routes: AppRouter.routes,
        );
      },
    );
  }
}
