import 'dart:async';

import 'package:flutter/material.dart';

import 'package:travelmate/core/controllers/app_controller.dart';
import 'package:travelmate/core/localization/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final ValueNotifier<int> _pageNotifier;
  late final StreamController<bool> _autoController;
  final List<String> _messageKeys = const [
    'onboardingMessage1',
    'onboardingMessage2',
    'onboardingMessage3',
  ];

  @override
  void initState() {
    super.initState();
    _pageNotifier = ValueNotifier<int>(0);
    _autoController = StreamController<bool>.broadcast();
    _autoController.stream.listen((trigger) {
      if (trigger) {
        final next = (_pageNotifier.value + 1) % _messageKeys.length;
        _pageNotifier.value = next;
      }
    });
  }

  @override
  void dispose() {
    _pageNotifier.dispose();
    _autoController.close();
    super.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: IconButton(
                  icon: const Icon(Icons.translate_outlined),
                  onPressed: controller.toggleLanguage,
                  tooltip: localizations.translate('language'),
                ),
              ),
              Expanded(
                child: Center(
                  child: ValueListenableBuilder<int>(
                    valueListenable: _pageNotifier,
                    builder: (context, index, child) {
                      final messageKey = _messageKeys[index];
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Container(
                          key: ValueKey(messageKey + controller.locale.languageCode),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            color: theme.colorScheme.primaryContainer
                                .withOpacity(0.45),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.travel_explore,
                                size: 82,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                localizations.translate('onboardingTitle'),
                                style: theme.textTheme.displayLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                localizations.translate(messageKey),
                                style: theme.textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/auth/login'),
                      child: Text(localizations.translate('loginTitle')),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/home'),
                      child: Text(localizations.translate('homeTitle')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: FilledButton.tonalIcon(
                  onPressed: () => _autoController.add(true),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(localizations.translate('next')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
