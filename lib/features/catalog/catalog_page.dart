import 'package:flutter/material.dart';

import 'package:travelmate/core/localization/app_localizations.dart';
import 'package:travelmate/core/prefs/prefs_service.dart';
import 'package:travelmate/core/theme/theme.dart';
import 'package:travelmate/features/home/explore_mock_data.dart';
import 'package:travelmate/features/place/models/explore_place.dart';

import '../search/search_models.dart';
import '../search/search_page.dart';
import '../search/search_repository.dart';
import '../search/widgets/search_filter_sheet.dart';
import '../search/widgets/search_result_card.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final ValueNotifier<List<SearchEntry>> _resultsNotifier =
      ValueNotifier<List<SearchEntry>>(<SearchEntry>[]);

  SearchFilters _filters = const SearchFilters();
  String _query = '';
  List<String> _history = <String>[];
  PrefsService? _prefsService;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await PrefsService.getInstance();
    final storedFilters = SearchFilters.fromMap(prefs.loadSearchFilters());
    final history = prefs.loadSearchHistory();
    setState(() {
      _filters = storedFilters;
      _history = history;
      _prefsService = prefs;
      _isLoading = false;
    });
    _resultsNotifier.value =
        SearchRepository.search(query: _query, filters: storedFilters);
  }

  @override
  void dispose() {
    _resultsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('catalogTitle')),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: localizations.translate('searchTitle'),
            onPressed: () => _openSearchDelegate(localizations),
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: localizations.translate('searchOpenFilters'),
            onPressed: _openFilters,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummary(theme, localizations),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ValueListenableBuilder<List<SearchEntry>>(
                      valueListenable: _resultsNotifier,
                      builder: (context, results, _) {
                        if (results.isEmpty) {
                          return Center(
                            child: GlassSurface(
                              padding: const EdgeInsets.all(24),
                              borderRadius: BorderRadius.circular(24),
                              child: Text(
                                localizations.translate('catalogEmptyState'),
                                style: theme.textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        final grouped = SearchRepository.groupByScope(results);
                        final scopes = grouped.keys.toList();
                        return ListView.builder(
                          itemCount: scopes.length,
                          itemBuilder: (context, index) {
                            final scope = scopes[index];
                            final items = grouped[scope]!;
                            return _ScopeSection(
                              scope: scope,
                              items: items,
                              localizations: localizations,
                              onTap: _openEntry,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummary(ThemeData theme, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.translate('catalogSummaryTitle'),
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            Chip(
              label: Text(
                '${localizations.translate('searchResultsLabel')}: '
                '${_resultsNotifier.value.length}',
              ),
            ),
            for (final scope in _filters.scopes)
              Chip(
                avatar: Icon(scope.icon, size: 16),
                label: Text(localizations.translate(scope.localizationKey)),
              ),
            Chip(
              label: Text(
                '${localizations.translate('searchSortLabel')}: '
                '${localizations.translate(_filters.sort.localizationKey)}',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openSearchDelegate(AppLocalizations localizations) async {
    final delegate = GlobalSearchDelegate(
      localizations: localizations,
      filters: _filters,
      history: _history,
    );
    final result = await showSearch<String?>(
      context: context,
      delegate: delegate,
    );
    if (!mounted) {
      return;
    }
    if (delegate.lastSelectedEntry != null) {
      _openEntry(delegate.lastSelectedEntry!);
      _applyQuery(delegate.lastSelectedEntry!.title);
      return;
    }
    if (result != null && result.trim().isNotEmpty) {
      _applyQuery(result);
    }
  }

  void _applyQuery(String query) {
    final trimmed = query.trim();
    setState(() {
      _query = trimmed;
    });
    _resultsNotifier.value =
        SearchRepository.search(query: trimmed, filters: _filters);
    _updateHistory(trimmed);
  }

  void _updateHistory(String query) {
    if (query.isEmpty) {
      return;
    }
    _history.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
    _history.insert(0, query);
    if (_history.length > 8) {
      _history = _history.sublist(0, 8);
    }
    _prefsService?.saveSearchHistory(_history);
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<SearchFilters>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SearchFilterSheet(initialFilters: _filters),
        );
      },
    );
    if (result != null) {
      _updateFilters(result);
    }
  }

  void _updateFilters(SearchFilters filters) {
    setState(() {
      _filters = filters;
    });
    _prefsService?.saveSearchFilters(filters.toMap());
    _resultsNotifier.value =
        SearchRepository.search(query: _query, filters: filters);
  }

  void _openEntry(SearchEntry entry) {
    if (entry.scope == SearchScope.places || entry.scope == SearchScope.food) {
      final place = _findPlace(entry.id);
      if (place != null) {
        Navigator.of(context).pushNamed('/place', arguments: place);
        return;
      }
    }
    if (entry.scope == SearchScope.cars) {
      Navigator.of(context).pushNamed('/compare_cars');
      return;
    }
    if (entry.scope == SearchScope.events) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)
                .translate('searchEventPlaceholder'),
          ),
        ),
      );
    }
  }

  ExplorePlace? _findPlace(String id) {
    for (final place in ExploreMockData.places) {
      if (place.id == id) {
        return place;
      }
    }
    return null;
  }
}

class _ScopeSection extends StatelessWidget {
  const _ScopeSection({
    required this.scope,
    required this.items,
    required this.localizations,
    required this.onTap,
  });

  final SearchScope scope;
  final List<SearchEntry> items;
  final AppLocalizations localizations;
  final ValueChanged<SearchEntry> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(scope.icon, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                localizations.translate(scope.localizationKey),
                style: theme.textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SearchResultCard(
                entry: entry,
                localizations: localizations,
                onTap: () => onTap(entry),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
