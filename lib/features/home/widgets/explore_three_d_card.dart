import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

import 'package:travelmate/core/localization/app_localizations.dart';
import 'package:travelmate/core/theme/theme.dart';

class ExploreThreeDCard extends StatefulWidget {
  const ExploreThreeDCard({super.key});

  @override
  State<ExploreThreeDCard> createState() => _ExploreThreeDCardState();
}

class _ExploreThreeDCardState extends State<ExploreThreeDCard> {
  late final Flutter3dController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Flutter3dController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final dynamic ctrl = _controller;
        await ctrl.loadObjFromAsset('assets/models/globe.obj');
        await ctrl.setZoom(1.4);
        await ctrl.setLightingIntensity(1.2);
        await ctrl.startAutoRotation(speed: 0.35);
      } catch (_) {
        // Silently ignore loading issues so the rest of the UI still works.
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    return GlassSurface(
      padding: const EdgeInsets.all(20),
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.translate('homeThreeDTitle'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                ),
                child: Flutter3dViewer(
                  controller: _controller,
                  enableTouch: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            localizations.translate('homeThreeDSubtitle'),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
