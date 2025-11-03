import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'package:travelmate/features/auth/forgot_password_page.dart';
import 'package:travelmate/features/auth/login_page.dart';
import 'package:travelmate/features/auth/register_page.dart';
import 'package:travelmate/features/catalog/catalog_page.dart';
import 'package:travelmate/features/compare_cars/compare_cars_page.dart';
import 'package:travelmate/features/dashboard/shell_page.dart';
import 'package:travelmate/features/journal/journal_page.dart';
import 'package:travelmate/features/onboarding/onboarding_page.dart';
import 'package:travelmate/features/place/place_page.dart';
import 'package:travelmate/features/plan/plan_models.dart';
import 'package:travelmate/features/plan/plan_page.dart';
import 'package:travelmate/features/plan/plan_summary_page.dart';
import 'package:travelmate/features/profile/profile_page.dart';
import 'package:travelmate/features/profile/settings_page.dart';
import 'package:travelmate/features/search/search_page.dart';
import 'package:travelmate/features/tutorial/tutorial_page.dart';

class AppRouter {
  AppRouter._();

  static final AppRouter instance = AppRouter._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/onboarding':
        return _fadeThrough(settings, const OnboardingPage());
      case '/auth/login':
        return _modal(settings, const LoginPage());
      case '/auth/register':
        return _modal(settings, const RegisterPage());
      case '/auth/forgot':
        return _modal(settings, const ForgotPasswordPage());
      case '/home':
        final initial = settings.arguments;
        final index = initial is int ? initial : 0;
        return _fadeThrough(settings, ShellPage(initialIndex: index));
      case '/plan':
        return _fadeThrough(settings, const PlanPage());
      case '/plan/summary':
        final arguments = settings.arguments;
        if (arguments is! TravelPlanSummaryArgs) {
          return _fadeThrough(settings, const PlanPage());
        }
        return PageRouteBuilder<void>(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 450),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) {
            return PlanSummaryPage(args: arguments);
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.vertical,
              child: child,
            );
          },
        );
      case '/journal':
        return _fadeThrough(settings, const JournalPage());
      case '/place':
        return _fadeThrough(settings, const PlacePage());
      case '/search':
        return _sharedAxis(settings, const SearchPage());
      case '/catalog':
        return _fadeThrough(settings, const CatalogPage());
      case '/compare_cars':
        return _sharedAxis(settings, const CompareCarsPage());
      case '/profile':
        return _fadeThrough(settings, const ProfilePage());
      case '/settings':
        return _sharedAxis(settings, const SettingsPage());
      case '/tutorial':
        return _fadeThrough(settings, const TutorialPage());
      default:
        return null;
    }
  }

  Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return _fadeThrough(settings, const OnboardingPage());
  }

  PageRoute<dynamic> _fadeThrough(RouteSettings settings, Widget child) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }

  PageRoute<dynamic> _modal(RouteSettings settings, Widget child) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(
            opacity: curved,
            child: child,
          ),
        );
      },
    );
  }

  PageRoute<dynamic> _sharedAxis(RouteSettings settings, Widget child) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.scaled,
          child: child,
        );
      },
    );
  }
}
