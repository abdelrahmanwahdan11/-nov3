import 'package:flutter/material.dart';

import 'package:travelmate/core/localization/app_localizations.dart';
import 'package:travelmate/core/prefs/prefs_service.dart';
import 'package:travelmate/core/theme/theme.dart';
import 'package:travelmate/features/home/explore_mock_data.dart';
import 'package:travelmate/features/place/models/explore_place.dart';

import 'search_models.dart';
import 'search_repository.dart';
import 'widgets/search_filter_sheet.dart';
import 'widgets/search_result_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ValueNotifier<List<SearchEntry>> _resultsNotifier =
      ValueNotifier<List<SearchEntry>>(<SearchEntry>[]);

  SearchFilters _filters = const SearchFilters();
  List<String> _history = <String>[];
  String _query = '';
  bool _isLoading = true;
  PrefsService? _prefsService;

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
        title: Text(localizations.translate('searchTitle')),
        actions: [
          IconButton(
            icon: const Icon(Icons.layers_rounded),
            tooltip: localizations.translate('searchGoToCatalog'),
            onPressed: () => Navigator.of(context).pushNamed('/catalog'),
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
                  _buildSearchBar(theme, localizations),
                  const SizedBox(height: 16),
                  _buildScopeChips(theme, localizations),
                  if (_history.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: _buildHistoryRow(theme, localizations),
                    ),
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
                                localizations.translate('searchEmptyState'),
                                style: theme.textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: results.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final entry = results[index];
                            return SearchResultCard(
                              entry: entry,
                              localizations: localizations,
                              onTap: () => _openEntry(entry),
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

  Widget _buildSearchBar(ThemeData theme, AppLocalizations localizations) {
    final hint = localizations.translate('searchGlobalHint');
    final display = _query.isEmpty ? hint : _query;
    return GestureDetector(
      onTap: () => _openSearchDelegate(localizations),
      child: GlassSurface(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                display,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(
                    _query.isEmpty ? 0.6 : 0.9,
                  ),
                ),
              ),
            ),
            Icon(Icons.history_toggle_off_rounded,
                color: theme.colorScheme.onSurface.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeChips(ThemeData theme, AppLocalizations localizations) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        for (final scope in SearchScope.values)
          FilterChip(
            label: Text(localizations.translate(scope.localizationKey)),
            selected: _filters.scopes.contains(scope),
            onSelected: (_) => _toggleScope(scope),
          ),
      ],
    );
  }

  Widget _buildHistoryRow(ThemeData theme, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              localizations.translate('searchHistoryTitle'),
              style: theme.textTheme.titleMedium,
            ),
            const Spacer(),
            TextButton(
              onPressed: _clearHistory,
              child: Text(localizations.translate('searchClearHistory')),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _history
              .map(
                (query) => ActionChip(
                  label: Text(query),
                  onPressed: () => _applyQuery(query),
                ),
              )
              .toList(),
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
    _history.removeWhere(
      (item) => item.toLowerCase() == query.toLowerCase(),
    );
    _history.insert(0, query);
    if (_history.length > 8) {
      _history = _history.sublist(0, 8);
    }
    _prefsService?.saveSearchHistory(_history);
  }

  Future<void> _clearHistory() async {
    await _prefsService?.clearSearchHistory();
    setState(() {
      _history = <String>[];
    });
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

  void _toggleScope(SearchScope scope) {
    final scopes = List<SearchScope>.from(_filters.scopes);
    if (scopes.contains(scope)) {
      scopes.remove(scope);
      if (scopes.isEmpty) {
        scopes.add(scope);
      }
    } else {
      scopes.add(scope);
    }
    _updateFilters(_filters.copyWith(scopes: scopes));
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

class GlobalSearchDelegate extends SearchDelegate<String?> {
  GlobalSearchDelegate({
    required this.localizations,
    required this.filters,
    required this.history,
  }) : super(searchFieldLabel: localizations.translate('searchGlobalHint'));

  final AppLocalizations localizations;
  final SearchFilters filters;
  final List<String> history;

  SearchEntry? lastSelectedEntry;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.check_rounded),
          onPressed: () {
            final trimmed = query.trim();
            if (trimmed.isEmpty) {
              close(context, null);
            } else {
              lastSelectedEntry = null;
              close(context, trimmed);
            }
          },
        ),
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear_rounded),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results =
        SearchRepository.search(query: query.trim(), filters: filters);
    return _SearchDelegateResults(
      localizations: localizations,
      results: results,
      onSelected: (entry) {
        lastSelectedEntry = entry;
        close(context, entry.title);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      if (history.isEmpty) {
        return Center(
          child: Text(localizations.translate('searchHistoryEmpty')),
        );
      }
      return ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          return ListTile(
            leading: const Icon(Icons.history_rounded),
            title: Text(item),
            onTap: () {
              lastSelectedEntry = null;
              close(context, item);
            },
          );
        },
      );
    }
    final suggestions = SearchRepository.suggestions(
      query: query,
      filters: filters,
      limit: 8,
    );
    return _SearchDelegateResults(
      localizations: localizations,
      results: suggestions,
      onSelected: (entry) {
        lastSelectedEntry = entry;
        close(context, entry.title);
      },
    );
  }
}

class _SearchDelegateResults extends StatelessWidget {
  const _SearchDelegateResults({
    required this.localizations,
    required this.results,
    required this.onSelected,
  });

  final AppLocalizations localizations;
  final List<SearchEntry> results;
  final ValueChanged<SearchEntry> onSelected;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Center(
        child: Text(localizations.translate('searchEmptyState')),
      );
    }
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(entry.imageUrl),
          ),
          title: Text(entry.title),
          subtitle: Text('${entry.location} · '
              '${localizations.translate(entry.scope.localizationKey)}'),
          onTap: () => onSelected(entry),
        );
      },
    );
  }
}
