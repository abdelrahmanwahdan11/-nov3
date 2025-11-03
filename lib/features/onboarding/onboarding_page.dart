import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'package:travelmate/core/controllers/app_controller.dart';
import 'package:travelmate/core/localization/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.titleKey,
    required this.imageUrl,
  });

  final String titleKey;
  final String imageUrl;
}

const _slides = <_OnboardingSlide>[
  _OnboardingSlide(
    titleKey: 'onboardingSlide1Title',
    imageUrl: 'https://images.unsplash.com/photo-1526772662000',
  ),
  _OnboardingSlide(
    titleKey: 'onboardingSlide2Title',
    imageUrl: 'https://images.unsplash.com/photo-1500530855697',
  ),
  _OnboardingSlide(
    titleKey: 'onboardingSlide3Title',
    imageUrl: 'https://images.unsplash.com/photo-1482192596544',
  ),
];

class _OnboardingPageState extends State<OnboardingPage> {
  static const _autoAdvanceDuration = Duration(milliseconds: 3000);
  static const _pageAnimationDuration = Duration(milliseconds: 600);

  late final PageController _pageController;
  late final ValueNotifier<int> _pageNotifier;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageNotifier = ValueNotifier<int>(0);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _pageController.dispose();
    _pageNotifier.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(_autoAdvanceDuration, (_) {
      if (!_pageController.hasClients) {
        return;
      }
      final nextPage = (_pageNotifier.value + 1) % _slides.length;
      _pageController.animateToPage(
        nextPage,
        duration: _pageAnimationDuration,
        curve: Curves.easeOutQuad,
      );
    });
  }

  void _stopAutoScroll() {
    _autoTimer?.cancel();
    _autoTimer = null;
  }

  Future<void> _completeOnboarding({required bool asGuest}) async {
    final controller = AppControllerScope.of(context);
    if (asGuest) {
      await controller.setGuestMode(true);
    } else {
      await controller.setGuestMode(false);
    }
    await controller.setHasOnboarded(true);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  void _handleNext() {
    final index = _pageNotifier.value;
    _stopAutoScroll();
    if (index < _slides.length - 1) {
      _pageController
          .animateToPage(
        index + 1,
        duration: _pageAnimationDuration,
        curve: Curves.easeOutQuad,
      )
          .whenComplete(() {
        if (mounted) {
          _startAutoScroll();
        }
      });
    } else {
      unawaited(_completeOnboarding(asGuest: false));
    }
  }

  Widget _buildDotsIndicator(ThemeData theme) {
    return ValueListenableBuilder<int>(
      valueListenable: _pageNotifier,
      builder: (context, index, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (dotIndex) {
            final isActive = index == dotIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: isActive ? 14 : 8,
              height: isActive ? 14 : 8,
              decoration: BoxDecoration(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSlide(BuildContext context, int index) {
    final slide = _slides[index];
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double page = 0;
                  if (_pageController.hasClients &&
                      _pageController.page != null) {
                    page = _pageController.page!;
                  } else {
                    page = _pageNotifier.value.toDouble();
                  }
                  final delta = page - index;
                  final horizontalOffset = delta * constraints.maxWidth * 0.15;
                  return Transform.translate(
                    offset: Offset(horizontalOffset, 0),
                    child: child,
                  );
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(slide.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.surface.withOpacity(0),
                      theme.colorScheme.surface.withOpacity(0.85),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final controller = AppControllerScope.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizations.translate('onboardingTitle'),
                    style: theme.textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.translate_outlined),
                    onPressed: controller.toggleLanguage,
                    tooltip: localizations.translate('language'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollStartNotification &&
                            notification.dragDetails != null) {
                          _stopAutoScroll();
                        } else if (notification is ScrollEndNotification) {
                          _startAutoScroll();
                        }
                        return false;
                      },
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _slides.length,
                        onPageChanged: (index) {
                          _pageNotifier.value = index;
                        },
                        itemBuilder: (context, index) {
                          return _buildSlide(context, index);
                        },
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: ValueListenableBuilder<int>(
                        valueListenable: _pageNotifier,
                        builder: (context, index, _) {
                          final slide = _slides[index];
                          final localeCode =
                              Localizations.localeOf(context).languageCode;
                          return PageTransitionSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder: (
                              child,
                              animation,
                              secondaryAnimation,
                            ) {
                              return FadeThroughTransition(
                                animation: animation,
                                secondaryAnimation: secondaryAnimation,
                                child: child,
                              );
                            },
                            child: Container(
                              key: ValueKey(
                                '${slide.titleKey}-$localeCode',
                              ),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withOpacity(0.35),
                                ),
                              ),
                              child: Text(
                                localizations.translate(slide.titleKey),
                                style: theme.textTheme.displayMedium ??
                                    theme.textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildDotsIndicator(theme),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _stopAutoScroll();
                        unawaited(_completeOnboarding(asGuest: false));
                      },
                      child: Text(localizations.translate('skip')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _handleNext,
                      child: Text(localizations.translate('next')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () {
                    _stopAutoScroll();
                    unawaited(_completeOnboarding(asGuest: true));
                  },
                  child: Text(localizations.translate('enterAsGuest')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
