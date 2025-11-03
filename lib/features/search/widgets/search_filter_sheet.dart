import 'package:flutter/material.dart';

import 'package:travelmate/core/localization/app_localizations.dart';

import '../search_models.dart';

class SearchFilterSheet extends StatefulWidget {
  const SearchFilterSheet({
    super.key,
    required this.initialFilters,
  });

  final SearchFilters initialFilters;

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  late RangeValues _priceRange;
  late double _distance;
  late double _rating;
  late List<SearchScope> _scopes;
  late SearchSort _sort;

  @override
  void initState() {
    super.initState();
    final filters = widget.initialFilters;
    _priceRange = filters.priceRange;
    _distance = filters.maxDistance;
    _rating = filters.minRating;
    _scopes = List<SearchScope>.from(filters.scopes);
    _sort = filters.sort;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    localizations.translate('searchFiltersTitle'),
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _priceRange = const RangeValues(80, 1200);
                      _distance = 120;
                      _rating = 0;
                      _scopes = List<SearchScope>.from(SearchScope.values);
                      _sort = SearchSort.newest;
                    });
                  },
                  child: Text(localizations.translate('searchFiltersReset')),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionLabel(localizations.translate('searchFilterPrice')),
            RangeSlider(
              values: _priceRange,
              min: 40,
              max: 2000,
              divisions: 40,
              labels: RangeLabels(
                'SAR ${_priceRange.start.toStringAsFixed(0)}',
                'SAR ${_priceRange.end.toStringAsFixed(0)}',
              ),
              onChanged: (value) => setState(() => _priceRange = value),
            ),
            const SizedBox(height: 12),
            _SectionLabel(localizations.translate('searchFilterDistance')),
            Slider(
              value: _distance,
              min: 5,
              max: 200,
              divisions: 39,
              label: '${_distance.toStringAsFixed(0)} km',
              onChanged: (value) => setState(() => _distance = value),
            ),
            const SizedBox(height: 12),
            _SectionLabel(localizations.translate('searchFilterRating')),
            Slider(
              value: _rating,
              min: 0,
              max: 5,
              divisions: 5,
              label: _rating.toStringAsFixed(1),
              onChanged: (value) => setState(() => _rating = double.parse(value.toStringAsFixed(1))),
            ),
            const SizedBox(height: 12),
            _SectionLabel(localizations.translate('searchFilterCategory')),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                for (final scope in SearchScope.values)
                  FilterChip(
                    label: Text(localizations.translate(scope.localizationKey)),
                    selected: _scopes.contains(scope),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _scopes = <SearchScope>{..._scopes, scope}.toList();
                        } else {
                          _scopes = _scopes.where((value) => value != scope).toList();
                          if (_scopes.isEmpty) {
                            _scopes = <SearchScope>[scope];
                          }
                        }
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionLabel(localizations.translate('searchFilterSort')),
            ...SearchSort.values.map(
              (value) => RadioListTile<SearchSort>(
                value: value,
                groupValue: _sort,
                onChanged: (selection) => setState(() => _sort = selection ?? _sort),
                title: Text(localizations.translate(value.localizationKey)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(
                    SearchFilters(
                      priceRange: _priceRange,
                      maxDistance: _distance,
                      minRating: _rating,
                      scopes: _scopes,
                      sort: _sort,
                    ),
                  );
                },
                icon: const Icon(Icons.done_rounded),
                label: Text(localizations.translate('searchApplyFilters')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: theme.textTheme.titleMedium,
      ),
    );
  }
}
