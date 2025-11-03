import 'package:flutter/material.dart';

import 'package:travelmate/core/localization/app_localizations.dart';
import 'package:travelmate/core/theme/theme.dart';

import '../car_models.dart';

class CarFilterSheet extends StatefulWidget {
  const CarFilterSheet({
    super.key,
    required this.initialFilters,
    required this.availableBrands,
    required this.availableFuels,
    required this.availableTransmissions,
    required this.priceBounds,
  });

  final CarComparisonFilters initialFilters;
  final List<String> availableBrands;
  final List<String> availableFuels;
  final List<String> availableTransmissions;
  final RangeValues priceBounds;

  static Future<CarComparisonFilters?> show(
    BuildContext context, {
    required CarComparisonFilters filters,
    required List<String> brands,
    required List<String> fuels,
    required List<String> transmissions,
    required RangeValues priceBounds,
  }) {
    return showModalBottomSheet<CarComparisonFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CarFilterSheet(
          initialFilters: filters,
          availableBrands: brands,
          availableFuels: fuels,
          availableTransmissions: transmissions,
          priceBounds: priceBounds,
        );
      },
    );
  }

  @override
  State<CarFilterSheet> createState() => _CarFilterSheetState();
}

class _CarFilterSheetState extends State<CarFilterSheet> {
  late RangeValues _priceRange;
  late Set<String> _brands;
  late Set<String> _fuels;
  late Set<String> _transmissions;

  @override
  void initState() {
    super.initState();
    final min = widget.priceBounds.start;
    final max = widget.priceBounds.end;
    final initial = widget.initialFilters.priceRange;
    final start = initial.start.clamp(min, max);
    final end = initial.end.clamp(min, max);
    _priceRange = RangeValues(start, end);
    _brands = Set<String>.from(widget.initialFilters.brands);
    _fuels = Set<String>.from(widget.initialFilters.fuels);
    _transmissions = Set<String>.from(widget.initialFilters.transmissions);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.9,
      builder: (context, controller) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: GlassSurface(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: CustomScrollView(
              controller: controller,
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.translate('compareFiltersTitle'),
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        localizations.translate('compareFiltersSubtitle'),
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      _buildFilterSection(
                        context,
                        title: localizations.translate('compareFilterPrice'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.translate('compareFilterPriceLabel')
                                  .replaceFirst(
                                '{range}',
                                '${_priceRange.start.round()} - ${_priceRange.end.round()}',
                              ),
                              style: theme.textTheme.bodyMedium,
                            ),
                            RangeSlider(
                              values: _priceRange,
                              min: widget.priceBounds.start,
                              max: widget.priceBounds.end,
                              divisions: (widget.priceBounds.end -
                                      widget.priceBounds.start)
                                  .clamp(1, 40)
                                  .round(),
                              labels: RangeLabels(
                                _priceRange.start.round().toString(),
                                _priceRange.end.round().toString(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _priceRange = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildChipSection(
                        context,
                        title: localizations.translate('compareFilterBrands'),
                        values: widget.availableBrands,
                        selected: _brands,
                        onChanged: (value) {
                          setState(() {
                            if (!_brands.add(value)) {
                              _brands.remove(value);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildChipSection(
                        context,
                        title: localizations.translate('compareFilterFuel'),
                        values: widget.availableFuels,
                        selected: _fuels,
                        onChanged: (value) {
                          setState(() {
                            if (!_fuels.add(value)) {
                              _fuels.remove(value);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildChipSection(
                        context,
                        title: localizations.translate('compareFilterTransmission'),
                        values: widget.availableTransmissions,
                        selected: _transmissions,
                        onChanged: (value) {
                          setState(() {
                            if (!_transmissions.add(value)) {
                              _transmissions.remove(value);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _brands.clear();
                                  _fuels.clear();
                                  _transmissions.clear();
                                  _priceRange = widget.priceBounds;
                                });
                              },
                              child: Text(
                                localizations.translate('compareFiltersReset'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                Navigator.of(context).pop(
                                  CarComparisonFilters(
                                    brands: _brands,
                                    fuels: _fuels,
                                    transmissions: _transmissions,
                                    priceRange: _priceRange,
                                  ),
                                );
                              },
                              child: Text(
                                localizations.translate('compareFiltersApply'),
                              ),
                            ),
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
      },
    );
  }

  Widget _buildFilterSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildChipSection(
    BuildContext context, {
    required String title,
    required List<String> values,
    required Set<String> selected,
    required ValueChanged<String> onChanged,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in values)
              FilterChip(
                label: Text(value),
                selected: selected.contains(value),
                onSelected: (_) => onChanged(value),
              ),
            if (values.isEmpty)
              Chip(
                label: Text(AppLocalizations.of(context)
                    .translate('compareFiltersNoOptions')),
              ),
          ],
        ),
      ],
    );
  }
}
