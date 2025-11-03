import 'package:flutter/material.dart';

import 'package:travelmate/core/localization/app_localizations.dart';
import 'package:travelmate/core/theme/theme.dart';

class FeatureScaffold extends StatelessWidget {
  const FeatureScaffold({
    super.key,
    required this.translationKey,
    this.actions,
    this.fab,
  });

  final String translationKey;
  final List<Widget>? actions;
  final Widget? fab;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate(translationKey)),
        actions: actions,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: GlassSurface(
            padding: const EdgeInsets.all(24),
            child: Text(
              localizations.translate(translationKey),
              style: Theme.of(context).textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      floatingActionButton: fab,
    );
  }
}
