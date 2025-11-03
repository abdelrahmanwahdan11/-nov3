import 'package:flutter/material.dart';

import 'package:travelmate/core/localization/app_localizations.dart';
import 'package:travelmate/core/theme/theme.dart';
import 'package:travelmate/features/place/models/explore_place.dart';

class PlacePage extends StatelessWidget {
  const PlacePage({super.key});

  @override
  Widget build(BuildContext context) {
    final place =
        ModalRoute.of(context)?.settings.arguments as ExplorePlace?;
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (place == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.translate('placeTitle')),
        ),
        body: Center(
          child: GlassSurface(
            padding: const EdgeInsets.all(24),
            child: Text(
              localizations.translate('homeNoResults'),
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(place.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Hero(
            tag: place.id,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.network(
                  place.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          GlassSurface(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.title,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  place.subtitle,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildDetailChip(
                      theme,
                      Icons.place,
                      '${place.location} · ${place.distanceText}',
                    ),
                    _buildDetailChip(
                      theme,
                      Icons.category,
                      localizations.translate(
                        _categoryKey(place.category),
                      ),
                    ),
                    _buildDetailChip(
                      theme,
                      Icons.star,
                      place.rating.toStringAsFixed(1),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  localizations.translate('placeAbout'),
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  place.description,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(ThemeData theme, IconData icon, String label) {
    return GlassSurface(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      radius: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  String _categoryKey(String category) {
    switch (category) {
      case 'Hidden Gem':
        return 'categoryHiddenGem';
      case 'Food & Café':
        return 'categoryFoodCafe';
      case 'Must-See':
      default:
        return 'categoryMustSee';
    }
  }
}
