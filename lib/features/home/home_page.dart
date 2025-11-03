import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'package:travelmate/core/controllers/app_controller.dart';
import 'package:travelmate/core/localization/app_localizations.dart';
import 'package:travelmate/core/theme/palettes.dart';
import 'package:travelmate/core/theme/theme.dart';
import 'package:travelmate/core/utils/pagination_mixin.dart';
import 'package:travelmate/core/utils/skeleton.dart';
import 'package:travelmate/core/widgets/atoms/animated_gradient_card.dart';
import 'package:travelmate/core/widgets/atoms/staggered_slide_fade.dart';
import 'package:travelmate/features/home/explore_mock_data.dart';
import 'package:travelmate/features/home/widgets/explore_three_d_card.dart';
import 'package:travelmate/features/place/models/explore_place.dart';
import 'package:travelmate/features/search/search_models.dart';
import 'package:travelmate/features/search/widgets/search_filter_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with PaginationMixin<HomePage> {
  static const _categories = <String>['Must-See', 'Hidden Gem', 'Food & Café'];

  final List<ExplorePlace> _visiblePlaces = <ExplorePlace>[];
  String _selectedCategory = _categories.first;
  bool _isInitialLoading = true;
  SearchFilters _filters = const SearchFilters();
  TutorialCoachMark? _coachMark;
  bool _tutorialQueued = false;

  final GlobalKey _searchActionKey = GlobalKey();
  final GlobalKey _filterButtonKey = GlobalKey();
  final GlobalKey _placeCardKey = GlobalKey();
  final GlobalKey _generateCardKey = GlobalKey();
  final GlobalKey _themeToggleKey = GlobalKey();

  static final Map<String, int> _placeOrder = <String, int>{
    for (var i = 0; i < ExploreMockData.places.length; i++)
      ExploreMockData.places[i].id: i,
  };

  @override
  int get pageSize => 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = AppControllerScope.of(context);
      final storedFilters = SearchFilters.fromMap(
        controller.prefsService.loadSearchFilters(),
      );
      if (mounted) {
        setState(() {
          _filters = storedFilters;
        });
      }
      await loadInitial();
    });
  }

  List<ExplorePlace> get _filteredPlaces {
    final filtered = ExploreMockData.places.where((place) {
      if (place.category != _selectedCategory) {
        return false;
      }
      if (!_filters.scopes.contains(_scopeForCategory(place.category))) {
        return false;
      }
      if (place.rating < _filters.minRating) {
        return false;
      }
      final distance = _parseDistance(place);
      if (distance > _filters.maxDistance) {
        return false;
      }
      final price = _estimatePrice(place);
      if (price < _filters.priceRange.start ||
          price > _filters.priceRange.end) {
        return false;
      }
      return true;
    }).toList();
    filtered.sort(_sortPlaces);
    return filtered;
  }

  bool get _hasActiveFilters {
    const defaults = SearchFilters();
    return _filters.priceRange.start != defaults.priceRange.start ||
        _filters.priceRange.end != defaults.priceRange.end ||
        _filters.maxDistance != defaults.maxDistance ||
        _filters.minRating != defaults.minRating ||
        !_filters.showsAllScopes ||
        _filters.sort != defaults.sort;
  }

  List<ExplorePlace> get _aiRoutePlaces =>
      ExploreMockData.places.where((place) => place.isAiCurated).toList();

  List<ExplorePlace> get _hiddenGemPlaces =>
      ExploreMockData.places
          .where((place) => place.category == 'Hidden Gem')
          .toList();

  ExplorePlace? get _heroPlace {
    return _visiblePlaces.isNotEmpty
        ? _visiblePlaces.firstWhere(
            (place) => place.isHero,
            orElse: () => _visiblePlaces.first,
          )
        : null;
  }

  @override
  Future<void> loadInitial() async {
    setState(() {
      _isInitialLoading = true;
    });
    final filtered = _filteredPlaces;
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) {
      return;
    }
    setState(() {
      _visiblePlaces
        ..clear()
        ..addAll(filtered.take(pageSize));
      hasMore = filtered.length > pageSize;
      page = 1;
      _isInitialLoading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowTutorial();
    });
  }

  @override
  Future<void> loadMore(int nextPage) async {
    final filtered = _filteredPlaces;
    final start = (nextPage - 1) * pageSize;
    if (start >= filtered.length) {
      if (mounted) {
        setState(() {
          hasMore = false;
        });
      }
      return;
    }
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) {
      return;
    }
    final end = math.min(start + pageSize, filtered.length);
    setState(() {
      _visiblePlaces.addAll(filtered.sublist(start, end));
      hasMore = end < filtered.length;
    });
  }

  Future<void> _handleRefresh() {
    return refresh();
  }

  void _onCategorySelected(String category) {
    if (_selectedCategory == category) {
      return;
    }
    setState(() {
      _selectedCategory = category;
    });
    refresh();
  }

  Future<void> _openSearch(AppLocalizations localizations) async {
    final result = await showSearch<ExplorePlace?>(
      context: context,
      delegate: ExploreSearchDelegate(
        localizations: localizations,
        places: ExploreMockData.places,
      ),
    );
    if (result != null) {
      _openPlace(result);
    }
  }

  Future<void> _openFilters(AppLocalizations localizations) async {
    final controller = AppControllerScope.of(context);
    final result = await showModalBottomSheet<SearchFilters>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SearchFilterSheet(initialFilters: _filters),
    );
    if (result != null) {
      setState(() {
        _filters = result;
      });
      await controller.prefsService.saveSearchFilters(result.toMap());
      refresh();
    }
  }

  void _openPlace(ExplorePlace place) {
    Navigator.of(context).pushNamed('/place', arguments: place);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final appController = AppControllerScope.of(context);

    final heroPlace = _heroPlace;
    final remainingPlaces = heroPlace == null
        ? _visiblePlaces
        : _visiblePlaces.where((p) => p != heroPlace).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('homeTitle')),
        actions: [
          IconButton(
            key: _searchActionKey,
            icon: const Icon(Icons.search),
            onPressed: () => _openSearch(localizations),
            tooltip: localizations.translate('homeSearchTooltip'),
          ),
          IconButton(
            key: _themeToggleKey,
            icon: Icon(_themeIconFor(appController.themeMode)),
            onPressed: () => _cycleTheme(appController),
            tooltip: localizations.translate('homeThemeToggleTooltip'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAtmosphereBanner(theme, localizations),
                    const SizedBox(height: 24),
                    _buildSearchBar(theme, localizations),
                    const SizedBox(height: 16),
                    _buildCategoryChips(theme, localizations),
                    const SizedBox(height: 24),
                    if (_isInitialLoading)
                      const Skeleton(height: 220, borderRadius: 28)
                    else if (heroPlace != null)
                      _buildHeroCard(heroPlace, theme, localizations),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 260,
                      child: _isInitialLoading
                          ? const Skeleton(height: 260, borderRadius: 28)
                          : const ExploreThreeDCard(),
                    ),
                    const SizedBox(height: 24),
                    _buildPlanCta(theme, localizations),
                    const SizedBox(height: 32),
                    _buildSectionHeader(
                      localizations.translate('sectionAiRoute'),
                      theme,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: _isInitialLoading
                          ? _buildHorizontalSkeletons()
                          : _buildAiRouteCarousel(theme, localizations),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader(
                      localizations.translate('sectionHiddenGems'),
                      theme,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: _isInitialLoading
                          ? _buildHorizontalSkeletons()
                          : _buildHiddenGemsFlip(theme, localizations),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            if (_isInitialLoading)
              _buildLoadingList()
            else if (remainingPlaces.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GlassSurface(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      localizations.translate('homeEmptyCategory'),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
              )
            else
              _buildPlacesList(remainingPlaces, theme, localizations),
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).padding.bottom + 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, AppLocalizations localizations) {
    final hintStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.6),
    );
    final hasFilters = _hasActiveFilters;
    final filterColor = hasFilters
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withOpacity(0.6);
    return GlassSurface(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.search, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => _openSearch(localizations),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  localizations.translate('homeSearchHint'),
                  style: hintStyle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            key: _filterButtonKey,
            onPressed: () => _openFilters(localizations),
            tooltip: localizations.translate('homeFilterTooltip'),
            icon: Icon(Icons.tune_rounded, color: filterColor),
          ),
        ],
      ),
    );
  }

  Widget _buildAtmosphereBanner(
      ThemeData theme, AppLocalizations localizations) {
    final controller = AppControllerScope.of(context);
    final palette = AccentPalettes.resolve(controller.accentPaletteId);
    final accent = theme.extension<AccentGradientTheme>();
    final colors = accent?.colors ?? palette.colors;

    return AnimatedGradientCard(
      colors: colors,
      height: 156,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.translate('homeAtmosphereTitle'),
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.translate('homeAtmosphereSubtitle'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.86),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  localizations.translate(palette.titleKey),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  backgroundColor: Colors.white.withOpacity(0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () => Navigator.of(context).pushNamed('/settings'),
                icon: const Icon(Icons.palette_outlined, size: 18),
                label: Text(
                  localizations.translate('homeAtmosphereAction'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(ThemeData theme, AppLocalizations localizations) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return ChoiceChip(
            label: Text(localizations.translate(_categoryKey(category))),
            selected: isSelected,
            onSelected: (_) => _onCategorySelected(category),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: _categories.length,
      ),
    );
  }

  Widget _buildHeroCard(
    ExplorePlace place,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return KeyedSubtree(
      key: _placeCardKey,
      child: GestureDetector(
        onTap: () => _openPlace(place),
        child: Hero(
          tag: place.id,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  place.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildBadge(
                          localizations.translate(_categoryKey(place.category)),
                          theme,
                        ),
                        _buildBadge(place.distanceText, theme),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      place.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, ThemeData theme) {
    return GlassSurface(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      radius: 12,
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildPlanCta(ThemeData theme, AppLocalizations localizations) {
    return GlassSurface(
      key: _generateCardKey,
      radius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.translate('homePlanCtaTitle'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            localizations.translate('homePlanCtaSubtitle'),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/plan'),
            icon: const Icon(Icons.auto_awesome_rounded),
            label: Text(localizations.translate('homePlanCtaButton')),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleLarge,
    );
  }

  Widget _buildAiRouteCarousel(
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    final places = _aiRoutePlaces;
    if (places.isEmpty) {
      return Center(
        child: Text(localizations.translate('homeNoResults')),
      );
    }
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final place = places[index];
        return StaggeredSlideFade(
          index: index,
          child: SizedBox(
            width: 220,
            child: GlassSurface(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        place.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    place.title,
                    style: theme.textTheme.bodyLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place.subtitle,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _openPlace(place),
                    child: Text(localizations.translate('homeViewPlace')),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(width: 16),
      itemCount: places.length,
    );
  }

  Widget _buildHiddenGemsFlip(
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    final gems = _hiddenGemPlaces;
    if (gems.isEmpty) {
      return Center(
        child: Text(localizations.translate('homeNoResults')),
      );
    }
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final place = gems[index];
        return StaggeredSlideFade(
          index: index,
          child: SizedBox(
            width: 200,
            child: FlipCard(
              direction: FlipDirection.HORIZONTAL,
              front: GlassSurface(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          place.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      place.title,
                      style: theme.textTheme.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.location,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              back: GlassSurface(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.translate('homeHiddenGemInsight'),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Text(
                        place.description,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.bottomEnd,
                      child: TextButton(
                        onPressed: () => _openPlace(place),
                        child: Text(localizations.translate('homeViewPlace')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(width: 16),
      itemCount: gems.length,
    );
    }

  Widget _buildPlacesList(
    List<ExplorePlace> places,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= places.length) {
            return _buildLoadMoreIndicator();
          }
          final place = places[index];
          return StaggeredSlideFade(
            index: index,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => _openPlace(place),
                child: GlassSurface(
                  radius: 24,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Hero(
                        tag: place.id,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            place.imageUrl,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.title,
                              style: theme.textTheme.bodyLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              place.subtitle,
                              style: theme.textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.place,
                                    size: 18,
                                    color: theme.colorScheme.primary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${place.location} · ${place.distanceText}',
                                    style: theme.textTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Icon(Icons.star, color: theme.colorScheme.primary),
                          Text(place.rating.toStringAsFixed(1)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        childCount: places.length + (isLoadingMore ? 1 : 0),
      ),
    );
  }

  Widget _buildLoadingList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Skeleton(height: 120, borderRadius: 24),
          );
        },
        childCount: 4,
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    if (!hasMore && !isLoadingMore) {
      return const SizedBox.shrink();
    }
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildHorizontalSkeletons() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return const Skeleton(width: 200, height: 200, borderRadius: 24);
      },
      separatorBuilder: (_, __) => const SizedBox(width: 16),
      itemCount: 3,
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

  SearchScope _scopeForCategory(String category) {
    switch (category) {
      case 'Food & Café':
        return SearchScope.food;
      default:
        return SearchScope.places;
    }
  }

  double _parseDistance(ExplorePlace place) {
    final value = double.tryParse(place.distanceText.split(' ').first);
    return value ?? 12;
  }

  double _estimatePrice(ExplorePlace place) {
    final random = math.Random(place.id.hashCode);
    final base = place.category == 'Food & Café' ? 65 : 140;
    final estimated = base + _parseDistance(place) * random.nextDouble() * 8;
    final clamped = estimated.clamp(40, 1600);
    return clamped is double ? clamped : (clamped as num).toDouble();
  }

  int _sortPlaces(ExplorePlace a, ExplorePlace b) {
    switch (_filters.sort) {
      case SearchSort.nearest:
        return _parseDistance(a).compareTo(_parseDistance(b));
      case SearchSort.highestRated:
        return b.rating.compareTo(a.rating);
      case SearchSort.lowestPrice:
        return _estimatePrice(a).compareTo(_estimatePrice(b));
      case SearchSort.newest:
      default:
        final orderA = _placeOrder[a.id] ?? 0;
        final orderB = _placeOrder[b.id] ?? 0;
        return orderB.compareTo(orderA);
    }
  }

  void _cycleTheme(AppController controller) {
    ThemeMode nextMode;
    switch (controller.themeMode) {
      case ThemeMode.system:
        nextMode = ThemeMode.light;
        break;
      case ThemeMode.light:
        nextMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        nextMode = ThemeMode.system;
        break;
    }
    controller.updateThemeMode(nextMode);
  }

  IconData _themeIconFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
      case ThemeMode.light:
        return Icons.wb_sunny_rounded;
      case ThemeMode.dark:
        return Icons.nights_stay_rounded;
    }
  }

  void _maybeShowTutorial() {
    if (!mounted || _tutorialQueued || _isInitialLoading) {
      return;
    }
    final controller = AppControllerScope.of(context);
    if (controller.hasSeenCoachMarks) {
      _tutorialQueued = true;
      return;
    }
    if (_searchActionKey.currentContext == null ||
        _filterButtonKey.currentContext == null ||
        _placeCardKey.currentContext == null ||
        _generateCardKey.currentContext == null ||
        _themeToggleKey.currentContext == null) {
      Future.delayed(const Duration(milliseconds: 300), _maybeShowTutorial);
      return;
    }
    final localizations = AppLocalizations.of(context);
    final targets = _buildCoachTargets(localizations);
    _tutorialQueued = true;
    _coachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black87,
      opacityShadow: 0.7,
      textSkip: localizations.translate('tutorialSkip'),
      onFinish: () => controller.setCoachMarksSeen(true),
      onSkip: () => controller.setCoachMarksSeen(true),
    )..show(context: context);
  }

  List<TargetFocus> _buildCoachTargets(AppLocalizations localizations) {
    return [
      _coachTarget(
        id: 'search',
        key: _searchActionKey,
        title: localizations.translate('tutorialSearchTitle'),
        description: localizations.translate('tutorialSearchDescription'),
        align: ContentAlign.bottom,
        shape: ShapeLightFocus.circle,
      ),
      _coachTarget(
        id: 'filter',
        key: _filterButtonKey,
        title: localizations.translate('tutorialFilterTitle'),
        description: localizations.translate('tutorialFilterDescription'),
        align: ContentAlign.top,
        shape: ShapeLightFocus.circle,
      ),
      _coachTarget(
        id: 'place-card',
        key: _placeCardKey,
        title: localizations.translate('tutorialPlaceCardTitle'),
        description: localizations.translate('tutorialPlaceCardDescription'),
        align: ContentAlign.top,
      ),
      _coachTarget(
        id: 'plan',
        key: _generateCardKey,
        title: localizations.translate('tutorialGenerateTitle'),
        description: localizations.translate('tutorialGenerateDescription'),
        align: ContentAlign.top,
      ),
      _coachTarget(
        id: 'theme',
        key: _themeToggleKey,
        title: localizations.translate('tutorialNightTitle'),
        description: localizations.translate('tutorialNightDescription'),
        align: ContentAlign.bottom,
        shape: ShapeLightFocus.circle,
      ),
    ];
  }

  TargetFocus _coachTarget({
    required String id,
    required GlobalKey key,
    required String title,
    required String description,
    ContentAlign align = ContentAlign.bottom,
    ShapeLightFocus shape = ShapeLightFocus.roundedRect,
  }) {
    final theme = Theme.of(context);
    return TargetFocus(
      identify: id,
      keyTarget: key,
      shape: shape,
      radius: shape == ShapeLightFocus.circle ? 44 : 18,
      contents: [
        TargetContent(
          align: align,
          child: _buildCoachContent(theme, title, description),
        ),
      ],
    );
  }

  Widget _buildCoachContent(ThemeData theme, String title, String description) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class ExploreSearchDelegate extends SearchDelegate<ExplorePlace?> {
  ExploreSearchDelegate({
    required this.localizations,
    required this.places,
  }) : super(searchFieldLabel: localizations.translate('homeSearchHint'));

  final AppLocalizations localizations;
  final List<ExplorePlace> places;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
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
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResultList(_filterPlaces());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildResultList(places.take(5).toList());
    }
    return _buildResultList(_filterPlaces());
  }

  List<ExplorePlace> _filterPlaces() {
    final lowerQuery = query.toLowerCase();
    return places.where((place) {
      return place.title.toLowerCase().contains(lowerQuery) ||
          place.subtitle.toLowerCase().contains(lowerQuery) ||
          place.location.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Widget _buildResultList(List<ExplorePlace> results) {
    if (results.isEmpty) {
      return Center(
        child: Text(localizations.translate('homeNoResults')),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      itemBuilder: (context, index) {
        final place = results[index];
        return ListTile(
          onTap: () => close(context, place),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              place.imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(place.title),
          subtitle: Text(
            '${place.location} · ${localizations.translate(_categoryKey(place.category))}',
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: results.length,
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
