import 'package:flutter/material.dart';

import 'package:travelmate/core/localization/app_localizations.dart';
import 'package:travelmate/core/theme/theme.dart';
import 'package:travelmate/features/plan/plan_models.dart';

class PlanSummaryPage extends StatelessWidget {
  const PlanSummaryPage({super.key, required this.args});

  final TravelPlanSummaryArgs args;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('planSummaryTitle')),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            GlassSurface(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('planSummaryDestination'),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    args.destination,
                    style: theme.textTheme.displaySmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.translate('planSummaryDays'),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _SelectionWrap(
                    values: _resolveDayLabels(localizations),
                    emptyLabel: localizations.translate('planSummaryAnyDay'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.translate('planSummaryBudget'),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatBudgetRange(),
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.translate('planSummaryStyles'),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _SelectionWrap(
                    values: _resolveStyleLabels(localizations),
                    emptyLabel: localizations.translate('planSummaryAnyStyle'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GlassSurface(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('planSummaryItinerary'),
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ..._buildItineraryTiles(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _resolveDayLabels(AppLocalizations localizations) {
    final selected = args.selectedWeekdayIndexes;
    if (selected.isEmpty) {
      return const [];
    }
    final labels = <String>[];
    for (final option in planWeekdayOptions) {
      if (selected.contains(option.value)) {
        labels.add(localizations.translate(option.fullKey));
      }
    }
    return labels;
  }

  List<String> _resolveStyleLabels(AppLocalizations localizations) {
    final selected = args.selectedStyleIds;
    if (selected.isEmpty) {
      return const [];
    }
    final labels = <String>[];
    for (final id in selected) {
      final option = planStyleOptions.firstWhere(
        (element) => element.id == id,
        orElse: () => planStyleOptions.first,
      );
      labels.add(localizations.translate(option.translationKey));
    }
    return labels;
  }

  String _formatBudgetRange() {
    final start = args.budgetRange.start.round();
    final end = args.budgetRange.end.round();
    return '$start - $end';
  }

  List<Widget> _buildItineraryTiles(BuildContext context) {
    final tiles = <Widget>[];
    final entries = args.activities;
    for (var index = 0; index < entries.length; index++) {
      tiles.add(_ItineraryTile(entry: entries[index]));
      if (index != entries.length - 1) {
        tiles.add(const Divider(height: 24));
      }
    }
    return tiles;
  }
}

class _SelectionWrap extends StatelessWidget {
  const _SelectionWrap({
    required this.values,
    required this.emptyLabel,
  });

  final List<String> values;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return Chip(
        label: Text(emptyLabel),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((value) => Chip(label: Text(value))).toList(),
    );
  }
}

class _ItineraryTile extends StatelessWidget {
  const _ItineraryTile({required this.entry});

  final PlanItineraryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            entry.time,
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                entry.description,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
