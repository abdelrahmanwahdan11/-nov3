import 'dart:async';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

import 'package:travelmate/core/localization/app_localizations.dart';
import 'package:travelmate/core/prefs/prefs_service.dart';
import 'package:travelmate/core/theme/theme.dart';
import 'package:travelmate/core/utils/pagination_mixin.dart';
import 'package:travelmate/core/utils/skeleton.dart';
import 'package:travelmate/features/compare_cars/car_models.dart';
import 'package:travelmate/features/compare_cars/compare_car_repository.dart';

import 'widgets/car_filter_sheet.dart';

class CompareCarsPage extends StatefulWidget {
  const CompareCarsPage({super.key});

  @override
  State<CompareCarsPage> createState() => _CompareCarsPageState();
}

class _CompareCarsPageState extends State<CompareCarsPage>
    with PaginationMixin<CompareCarsPage> {
  final ValueNotifier<List<CompareCar>> _carsNotifier =
      ValueNotifier<List<CompareCar>>(<CompareCar>[]);
  final ValueNotifier<Set<String>> _selectedNotifier =
      ValueNotifier<Set<String>>(<String>{});
  final TextEditingController _searchController = TextEditingController();

  PrefsService? _prefsService;
  CarComparisonFilters _filters = const CarComparisonFilters();
  RangeValues _priceBounds = const RangeValues(180, 680);
  List<CompareCar> _cars = <CompareCar>[];
  bool _isLoading = true;
  Timer? _debounce;

  String get _query => _searchController.text.trim();

  @override
  int get pageSize => 4;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await PrefsService.getInstance();
    final storedFilters =
        CarComparisonFilters.fromMap(prefs.loadCompareFilters());
    final selectedIds = prefs.loadCompareSelectedCars();
    final bounds = CompareCarRepository.priceBounds();
    if (!mounted) {
      return;
    }
    _selectedNotifier.value = selectedIds.toSet();
    setState(() {
      _prefsService = prefs;
      _filters = storedFilters;
      _priceBounds = bounds;
    });
    await _refreshData(showLoader: true);
  }

  @override
  void dispose() {
    _carsNotifier.dispose();
    _selectedNotifier.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Future<void> loadInitial() async {
    final cars = await CompareCarRepository.fetchCars(
      page: 1,
      pageSize: pageSize,
      query: _query,
      filters: _filters,
    );
    if (!mounted) {
      return;
    }
    _cars = cars;
    _carsNotifier.value = List<CompareCar>.from(cars);
    setState(() {
      hasMore = cars.length == pageSize;
      page = 1;
      _isLoading = false;
    });
  }

  @override
  Future<void> loadMore(int nextPage) async {
    final cars = await CompareCarRepository.fetchCars(
      page: nextPage,
      pageSize: pageSize,
      query: _query,
      filters: _filters,
    );
    if (!mounted) {
      return;
    }
    if (cars.isEmpty) {
      setState(() {
        hasMore = false;
      });
      return;
    }
    _cars.addAll(cars);
    _carsNotifier.value = List<CompareCar>.from(_cars);
    setState(() {
      hasMore = cars.length == pageSize;
    });
  }

  Future<void> _refreshData({bool showLoader = false}) async {
    _debounce?.cancel();
    if (showLoader && mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    await refresh();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () {
      _refreshData(showLoader: true);
    });
  }

  Future<void> _openFilters() async {
    final localFilters = _filters;
    final result = await CarFilterSheet.show(
      context,
      filters: localFilters,
      brands: CompareCarRepository.brands(),
      fuels: CompareCarRepository.fuels(),
      transmissions: CompareCarRepository.transmissions(),
      priceBounds: _priceBounds,
    );
    if (result == null || !mounted) {
      return;
    }
    setState(() {
      _filters = result;
    });
    await _prefsService?.saveCompareFilters(result.toMap());
    await _refreshData(showLoader: true);
  }

  void _toggleSelection(CompareCar car) {
    final current = Set<String>.from(_selectedNotifier.value);
    if (!current.add(car.id)) {
      current.remove(car.id);
    }
    _selectedNotifier.value = current;
    _prefsService?.saveCompareSelectedCars(current.toList());
  }

  void _removeSelection(String carId) {
    final current = Set<String>.from(_selectedNotifier.value);
    if (current.remove(carId)) {
      _selectedNotifier.value = current;
      _prefsService?.saveCompareSelectedCars(current.toList());
    }
  }

  Future<void> _handleRefresh() async {
    await _refreshData(showLoader: false);
  }

  List<CompareCar> _resolveSelectedCars(Set<String> ids) {
    return ids
        .map(CompareCarRepository.findById)
        .whereType<CompareCar>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('compareCarsTitle')),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: localizations.translate('compareOpenFilters'),
            onPressed: _openFilters,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.translate('compareCarsSubtitle'),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildSearchField(localizations),
                    const SizedBox(height: 24),
                    ValueListenableBuilder<Set<String>>(
                      valueListenable: _selectedNotifier,
                      builder: (context, selected, _) {
                        final selectedCars = _resolveSelectedCars(selected);
                        return _buildComparisonArea(
                          localizations,
                          theme,
                          selectedCars,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      localizations.translate('compareListTitle'),
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GlassSurface(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Skeleton(height: 180, borderRadius: 20),
                              SizedBox(height: 16),
                              Skeleton(width: 160, height: 20),
                              SizedBox(height: 8),
                              Skeleton(width: 220, height: 16),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: 4,
                  ),
                ),
              )
            else
              ValueListenableBuilder<List<CompareCar>>(
                valueListenable: _carsNotifier,
                builder: (context, cars, _) {
                  if (cars.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: GlassSurface(
                          padding: const EdgeInsets.all(24),
                          borderRadius: BorderRadius.circular(28),
                          child: Text(
                            localizations.translate('compareListEmpty'),
                            style: theme.textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }
                  return ValueListenableBuilder<Set<String>>(
                    valueListenable: _selectedNotifier,
                    builder: (context, selected, __) {
                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index >= cars.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child:
                                      Center(child: CircularProgressIndicator()),
                                );
                              }
                              final car = cars[index];
                              final isSelected = selected.contains(car.id);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: _CarCard(
                                  car: car,
                                  isSelected: isSelected,
                                  onToggle: () => _toggleSelection(car),
                                  localizations: localizations,
                                ),
                              );
                            },
                            childCount: cars.length + (hasMore ? 1 : 0),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations localizations) {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded),
        hintText: localizations.translate('compareSearchHint'),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                tooltip: localizations.translate('compareClearSearch'),
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  _searchController.clear();
                  _refreshData(showLoader: true);
                },
              ),
      ),
    );
  }

  Widget _buildComparisonArea(
    AppLocalizations localizations,
    ThemeData theme,
    List<CompareCar> selected,
  ) {
    if (selected.length < 2) {
      return GlassSurface(
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: [
            const Icon(Icons.directions_car_filled_rounded),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                localizations.translate('compareSelectedEmpty'),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    return GlassSurface(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                localizations
                    .translate('compareSelectedTitle')
                    .replaceFirst('{count}', selected.length.toString()),
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                tooltip: localizations.translate('compareOpenFilters'),
                onPressed: _openFilters,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildComparisonTable(localizations, theme, selected),
        ],
      ),
    );
  }

  Widget _buildComparisonTable(
    AppLocalizations localizations,
    ThemeData theme,
    List<CompareCar> selected,
  ) {
    final specs = <_SpecRow>[
      _SpecRow(
        label: localizations.translate('compareSpecBrand'),
        valueBuilder: (car) => car.brand,
      ),
      _SpecRow(
        label: localizations.translate('compareSpecModel'),
        valueBuilder: (car) => car.model,
      ),
      _SpecRow(
        label: localizations.translate('compareSpecYear'),
        valueBuilder: (car) => car.year.toString(),
      ),
      _SpecRow(
        label: localizations.translate('compareSpecSeats'),
        valueBuilder: (car) => car.seats.toString(),
      ),
      _SpecRow(
        label: localizations.translate('compareSpecDoors'),
        valueBuilder: (car) => car.doors.toString(),
      ),
      _SpecRow(
        label: localizations.translate('compareSpecTransmission'),
        valueBuilder: (car) => car.transmission,
      ),
      _SpecRow(
        label: localizations.translate('compareSpecFuel'),
        valueBuilder: (car) => car.fuel,
      ),
      _SpecRow(
        label: localizations.translate('compareSpecConsumption'),
        valueBuilder: (car) => car.consumption,
      ),
      _SpecRow(
        label: localizations.translate('compareSpecPrice'),
        valueBuilder: (car) =>
            '${car.pricePerDay.toString()} ${localizations.translate('compareSpecPriceSuffix')}',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final available =
            (constraints.maxWidth - 140).clamp(0.0, double.infinity);
        final columnWidth = available / selected.length;
        final carColumnWidth = columnWidth.clamp(160.0, 260.0);
        final columnWidths = <int, TableColumnWidth>{
          0: const FixedColumnWidth(140),
        };
        for (var i = 0; i < selected.length; i++) {
          columnWidths[i + 1] = FixedColumnWidth(carColumnWidth);
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: columnWidths,
                children: [
                  TableRow(
                    children: [
                      const SizedBox(),
                      for (final car in selected)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  car.displayName,
                                  style: theme.textTheme.titleSmall,
                                ),
                              ),
                              IconButton(
                                tooltip:
                                    localizations.translate('compareRemoveCar'),
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () => _removeSelection(car.id),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  for (final spec in specs)
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            spec.label,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        for (final car in selected)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              spec.valueBuilder(car),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CarCard extends StatelessWidget {
  const _CarCard({
    required this.car,
    required this.isSelected,
    required this.onToggle,
    required this.localizations,
  });

  final CompareCar car;
  final bool isSelected;
  final VoidCallback onToggle;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassSurface(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    car.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: FilledButton.tonal(
                    onPressed: onToggle,
                    child: Text(
                      localizations.translate(
                        isSelected
                            ? 'compareActionRemove'
                            : 'compareActionAdd',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.displayName,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${car.year} • ${car.transmission}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${car.pricePerDay} ${localizations.translate('compareSpecPriceSuffix')}',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${car.fuel} • ${car.consumption}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          FlipCard(
            front: _buildHighlightsCard(theme),
            back: _buildNotesCard(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsCard(ThemeData theme) {
    return GlassSurface(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded),
              const SizedBox(width: 8),
              Text(
                localizations.translate('compareHighlightsTitle'),
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final highlight in car.highlights)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      highlight,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Text(
            localizations.translate('compareFlipHint'),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(ThemeData theme) {
    return GlassSurface(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notes_rounded),
              const SizedBox(width: 8),
              Text(
                localizations.translate('compareNotesTitle'),
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            car.notes,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _SpecRow {
  const _SpecRow({required this.label, required this.valueBuilder});

  final String label;
  final String Function(CompareCar car) valueBuilder;
}
