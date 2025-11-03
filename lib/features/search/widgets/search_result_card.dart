import 'package:flutter/material.dart';

import 'package:travelmate/core/localization/app_localizations.dart';
import 'package:travelmate/core/theme/theme.dart';

import '../search_models.dart';

class SearchResultCard extends StatelessWidget {
  const SearchResultCard({
    super.key,
    required this.entry,
    required this.localizations,
    this.onTap,
  });

  final SearchEntry entry;
  final AppLocalizations localizations;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: GlassSurface(
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                entry.imageUrl,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(entry.scope.icon, size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        localizations.translate(entry.scope.localizationKey),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.star_rounded, color: theme.colorScheme.tertiary, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        entry.rating.toStringAsFixed(1),
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.title,
                    style: theme.textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _InfoChip(
                        icon: Icons.place_rounded,
                        label: entry.location,
                      ),
                      _InfoChip(
                        icon: Icons.category_rounded,
                        label: localizations.translate(entry.categoryKey),
                      ),
                      _InfoChip(
                        icon: Icons.directions_walk_rounded,
                        label: '${entry.distanceKm.toStringAsFixed(1)} km',
                      ),
                      _InfoChip(
                        icon: Icons.payments_rounded,
                        label: 'SAR ${entry.price.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassSurface(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

extension on SearchEntry {
  String get categoryKey {
    final normalized = category.toLowerCase();
    switch (normalized) {
      case 'must-see':
        return 'categoryMustSee';
      case 'hidden gem':
        return 'categoryHiddenGem';
      case 'food & café':
        return 'categoryFoodCafe';
      case 'festival':
        return 'searchCategoryFestival';
      case 'retreat':
        return 'searchCategoryRetreat';
      case 'adventure':
        return 'searchCategoryAdventure';
      case 'electric':
        return 'searchCategoryElectric';
      case 'hybrid':
        return 'searchCategoryHybrid';
      case 'performance':
        return 'searchCategoryPerformance';
    }
    return category;
  }
}
