import 'package:flutter/material.dart';

import 'package:travelmate/features/auth/forgot_password_page.dart';
import 'package:travelmate/features/auth/login_page.dart';
import 'package:travelmate/features/auth/register_page.dart';
import 'package:travelmate/features/catalog/catalog_page.dart';
import 'package:travelmate/features/compare_cars/compare_cars_page.dart';
import 'package:travelmate/features/home/home_page.dart';
import 'package:travelmate/features/journal/journal_page.dart';
import 'package:travelmate/features/onboarding/onboarding_page.dart';
import 'package:travelmate/features/place/place_page.dart';
import 'package:travelmate/features/plan/plan_page.dart';
import 'package:travelmate/features/profile/profile_page.dart';
import 'package:travelmate/features/profile/settings_page.dart';
import 'package:travelmate/features/search/search_page.dart';
import 'package:travelmate/features/tutorial/tutorial_page.dart';

class AppRouter {
  AppRouter._();

  static final AppRouter instance = AppRouter._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder == null) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const OnboardingPage(),
      );
    }
    return MaterialPageRoute<void>(
      settings: settings,
      builder: builder,
    );
  }

  static final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
    '/onboarding': (context) => const OnboardingPage(),
    '/auth/login': (context) => const LoginPage(),
    '/auth/register': (context) => const RegisterPage(),
    '/auth/forgot': (context) => const ForgotPasswordPage(),
    '/home': (context) => const HomePage(),
    '/plan': (context) => const PlanPage(),
    '/journal': (context) => const JournalPage(),
    '/place': (context) => const PlacePage(),
    '/search': (context) => const SearchPage(),
    '/catalog': (context) => const CatalogPage(),
    '/compare_cars': (context) => const CompareCarsPage(),
    '/profile': (context) => const ProfilePage(),
    '/settings': (context) => const SettingsPage(),
    '/tutorial': (context) => const TutorialPage(),
  };
}
